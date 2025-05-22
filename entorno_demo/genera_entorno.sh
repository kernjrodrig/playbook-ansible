#!/bin/bash

# Variables configurables
NETWORK_NAME="ansible"
SUBNET="172.18.0.0/16"
IMAGES=(
#    "apasoft/debian11-ansible"
    "apasoft/rocky9-ansible"
#    "apasoft/ubuntu22-ansible"
)
CONTAINERS=(
#    "rocky1:172.18.0.2:${IMAGES[0]}"
    "rocky2:172.18.0.3:${IMAGES[0]}"
    "rocky3:172.18.0.5:${IMAGES[0]}"
    "rocky4:172.18.0.6:${IMAGES[0]}"
#    "rocky5:172.18.0.8:${IMAGES[0]}"
#    "rocky6:172.18.0.10:${IMAGES[0]}"
)

###################################
# Eliminar contenedores
###################################
echo "Eliminando contenedores existentes..."
for container in "${CONTAINERS[@]}"; do
    NAME=$(echo "$container" | cut -d':' -f1)
    podman rm -f "$NAME" 2>/dev/null || echo "Contenedor $NAME no existe o ya fue eliminado."
done

###################################
# Eliminar la red
###################################
echo "Eliminando red existente..."
podman network rm "$NETWORK_NAME" 2>/dev/null || echo "La red $NETWORK_NAME no existe o ya fue eliminada."

###################################
# Crear la red
###################################
echo "Creando red $NETWORK_NAME con subred $SUBNET..."
podman network create "$NETWORK_NAME" --subnet="$SUBNET"

###################################
# Crear y arrancar contenedores
###################################
echo "Creando y arrancando contenedores..."
for container in "${CONTAINERS[@]}"; do
    NAME=$(echo "$container" | cut -d':' -f1)
    IP=$(echo "$container" | cut -d':' -f2)
    IMAGE=$(echo "$container" | cut -d':' -f3)

    podman run --detach \
        --privileged \
        --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
        --ip "$IP" \
        --cgroupns=host \
        --name "$NAME" \
        --network "$NETWORK_NAME" \
        "$IMAGE"
    echo "Contenedor $NAME creado con IP $IP."
done

echo "Proceso completado."

