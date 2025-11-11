#!/bin/bash
set -e

# ===============================================
# CONFIGURACIÓN
# ===============================================
EMAIL="escuelaint@gmail.com"      # <-- reemplazar
DOMAIN1="nginx.perfeccion.ar"         # <-- reemplazar
DOMAIN2="flask.perfeccion.ar"         # <-- reemplazar
NAMESPACE="default"
INGRESS_CLASS="nginx"
CERT_MANAGER_VERSION="v1.15.0"
HELM_RELEASE="nginx-ingress"
WORKDIR="multi-domain/manifests"

mkdir -p "${WORKDIR}"

echo "🚀 Despliegue multi-dominio con Let's Encrypt (compatible con GKE)"
echo "📁 Manifiestos en: ${WORKDIR}"

# ===============================================
# 0. Verificar dependencias
# ===============================================
if ! command -v helm &> /dev/null; then
  echo "❌ Helm no está instalado. Instálalo antes de continuar: https://helm.sh/docs/intro/install/"
  exit 1
fi

if ! command -v kubectl &> /dev/null; then
  echo "❌ kubectl no está instalado. Instálalo antes de continuar."
  exit 1
fi

echo "✅ Dependencias helm y kubectl detectadas."

# ===============================================
# 1. Detectar si estamos en GKE
# ===============================================
IS_GKE=false
if timeout 5 kubectl cluster-info dump 2>/dev/null | grep -q "gke"; then
  IS_GKE=true
  echo "☁️  Cluster GKE detectado."
else
  echo "🧩 Cluster no GKE (probablemente microk8s o bare metal)."
fi

# ===============================================
# 2. Instalar NGINX Ingress Controller
# ===============================================
echo "🔍 Verificando repositorio ingress-nginx..."
if ! helm repo list | grep -q "https://kubernetes.github.io/ingress-nginx"; then
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
fi
helm repo update >/dev/null

echo "🔍 Verificando instalación de NGINX Ingress Controller..."
if ! helm list -A | grep -q "${HELM_RELEASE}"; then
  echo "📦 Instalando NGINX Ingress Controller..."
  helm install ${HELM_RELEASE} ingress-nginx/ingress-nginx \
    --create-namespace --namespace ingress-nginx \
    --set controller.publishService.enabled=true \
    --set controller.replicaCount=2
else
  echo "✅ NGINX Ingress Controller ya instalado."
fi

DEPLOY_NAME=$(kubectl get deploy -n ingress-nginx -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep controller || true)
if [ -z "$DEPLOY_NAME" ]; then
  echo "❌ No se encontró ningún deployment del ingress-nginx. Verificá la instalación de Helm."
  helm list -A | grep ingress-nginx || true
  exit 1
fi

echo "⏳ Esperando a que el deployment '$DEPLOY_NAME' esté disponible..."
kubectl wait --namespace ingress-nginx \
  --for=condition=Available deployment/${DEPLOY_NAME} \
  --timeout=300s

kubectl get svc -n ingress-nginx

# ===============================================
# 3. Instalar cert-manager (modo GKE-aware)
# ===============================================
echo "📦 Instalando cert-manager ${CERT_MANAGER_VERSION}..."

if [ "$IS_GKE" = true ]; then
  echo "⚙️  Instalando con --set leaderElection.namespace=cert-manager (requerido en GKE)"
  helm repo add jetstack https://charts.jetstack.io >/dev/null 2>&1 || true
  helm repo update

  helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version ${CERT_MANAGER_VERSION} \
    --set installCRDs=true \
    --set global.leaderElection.namespace=cert-manager

else
  echo "📥 Instalando usando manifiesto oficial (no GKE)"
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
fi

kubectl wait --namespace cert-manager \
  --for=condition=Available deployment/cert-manager-webhook \
  --timeout=300s

echo "✅ cert-manager operativo."

# ===============================================
# 4. Crear manifiestos
# ===============================================

# ClusterIssuer
cat <<EOF > "${WORKDIR}/02-clusterissuer.yaml"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${EMAIL}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: ${INGRESS_CLASS}
EOF

# App1
cat <<EOF > "${WORKDIR}/03-app1.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: gcr.io/google-samples/hello-app:1.0
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: svc-app1
spec:
  selector:
    app: app1
  ports:
  - port: 80
    targetPort: 8080
EOF

# App2
cat <<EOF > "${WORKDIR}/04-app2.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: gcr.io/google-samples/hello-app:2.0
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: svc-app2
spec:
  selector:
    app: app2
  ports:
  - port: 80
    targetPort: 8080
EOF

# Ingress
cat <<EOF > "${WORKDIR}/05-ingress.yaml"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-domain-ingress
  annotations:
    kubernetes.io/ingress.class: "${INGRESS_CLASS}"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - ${DOMAIN1}
    - ${DOMAIN2}
    secretName: multi-domain-tls
  rules:
  - host: ${DOMAIN1}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: svc-app1
            port:
              number: 80
  - host: ${DOMAIN2}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: svc-app2
            port:
              number: 80
EOF

# ===============================================
# 5. Aplicar manifiestos
# ===============================================
echo "📥 Aplicando manifiestos..."
kubectl apply -f "${WORKDIR}/02-clusterissuer.yaml"
kubectl apply -f "${WORKDIR}/03-app1.yaml"
kubectl apply -f "${WORKDIR}/04-app2.yaml"
kubectl apply -f "${WORKDIR}/05-ingress.yaml"

# ===============================================
# 6. Resumen final
# ===============================================
echo "✅ Despliegue completo."
echo ""
echo "🔎 IP pública del Ingress:"
echo "    kubectl get svc -n ingress-nginx"
echo ""
echo "📘 Configurá DNS:"
echo "    ${DOMAIN1} -> <IP pública>"
echo "    ${DOMAIN2} -> <IP pública>"
echo ""
echo "🧾 Verificá el certificado con:"
echo "    kubectl describe certificate multi-domain-tls"
echo ""
echo "🎉 Listo para usar. Los YAML están en ${WORKDIR}"
