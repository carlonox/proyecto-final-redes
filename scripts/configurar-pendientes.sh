#!/bin/bash
# Configurar servidores - Proyecto Final Redes
# Uso: DISK_PATH=/data/imagenes/QEMU/Servers bash configurar-servidores.sh
# Por defecto: DISK_PATH=/tmp
DISK_PATH="${DISK_PATH:-/tmp}"

# Ejecutar: sudo bash configurar-pendientes.sh

set -e

echo "=========================================="
echo "1. INSTALANDO CUPS (IMPRESION) EN SM"
echo "=========================================="
sudo virt-customize -a $DISK_PATH/srv-ldap-sm.qcow2 --install cups 2>&1 | tail -3

echo ""
echo "=========================================="
echo "2. CONFIGURANDO ESTRUCTURA LDAP BASICA"
echo "=========================================="
sudo virt-customize -a $DISK_PATH/srv-ldap-sm.qcow2 --run-command '
mkdir -p /etc/ldap/content
cat > /etc/ldap/content/base.ldif << LDIF
dn: dc=empresa,dc=local
objectClass: top
objectClass: dcObject
objectClass: organization
o: Red Corporativa
dc: empresa

dn: ou=Bogota,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Bogota

dn: ou=Cucuta,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Cucuta

dn: ou=SantaMarta,dc=empresa,dc=local
objectClass: organizationalUnit
ou: SantaMarta

dn: ou=Barranquilla,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Barranquilla

dn: cn=admin,dc=empresa,dc=local
objectClass: organizationalRole
cn: admin
description: Administrador LDAP
LDIF

# Configurar slapd por primera vez
cat > $DISK_PATH/slapd-debconf << EOF
slapd slapd/password1 password admin
slapd slapd/password2 password admin
slapd slapd/domain string empresa.local
slapd slapd/organization string Empresa
EOF

DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive slapd < $DISK_PATH/slapd-debconf 2>/dev/null || true
' 2>&1 | tail -3

sudo virt-customize -a $DISK_PATH/srv-ldap-bar.qcow2 --run-command '
mkdir -p /etc/ldap/content
cat > /etc/ldap/content/base.ldif << LDIF
dn: dc=empresa,dc=local
objectClass: top
objectClass: dcObject
objectClass: organization
o: Red Corporativa
dc: empresa

dn: ou=Bogota,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Bogota

dn: ou=Cucuta,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Cucuta

dn: ou=SantaMarta,dc=empresa,dc=local
objectClass: organizationalUnit
ou: SantaMarta

dn: ou=Barranquilla,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Barranquilla

dn: cn=admin,dc=empresa,dc=local
objectClass: organizationalRole
cn: admin
description: Administrador LDAP
LDIF
' 2>&1 | tail -3

echo ""
echo "=========================================="
echo "3. ACTUALIZANDO DISCOS EN GNS3"
echo "=========================================="
sudo cp $DISK_PATH/srv-ldap-sm.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-ldap-sm.qcow2
sudo cp $DISK_PATH/srv-ldap-bar.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-ldap-bar.qcow2
sudo chown carlonox:carlonox /home/carlonox/GNS3/images/QEMU/Servers/*.qcow2

echo ""
echo "=========================================="
echo "COMPLETADO! Por favor reinicia los servidores en GNS3"
echo "=========================================="
