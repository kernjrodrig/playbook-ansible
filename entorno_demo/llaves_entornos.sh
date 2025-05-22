#!/bin/bash

# Lista de IPs y contraseñas
declare -A hosts=(

["rocky1"]="lepanto"
["rocky2"]="lepanto"
["rocky3"]="lepanto"
["rocky4"]="lepanto"
["rocky5"]="lepanto"
["rocky6"]="lepanto"
#["192.168.10.77"]="root00"
#["192.168.10.78"]="root00"

)



# Ruta de la llave SSH
SSH_KEY="$HOME/.ssh/id_rsa"

# Generar un par de llaves SSH si no existe
if [ ! -f "$SSH_KEY" ]; then
    ssh-keygen -t rsa -b 2048 -f "$SSH_KEY" -N ""
fi

# Iterar sobre los hosts y copiar la llave pública
for host in "${!hosts[@]}"; do
    password=${hosts[$host]}
    echo "Copiando llave SSH a $host"

    # Copiar la llave pública usando sshpass
    sshpass -p "$password" ssh-copy-id -o StrictHostKeyChecking=no root@"$host"

    if [ $? -eq 0 ]; then
        echo "Llave SSH copiada exitosamente a $host"
    else
        echo "Error copiando la llave SSH a $host"
    fi
done
