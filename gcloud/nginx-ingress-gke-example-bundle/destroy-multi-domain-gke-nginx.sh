#!/bin/bash
set -e

# ===============================================
# CONFIGURACIÓN
# ===============================================
WORKDIR="multi-domain/manifests"
HELM_RELEASE="nginx-ingress"
CERT_MANAGER_VERSION="v1.15.0"

echo "🧹 Destrucción del despliegue multi-dominio (GKE o microk8s)"
echo "📁 Directorio de manifiestos: ${WORKDIR}"

# ===============================================
# Confirmación
# ===============================================
read -p "⚠️  Esto eliminará todos los recursos creados por el despliegue. ¿Continuar? (y/n): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Operación cancelada."
  exit 1
fi

# ===============================================
# 1. Eliminar objetos del namespace default
# ===============================================
echo "🗑️  Eliminando aplicaciones, servicios e ingress..."
kubectl delete -f "${WORKDIR}/05-ingress.yaml" --ignore-not-found
kubectl delete -f "${WORKDIR}/03-app1.yaml" --ignore-not-found
kubectl delete -f "${WORKDIR}/04-app2.yaml" --ignore-not-found
kubectl delete -f "${WORKDIR}/02-clusterissuer.yaml" --ignore-not-found

# ===============================================
# 2. Eliminar cert-manager
# ===============================================
echo "🧩 Eliminando cert-manager..."
if helm status cert-manager -n cert-manager &>/dev/null; then
  echo "🌀 Desinstalando cert-manager (Helm)..."
  helm uninstall cert-manager -n cert-manager || true
elif kubectl get ns cert-manager &>/dev/null; then
  echo "📄 Eliminando manifiesto cert-manager.yaml (modo YAML)..."
  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml --ignore-not-found
  kubectl delete ns cert-manager --ignore-not-found
else
  echo "ℹ️  cert-manager no está instalado."
fi

# ===============================================
# 3. Eliminar NGINX Ingress Controller
# ===============================================
echo "🌐 Eliminando NGINX Ingress Controller..."
if helm list -A | grep -q "${HELM_RELEASE}"; then
  helm uninstall ${HELM_RELEASE} -n ingress-nginx || true
fi
kubectl delete ns ingress-nginx --ignore-not-found

# ===============================================
# 4. Limpieza final
# ===============================================
echo "🧽 Eliminando archivos locales..."
rm -rf "${WORKDIR}"

echo "✅ Limpieza completa."
echo "Todos los recursos del despliegue multi-dominio fueron eliminados."
