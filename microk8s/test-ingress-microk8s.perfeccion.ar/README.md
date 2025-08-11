## Requerimientos

En el NGINX Proxy Manager: Configuración de Proxy Host

Click en `Add Proxy Host`

2. Tab Details:

- Domain Names: app1.perfeccion.ar
- Scheme: http
- Forward Hostname / IP: IP privada de tu VM con microk8s, por ejemplo 10.10.152.2
- Forward Port: 80
- Check "Block common exploits"
- Check "Websockets support"

3. Advanced tab:

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

4. Repetir para app2.perfeccion.ar

## TODO

Tab SSL: 

- Check "Force SSL"
- Enable SSL Certificate (Let's Encrypt) ✔

## Troubleshooting

NPM must forward real Host: headers, not override them. It's critical for Ingress matching.

In NPM, go to the Advanced tab of the Proxy Host and ensure this is NOT set:

    proxy_set_header Host $proxy_host;

Instead, allow:

    proxy_set_header Host $host;

You can use a single Ingress resource with multiple rules, or separate ones per app.

Don’t enable SSL on the Ingress, unless you're doing TLS pass-through or termination inside the cluster. In this setup, only NPM handles TLS.

✅ Bonus: Troubleshooting Tips

Use `kubectl describe ingress <name>` to confirm routing.

Use `kubectl get svc and kubectl get pods -o wide` to confirm services and endpoints.

From within your NPM host, use:

    curl -H "Host: app1.perfeccion.ar" http://your.ingress.ip/
