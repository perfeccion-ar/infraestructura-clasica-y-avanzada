Chart used: https://artifacthub.io/packages/helm/kubitodev/excalidraw

Steps made:

1. `helm repo add kubitodev https://charts.kubito.dev`
2. Valores por defecto modificados, del archivo values-excalidraw.yaml

```yaml
service:
  type: ClusterIP
  port: 80
  nodePort: ""

ingress:
  hosts:
    - host: excalidraw.perfeccion.ar
```

3. Lanzado con

    helm install excalidraw -f values-excalidraw.yaml kubitodev/excalidraw

Output:

```shell
NAME: excalidraw
LAST DEPLOYED: Sun Aug 10 23:18:27 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

4. Creado registro A en https://dns.he.net apuntando a la ip externa del Proxmox
5. Nginx Proxy Manager, Proxy hacia la ip de la VM con Microk8s :80, con estos custom values:

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

