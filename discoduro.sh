#!/bin/bash

DEVICE="{physical device here. i.e /dev/sda}"
PARTITION="{partition to resize. i.e /dev/sda3}"
LV_PATH="{logical volume path here. i.e /dev/mapper/vg0-lv0}"
FS_TYPE="$(blkid -o value -s TYPE $LV_PATH)"


echo "Comenzando operación de correción de disco duro..."

# Gdisk para corregir pedillos de discos duros
echo "Ejecutando 'gdisk' en $DEVICE..."
gdisk "$DEVICE" <<EOF
v
w
Y
Y
EOF

# Informar los cambios de la table de particiones
echo "Ejecutando 'partprobe'..."
partprobe "$DEVICE"

# Borrar partición para modificar posición de tabla de bloques en nueva partición
echo "Borranding y recreanding la partición..."
fdisk "$DEVICE" <<EOF
d
3
n



w
EOF

# Informar el cambio al OS
partprobe "$DEVICE"

# Ajustar el tamaño de la particion
echo "Ajustando el tamaño del volúmen físico $PARTITION..."
pvresize "$PARTITION"

# Extender el volumen lógico para que use todo el espacio disponible
echo "Extendiendo el volúmen lógico $LV_PATH..."
lvextend -l +100%FREE "$LV_PATH"

# Informar cambios de la tabla
echo "Ejecutando 'partprobe' otra vez..."
partprobe

# Ajustar tamaño del filesystem
if [ "$FS_TYPE" == "ext4" ]; then
    echo "Ajustando el tamaño del filesystem ext4 en $LV_PATH..."
    resize2fs "$LV_PATH"
elif [ "$FS_TYPE" == "xfs" ]; then
    echo "Ajustando el filesystem con xfs en $LV_PATH..."
    xfs_growfs "$LV_PATH"
else
    echo "Filesystem no soportados: $FS_TYPE"
    exit 1
fi

echo "Reparación mamalona de discos exitosa."