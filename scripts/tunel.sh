#!/bin/bash

echo Bucle para, en caso de caidas, mantener el tunel abierto
while :
do
  # Basado en este ejemplo en Gcloud contra instancia MySQL
  # sudo ssh -i ~/.ssh/google_compute_engine -4 -f -o StrictHostKeyChecking=no -L 3307:10.159.32.3:3306 -l victor.martinez 34.86.49.246 sleep 1000000000
  # Agregar -v para troubleshotear
  echo - gero@bunker4.perfeccion.ar será el usuario gero, sin privilegios, en el container 103 - bastión
  echo - 10224 no se cambia, es el nat de nat: Modem Movistar → Proxmox → Container Bastion:22
  echo - 50000 es el puerto en la maquina local. Por cada tunel nuevo, cambiar este valor.
  echo   Nota: este valor requiere sudo si es menor a 1024 
  echo - 10.10.153.2 es el endpoint final, el container 100 de prueba testvlan3
  echo   Ese container tendrá su propio usuario, ejemplo, prueba, con privilegios
  echo   Las ip de los demas containers están detallados en red proxmox.drawio de 
  echo   https://gitlab.com/bunker4/infraestructura-clasica
  echo - :22 es el puerto final al que se desea llegar. No hace falta forzosamente que sea ssh
  echo   Puede ser tambien MySQL 3306, ftp 21, kubernetes 443, etc
  echo
  echo Modo de uso: 
  echo "Este script pedirá el password del Bastión (ejemplo, gero ), y si anda bien, no hará mas nada"
  echo En otra ventana debe conectar al endpoint, usando el segundo usuario, prueba, ejemplo
  echo ssh -v -p 50000 prueba@localhost
  echo 
  echo Para no poner tantos password, se recomienda agregar la llave publica en ambos servidores
  echo
  echo "Abriendo tunel, presione [CTRL+C] para reiniciarlo"
  ssh gero@bunker4.perfeccion.ar -nN -p 10224 -L127.0.0.1:50000:10.10.153.2:22 sleep 3600
	echo "Reiniciando tunel"
	sleep 1
done
