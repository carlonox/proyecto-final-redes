#!/bin/bash
# Configurar servidores - Proyecto Final Redes
# Uso: DISK_PATH=/data/imagenes/QEMU/Servers bash configurar-servidores.sh
# Por defecto: DISK_PATH=/tmp
DISK_PATH="${DISK_PATH:-/tmp}"

# Ejecutar: bash configurar-servicios.sh

echo "=== 1. DNS: zonas en SRV_DNS_Bog ==="
sudo virt-customize -a $DISK_PATH/srv-dns-bog.qcow2 --run-command '
cat > /etc/bind/named.conf.local << EOF
zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
};
zone "0.1.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.1.0";
};
EOF

cat > /etc/bind/db.empresa.local << EOF
\$TTL 604800
@ IN SOA srv-dns-bog.empresa.local. admin.empresa.local. (
    1 ; Serial
    604800 ; Refresh
    86400 ; Retry
    2419200 ; Expire
    604000 ) ; Negative Cache TTL
;
@ IN NS srv-dns-bog.empresa.local.
@ IN A 10.1.0.5
srv-dns-bog IN A 10.1.0.5
srv-web-cuc IN A 10.2.0.5
srv-ldap-sm IN A 10.3.0.5
srv-ldap-bar IN A 10.4.0.5
www IN CNAME srv-web-cuc.empresa.local.
EOF

cat > /etc/bind/db.10.1.0 << EOF
\$TTL 604800
@ IN SOA srv-dns-bog.empresa.local. admin.empresa.local. ( 1 604800 86400 2419200 604000 )
@ IN NS srv-dns-bog.empresa.local.
5 IN PTR srv-dns-bog.empresa.local.
EOF

systemctl enable bind9
' 2>&1 | tail -2

echo "=== 2. DHCP en SRV_DNS_Bog ==="
sudo virt-customize -a $DISK_PATH/srv-dns-bog.qcow2 --run-command '
cat > /etc/dhcp/dhcpd.conf << EOF
subnet 10.1.0.0 netmask 255.255.255.0 {
    range 10.1.0.100 10.1.0.200;
    option routers 10.1.0.1;
    option domain-name-servers 10.1.0.5;
    option domain-name "empresa.local";
    default-lease-time 86400;
    max-lease-time 172800;
}
EOF
systemctl enable isc-dhcp-server
' 2>&1 | tail -2

echo "=== 3. WEB + FTP en SRV_WEB_Cuc ==="
sudo virt-customize -a $DISK_PATH/srv-web-cuc.qcow2 --run-command '
mkdir -p /var/www/html/empresa
cat > /var/www/html/empresa/index.html << EOF
<html><body>
<h1>Bienvenido a la Red Corporativa</h1>
<p>Servidor WEB - Cucuta</p>
<p>Proyecto Final Redes de Computadores 2026-1</p>
</body></html>
EOF

cat > /etc/apache2/sites-available/empresa.conf << EOF
<VirtualHost *:80>
    ServerName www.empresa.local
    DocumentRoot /var/www/html/empresa
</VirtualHost>
EOF
a2ensite empresa.conf
systemctl enable apache2

cat > /etc/vsftpd.conf << EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
EOF
systemctl enable vsftpd
' 2>&1 | tail -2

echo "=== 4. LDAP en SRV_LDAP_SM + SRV_LDAP_Bar ==="
sudo virt-customize -a $DISK_PATH/srv-ldap-sm.qcow2 --run-command '
cat > $DISK_PATH/base.ldif << EOF
dn: dc=empresa,dc=local
objectClass: top
objectClass: dcObject
objectClass: organization
o: Empresa
dc: empresa

dn: ou=Usuarios,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Usuarios

dn: ou=Grupos,dc=empresa,dc=local
objectClass: organizationalUnit
ou: Grupos

dn: cn=admin,dc=empresa,dc=local
objectClass: organizationalRole
cn: admin
description: Administrador LDAP
EOF
sleep 2
' 2>&1 | tail -2

sudo virt-customize -a $DISK_PATH/srv-ldap-bar.qcow2 --run-command 'systemctl enable ssh' 2>&1 | tail -2

echo "=== 5. Copiando discos a GNS3 ==="
sudo cp $DISK_PATH/srv-dns-bog.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-dns-bog.qcow2
sudo cp $DISK_PATH/srv-web-cuc.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-web-cuc.qcow2
sudo cp $DISK_PATH/srv-ldap-sm.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-ldap-sm.qcow2
sudo cp $DISK_PATH/srv-ldap-bar.qcow2 /home/carlonox/GNS3/images/QEMU/Servers/srv-ldap-bar.qcow2
sudo chown -R carlonox:carlonox /home/carlonox/GNS3/images/QEMU/Servers

echo ""
echo "=== SERVICIOS CONFIGURADOS ==="
echo "DNS + DHCP en SRV_DNS_Bog (10.1.0.5)"
echo "WEB + FTP en SRV_WEB_Cuc (10.2.0.5)"
echo "LDAP en SRV_LDAP_SM (10.3.0.5)"
echo "SSH en SRV_LDAP_Bar (10.4.0.5)"
