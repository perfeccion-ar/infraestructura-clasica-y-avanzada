Mecanismo para mantener actualizado los links que alimentan NotebookLM

Clonar en una carpeta nueva

    git clone https://github.com/perfeccion-ar/infraestructura-clasica-y-avanzada.git
    git clone https://github.com/perfeccion-ar/infraestructura-clasica-y-avanzada.wiki.git

Correr este python

    python generador-de-enlaces-para-alimentar-notebooklm.py > enlaces-para-notebooklm.txt

TODO: automatizar lo siguiente

Como son muchas urls, nos quedamos solo con las nuestras

    cat enlaces-para-notebooklm.txt| grep "pancutan\|perfeccion" > enlaces-para-notebooklm2.txt

Limpiar de ese archivo estos caracteres, con vim (:) en esta secuencia

```
%s/Enlaces encontrados://gc
%s/`//gc
%s/,$//gc
%s/">//gc
%s/"//gc
```

Sacar links a archivos con extensión .excalidraw

Todavia hay muchos urls repetidas con anchors y ?variables al final.
Llevar el resultante a Copilot o a alguna IA generosa en tamaño de prompts, y pedirle que
elimine todas las lineas duplicadas

Insertar en https://notebooklm.google.com

Al 15/11/2025, este es el notebook actualizado https://notebooklm.google.com/notebook/c085cbe0-3e0c-4237-ba5a-8817ae6635af
