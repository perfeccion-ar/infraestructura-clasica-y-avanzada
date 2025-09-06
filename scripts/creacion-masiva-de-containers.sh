#!/bin/bash

# Este script crea 30 containers para estudiantes

# List container names (assuming they're running; filter with --format csv -c ns for name and status if needed)
# containers=$(lxc list --format csv -c n)

# for container in $containers; do


# Define array of container names from padawan02 to padawan30
containers=()
for i in $(seq -f "%02g" 2 30); do
  containers+=("padawan$i")
done

# Debug: Print the array to verify contents
echo "Containers in array: ${containers[@]}"

# Loop through the array and run commands in each container
for container in "${containers[@]}"; do
  lxc launch images:debian/13/cloud $container
  lxc config set $container limits.memory 2GiB
  zfs set reservation=9G zfspool/containers/$container
  zfs set quota=9G zfspool/containers/$container
  # lxc config device add $container port-ssh proxy listen=tcp:0.0.0.0:2201 connect=tcp:127.0.0.1:22

  echo "Running command in container: $container"
  lxc exec "$container" -- apt update  # Replace 'apt update' with your command, e.g., '/path/to/your/config-script.sh'
  lxc exec "$container" -- apt dist-upgrade -y  # Replace 'apt update' with your command, e.g., '/path/to/your/config-script.sh'
  lxc exec "$container" --  apt install mc vim ncdu pydf jq nmap -y
  lxc exec "$container" --  adduser padawan
  lxc exec "$container" --  adduser padawan sudo
  
  echo "Finished in $container"
done

# Asignación masiva de puertos ssh
# lxc config device add $container port-ssh proxy listen=tcp:0.0.0.0:2201 connect=tcp:127.0.0.1:22

for i in {01..30}
do
  lxc config device add padawan$i port-ssh proxy listen=tcp:0.0.0.0:22$i connect=tcp:127.0.0.1:22
done
