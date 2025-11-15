# Crear un clúster y desplegar una carga de trabajo con Terraform

Versión *corregida* de https://docs.cloud.google.com/kubernetes-engine/docs/quickstarts/create-cluster-using-terraform?hl=es#local-shell

Como ya dijimos en el otro proyecto, para correr este proyecto no hace falta mucha potencia: se puede correr instalando kubectl y gcloud-cli en la compu, o simplemente activando una Shell en [la barra de arriba de ](https://console.cloud.google.com/)

Dinero necesario: hay que tener una tarjeta con unos pocos dolares, activada en la sección de Billing. Lo norma:

- Cuidar los créditos de regalo
- Utilizar el modo Autopilot, y destruir (terraform destroy) tras probar.
- Tratar de tener lo más posible por código, cuestión de retomar fácilmente la enseñanza al otro día.

Siguiendo estos consejos, se debería gastar solo unos pocos centavos de dólar. Tener a mano https://cloud.google.com/kubernetes-engine/pricing?hl=es

    gcloud auth login
    gcloud config set project escuelita-automation

Activar algunas APIs. Para habilitar APIs, hay que tener el rol "Service Usage Admin IAM role" (roles/serviceusage.serviceUsageAdmin), que contiene el permiso `serviceusage.services.enable permission`

Los siguientes permisos se pueden activar también accediendo a http://console.cloud.google.com, mirando primero en https://docs.cloud.google.com/iam/docs/granting-changing-revoking-access?hl=es

    gcloud services enable container.googleapis.com

Otorgar roles a mi cuenta de usuario: roles/container.admin, roles/compute.networkAdmin, roles/iam.serviceAccountUser

    gcloud projects add-iam-policy-binding escuelita-automation --member user:sergio@eim.esc.edu.ar --role=roles/gkemulticloud.admin

Conviene ir **a otra carpeta** que no sea este repositorio, y clonar este proyecto

    git clone https://github.com/terraform-google-modules/terraform-docs-samples.git --single-branch

Este proyecto, obtenido en https://github.com/terraform-google-modules/terraform-docs-samples, tiene carpetas con librerías escritas en HCL (HashiCorp Configuration Language). Lo que buscan es facilitar escribir código para que el comando terraform pueda crear toda clase de infraestructura en Gcloud: instancias SQL, VMs, redes VPC, etc.

Entramos a esta carpeta


Entramos a la carpeta gke/autopilot/ - alí hay varias subcarpetas que serán llamadas por nuestro manifiesto en HCL:

```shell
drwxr-xr-x 2 s s 4096 nov  1 18:23 basic
drwxr-xr-x 4 s s 4096 nov  1 18:23 config_sync
drwxr-xr-x 2 s s 4096 nov  1 18:23 custom_service_account
drwxr-xr-x 2 s s 4096 nov  1 18:23 iap
drwxr-xr-x 2 s s 4096 nov  1 18:23 labels
drwxr-xr-x 2 s s 4096 nov  1 18:23 mesh
drwxr-xr-x 2 s s 4096 nov  1 18:23 policycontroller
drwxr-xr-x 2 s s 4096 nov  1 18:23 release_channel
drwxr-xr-x 2 s s 4096 nov  1 18:23 reservation
drwxr-xr-x 2 s s 4096 nov  1 18:23 tag
```

Para que Terraform trabaje, necesita un Provider, del tipo de infraestructura sobre la cual estemos trabajando: Gcloud, Azure, AWS, Digital Ocean, etc, incluso Proxmox. Esta carpeta sería una implementación ya lista, para no tener que ir nosotros mismos a buscar el provider para Gcloud que está en https://registry.terraform.io/providers/hashicorp/google/latest/docs. Estrictamente hablando, es una versión simplificada de https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster, donde hay que ir si este proyecto falla.

Cito (1 nov 2025), del link de guía que usamos, https://docs.cloud.google.com/kubernetes-engine/docs/quickstarts/create-cluster-using-terraform?hl=es#local-shell

"El [Google Cloud proveedor](https://registry.terraform.io/providers/hashicorp/google/latest/docs) es un complemento que te permite gestionar y aprovisionar Google Cloud recursos con Terraform. Actúa como **puente entre las configuraciones de Terraform y las APIs de Google Cloud**, lo que te permite definir de forma declarativa recursos de infraestructura, como máquinas virtuales y redes.

El clúster y la aplicación de ejemplo de este tutorial se especifican en dos archivos de Terraform que usan los proveedores Google Cloud y Kubernetes".

Si se trabaja en Visual Code Editor, instalar el plugin "HashiCorp Terraform", así nos ayuda con la sintaxis de este archivo

## cluster.tf

**En la carpeta `gke/autopilot` donde clonamos https://github.com/terraform-google-modules/terraform-docs-samples.git**, ponemos el archivo `cluster.tf` de este repositorio, que acompaña a este `README.md`.

En mi caso, lo copiaría a `~/Downloads/terraform-docs-samples/gke/autopilot`

 - Si se abre y se observa, se podrá ver que `cluster.tf` creará los siguientes recursos en el cloud:

- Una red de VPC, activando un recurso de tipo *google_compute_network*
- Una subred IPv4/IPv6 ("doble pila") de tipo google_compute_subnetwork
- Un clúster Kubernetes GKE, en modo *Autopilot*, que es un recurso de tipo google_container_cluster, y lo ubicará en *us-central1* (normalmente, la región ms vieja y barata).
- El ajuste `deletion_protection` controla si puedes usar Terraform para eliminar este clúster. Con `false`, podremos destruir lo que hemos hecho, fácilmente, con el comando `terraform destroy`.

> Esto es una gran ventaja, respecto del proyecto anterior ("cloudguru modificado"), donde tenemos que revisar minuciosamente cada cosa que la console.cloud.google.com ha creado automagicamente por nosotros.

A este archivo, le cambiamos esta linea, de INTERNAL a EXTERNAL

    ipv6_access_type = "INTERNAL" # Change to "EXTERNAL" if creating an external loadbalancer

## Desplegar cluster.tf

Antes de desplegar, probamos los siguientes comandos

    terraform init
    export GOOGLE_PROJECT="escuelita-automation"  # O, su proyecto
    terraform plan

Si no tenemos errores, hacemos

    terraform apply

Como se puede ver, antes de arrancar, Terraform nos pedirá confirmación. Y lo mas interesante son las expresiones "known after apply".

Estas son variables, que esencialmente se pueblan con aquellos valores que nosotros obtendriamos tras correr de un lado a oto creando manualmente las cosas, y enlazandolas a mano. Ejemplo:

```shell
Terraform will perform the following actions:

  # google_compute_network.default will be created
  + resource "google_compute_network" "default" {
      + auto_create_subnetworks                   = false
      + bgp_always_compare_med                    = (known after apply)
      + bgp_best_path_selection_mode              = (known after apply)
      + bgp_inter_region_cost                     = (known after apply)
      + delete_default_routes_on_create           = false
      + enable_ula_internal_ipv6                  = true
      + gateway_ipv4                              = (known after apply)
      + id                                        = (known after apply)
      + internal_ipv6_range                       = (known after apply)
      + mtu                                       = (known after apply)
      + name                                      = "example-network"
      + network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
      + network_id                                = (known after apply)
      + numeric_id                                = (known after apply)
      + project                                   = "escuelita-automation"
      + routing_mode                              = (known after apply)
      + self_link                                 = (known after apply)

      (etc)
    }
```

Cuando termine de aplicar, vamos a https://console.cloud.google.com/kubernetes

Es un buen momento para alimentar nuestro ~/.kube/config, entrando al cluster.
Allí en la opción **Conectar** obtendremos una línea tipo

    gcloud container clusters get-credentials example-autopilot-cluster --region us-central1 --project escuelita-automation

Nos fijamos si estamos apuntando al cluster correcto...

    kubectl config current-context
    → gke_escuelita-automation_us-central1_example-autopilot-cluster

    kubectl get ns
    kubectl get nodes

Si no aparecen nodos, es porque todavía no hemos desplegado (Workload) ninguna cosa. Precisamente esa es la gracia de Autopilot, no tener que reservar nodos, que es en lo que en definitiva es mas caro (VMs o "Computing"). Ademas hay que recordar que se nos cobra por Nodo, red, buckets, etc, pero no por el Master que hemos puesto a correr.

## app.tf

Técnicamente ya podríamos correr con `kubectl -f` nuestros manifiestos.

Pero si queremos **ya mismo** desplegar algo, podemos usar una receta de Helm, o la siguiente receta de Terraform que dejamos aquí lista, en el archivo app.tf

En el app.tf aquí provisto, y para dejar con acceso externo al balanceador, comentamos estas lineas

```hcl
annotations = {
   "networking.gke.io/load-balancer-type" = "Internal" # Remove this line
 }
```

Copiamos app.tf adonde está habíamos clonado https://github.com/terraform-google-modules/terraform-docs-samples.git

Y junto al cluster.tf que ya tenemos, nuevamente corremos

    terraform apply

Para verlo desplegado, tenemos dos opciones, yendo a

-  https://console.cloud.google.com/kubernetes/workload
-  https://console.cloud.google.com/kubernetes/gateways

O con `kubectl`:

```shell
[s@bebop] ~/Downloads/terraform-docs-samples/gke/autopilot (main) ⚡
❯ kubectl get deployments
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
example-hello-app-deployment   1/1     1            1           16m

[s@bebop] ~/Downloads/terraform-docs-samples/gke/autopilot (main) ⚡
❯ kubectl get services
NAME                             TYPE           CLUSTER-IP      EXTERNAL-IP                                  PORT(S)        AGE
example-hello-app-loadbalancer   LoadBalancer   192.168.0.235   2600:1900:4001:407:8000:0:0:0,34.70.230.59   80:31105/TCP   14m
kubernetes                       ClusterIP      192.168.0.1     <none>                                       443/TCP        34m
```

Como se puede ver, esta es la ip asignada: http://34.70.230.59

## Destruir

No olvidemos correr `terraform destroy` para limpiar el experimento y que no se sigan generando costos.

# TODO

- Desplegar otros manifiestos
- Desplegar con https
- Asignar una ip estática, como en el proyecto anterior
- Si agregamos mas LoadBalancers, y los apuntamos a otras **cargas de trabajo** (service + deployment), podemos apuntar mas dominios
  - Pero mas LoadBalancers implica contratar mas ips externas.
  - De modo que sería interesante instalar un Ingress, que es un Router inteligente, un "proxy Forward" capaz de manejar Virtualhosts
  - Así, con una sola IP, como en todo servidor web con capacidad de manejar "VirtualHosts", podamos servir dominios **distintos** en **distintas** cargas de trabajo.
