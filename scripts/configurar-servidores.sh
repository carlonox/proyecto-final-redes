#!/bin/bash
# Configurar servidores - Proyecto Final Redes
# Uso: DISK_PATH=/data/imagenes/QEMU/Servers bash configurar-servidores.sh
# Por defecto: DISK_PATH=/tmp
DISK_PATH="${DISK_PATH:-/tmp}"

# Ejecutar: bash configurar-servidores.sh
# 
# Para Docker: export DISK_PATH=/data/imagenes/QEMU/Servers
# Para nativo: export DISK_PATH=/tmp  (por defecto)


echo "=== Configurando SRV_DNS_Bog (10.1.0.5) ==="
sudo virt-customize -a $DISK_PATH/srv-dns-bog.qcow2 \
  --run-command 'cat > /etc/netplan/01-netcfg.yaml << NETEOF
network:
  version: 2
  ethernets:
    ens3:
      dhcp4: no
      addresses: [10.1.0.5/24]
      gateway4: 10.1.0.1
      nameservers:
        addresses: [8.8.8.8]
NETEOF
netplan generate' 2>&1 | tail -2

echo "=== Configurando SRV_WEB_Cuc (10.2.0.5) ==="
sudo virt-customize -a $DISK_PATH/srv-web-cuc.qcow2 \
  --run-command 'cat > /etc/netplan/01-netcfg.yaml << NETEOF
network:
  version: 2
  ethernets:
    ens3:
      dhcp4: no
      addresses: [10.2.0.5/24]
      gateway4: 10.2.0.1
      nameservers:
        addresses: [8.8.8.8]
NETEOF
netplan generate' 2>&1 | tail -2

echo "=== Configurando SRV_LDAP_SM (10.3.0.5) ==="
sudo virt-customize -a $DISK_PATH/srv-ldap-sm.qcow2 \
  --run-command 'cat > /etc/netplan/01-netcfg.yaml << NETEOF
network:
  version: 2
  ethernets:
    ens3:
      dhcp4: no
      addresses: [10.3.0.5/24]
      gateway4: 10.3.0.1
      nameservers:
        addresses: [8.8.8.8]
NETEOF
netplan generate' 2>&1 | tail -2

echo "=== Configurando SRV_LDAP_Bar (10.4.0.5) ==="
sudo virt-customize -a $DISK_PATH/srv-ldap-bar.qcow2 \
  --run-command 'cat > /etc/netplan/01-netcfg.yaml << NETEOF
network:
  version: 2
  ethernets:
    ens3:
      dhcp4: no
      addresses: [10.4.0.5/24]
      gateway4: 10.4.0.1
      nameservers:
        addresses: [8.8.8.8]
NETEOF
netplan generate' 2>&1 | tail -2

echo ""
echo "=== Listo! Ahora copia los discos a GNS3 ==="
sudo cp $DISK_PATH/srv-dns-bog.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-dns-bog.qcow2
sudo cp $DISK_PATH/srv-web-cuc.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-web-cuc.qcow2
sudo cp $DISK_PATH/srv-ldap-sm.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-ldap-sm.qcow2
sudo cp $DISK_PATH/srv-ldap-bar.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-ldap-bar.qcow2
sudo chown -R carlonox:carlonox /home/carlonox/GNS3/images/QEMU/Servers
echo "Discos copiados a GNS3"
