# Despliegue de aplicaciones en Gcloud, con ip estatica e Ingress

Basado en

- https://gitlab.com/cloudguru-public/gke-ingress-with-ssl
- https://www.youtube.com/watch?v=mOk_VJW-L0c

Tutoriales gratis:

- https://www.skills.google/paths/11/course_sessions/31809837/labs/592696
- https://www.coursera.org/learn/gcp-fundamentals
- https://www.coursera.org/learn/google-kubernetes-engine
- https://www.coursera.org/learn/deploying-workloads-google-kubernetes-engine-gke-

Pasos realizados

Al menos en Archlinux, asó instalamos Gcloud, necesario para crear infraestructura en la nube

    yay -S google-cloud-cli

Nos logueamos.

Utilizaré mi cuenta educativa, sergio@eim.esc.edu.ar, que tengo con Google Workspaces. PEro puede ser una cuenta @gmail también.

    gcloud auth login

Si o si hace falta un "proyecto". Creamos un proyecto en cloud.google.com, en mi ejemplo, gnuescuelas

Enlazamos nuestra sesión de trabajo de hoy con ese proyecto

    gcloud config set project gnuescuelas
    gcloud auth application-default login

Necesitaremos habilitar a nuestra sesión por linea de comandos, algúnas APIs

```shell
gcloud services enable gkemulticloud.googleapis.com
gcloud services enable gkeconnect.googleapis.com
gcloud services enable connectgateway.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable opsconfigmonitoring.googleapis.com
gcloud projects add-iam-policy-binding gnuescuelas --member user:sergio@eim.esc.edu.ar --role=roles/gkemulticloud.admin
```

Agrego un plugin necesario para gcloud-cli

    yay gke-gcloud-auth-plugin

Creo el cluster arriba, por linea de comandos gcloud, con Terraform, o usando la consola gráfica **como puse en las capturas de pantallas**

Cuando termino, tengo en la sección de clusteres, en mi cluster, una opción "Connect" con un comando así

    gcloud container clusters get-credentials autopilot-cluster-1 --region us-central1 --project gnuescuelas

Esto me setea mi ~/.kube/config

Ya puedo probar algunos comandos

    kubectl get nodes

Si escogí cluster administrado por Autopilot, no me aparece al principio ningún nodo. Es porque debo desplegar "algo" para que al menos se me genere automaticamente un nodo.

Cuando despliegue, me creará DOS nodos, uno en cada zona de la region, y mandará pods a zonas distintas.

Otros comandos antes de seguir:

```shell
vim ~/.kube/config
kubectl config get-contexts
kubectl config gke_gnuescuelas_us-central1_autopilot-cluster-1
kubectl config current-context
```

Creamos una ip estática

```shell
gcloud compute addresses create web-static-ip --global --ip-version IPV4 --project gnuescuelas
gcloud compute addresses describe web-static-ip --global
gcloud compute addresses describe web-static-ip --global --format="value(address)" --project gnuescuelas
```

Deployamos, y vamos troubleshoteando

```shell
kubectl apply -f flask-deployment.yaml
kubectl apply -f nginx-deployment.yaml
kubectl get deployments

kubectl apply -f flask-service.yml
kubectl apply -f nginx-service.yml
kubectl get services
```

Controlar si anda el servicio, por ejemplo

    kubectl port-forward $(kubectl get pod --selector="app=my-flask-app" --output jsonpath='{.items[0].metadata.name}') 8080:5001

Así, un navegador apuntado a a http://localhost:8080 mostrará

Instance ID: 26aa248fd048414085abc1aa920b727a

## Ingress

No me funcionó mi ingress.yaml -y es porque cuando se hace por console.cloud.google.com, veo que cuando se hace el Ingress en modo gráfico, agrega ademas un LoadBalancer, y los enlaza.

Pero, no no veo como crear con Yaml un LoadBalancer de tipo Google. De hecho son tan propios de Google, que no se hacen con kubectl, sino con el comando gcloud... se puede ver la línea necesaria, larguisima, cuando se va a crear un Load Balancer adentro de la consola de Gcloud.

Lo que si necesita el Ingress creado por la consola, es, una vez creado por la Consola de Gcloud, y ponerle la ip externa. Ver mas abajo eso.

Resumen de las capturas de pantallas.

Kubernetes Engine → Mi cluster → Gateways, Services & Ingress

Pestaña Services, escogi UNO (no permite mas) de mis Services

- [x] my-flask-service
- [ ] nginx-service

→ Botón Create Ingress - Ver capturas de pantalla

Tras crearse, edito por dentro el Yaml y le pongo la ip que habiamos creado, una línea

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.global-static-ip-name: web-static-ip
```

y otra sección, abajo

```yaml
status:
  loadBalancer:
    ingress:
    - ip: 35.244.234.8
```

Tras hacer Save:

Controlo efectivamente:

```shell
kubectl get ingress

NAME                        CLASS    HOSTS                 ADDRESS        PORTS   AGE
ingress-for-flask-service   <none>   flask.perfeccion.ar   35.244.234.8   80      62m
```

Si quiero solo la ip, para un script:

```shell
kubectl get ingress ingress-for-flask-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

35.244.234.8
```

Actualizo Hurricane, y posiblemente, el Firewall de Gcloud

```shell
ping flask.perfeccion.ar
PING flask.perfeccion.ar (35.244.234.8) 56(84) bytes de datos.
64 bytes desde 8.234.244.35.bc.googleusercontent.com (35.244.234.8): icmp_seq=1 ttl=120 tiempo=24.7 ms
64 bytes desde 8.234.244.35.bc.googleusercontent.com (35.244.234.8): icmp_seq=2 ttl=120 tiempo=24.6 ms
```

# TODO:

> Descartado al parecer, que se pueda tener solo Ingress, sin LoadBalancer como tenemos en el Microk8s

- Ver como hacer para compartir una misma ip real y estatica, con dos virtualhost distintos, como tenemos en el Microk8s
- Que todo sea mas por código, por ejemplo
  - Crear el Load Balancer, con gcloud o con Terraform
  - Obtener su identificador
  - Poder armarle la cabecera al ingress.yml, como hace Gcloud, algo así

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/backends: '{"k8s1-6ec05096-default-my-flask-service-5001-11a7c6b0":"HEALTHY"}'
    ingress.kubernetes.io/forwarding-rule: k8s2-fr-dt561a8a-default-ingress-for-flask-service-yzqi105e
    ingress.kubernetes.io/target-proxy: k8s2-tp-dt561a8a-default-ingress-for-flask-service-yzqi105e
    ingress.kubernetes.io/url-map: k8s2-um-dt561a8a-default-ingress-for-flask-service-yzqi105e
    kubernetes.io/ingress.global-static-ip-name: web-static-ip
```

- Recrear este Ingress con https - ver ejemplos en carpeta TODO/
  - Guardo mientras los comandos vistos en la sección de Fuentes

```shell
kubectl get frontendconfig
kubectl get managedcertificates -n default
kubectl get managedcertificates.networking.gke.io
kubectl get ingressclasses.networking.k8s.io
```
