# Ubuntu Mate Desktop, accessible via navegador 

Escritorio completo servido bajo Docker sin necesidad de máquina virtual, X11 Forwarding, VNC, NX, etc.

Usa Mate Desktop como window Manager. Ya tiene VSCode y Chromium Browser.

Proyecto original: https://docs.linuxserver.io/images/docker-webtop/#supported-architectures

Traido al grupo de aprendizaje Bunker 4 por

- [Nahuel Palacio](https://github.com/PNahuel5588) - ver video en https://www.youtube.com/watch?v=ZHIgO-OL4xg
- Anibal Rivero (Sensar.nl)

Ideal para 

- Montarlo en una VPS, o en el Proxmox del aula.
- Permite acceder a recursos pesados de servidor remoto (GPU, puntos de montaje local, datasets mnuy grandes)
- Brindar a alumnos un escritorio completo de trabajo, sin necesidad que instalen Linux en máquinas limitadas.

Relacionado: [más trucos para tener un escritorio liviano, remoto](https://github.com/perfeccion-ar/infraestructura-clasica-y-avanzada/wiki/Escritorios-livianos)

![Webtop-Ubuntu-Mate](docker-webtop-ubuntu-mate.png)

## Minimal instructions by Anibal

- Copy `env.example` to `.env`
- Edit the values in `.env`
- Run `docker compose up -d && docker compose logs -f`
- Access it with 
  - `https://localhost:3001`
  - or `http://localhost:3000`
- Optional, if you are inside a container, forward from router ports 3000 and 3001

