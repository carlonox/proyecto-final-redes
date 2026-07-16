#!/bin/bash
# ===========================================
# configurar-servicios-total.sh
# Ejecutar DENTRO del container GNS3 para
# configurar IPs y servicios en las 4 QCOW2
# ===========================================
set -e

DISK_PATH="/data/imagenes/QEMU/Servers"
SCRIPT_DIR="/scripts"

echo "============================================"
echo " Configuración de Servidores - Proyecto Final"
echo "============================================"
echo ""

# Verificar herramientas
echo "🔧 Verificando herramientas..."
command -v virt-customize >/dev/null 2>&1 || { echo "❌ virt-customize no encontrado"; exit 1; }
echo "  ✅ virt-customize disponible"
echo ""

# Verificar que los discos existen
echo "💾 Verificando discos..."
for disk in srv-dns-bog srv-web-cuc srv-ldap-sm srv-ldap-bar; do
    if [ -f "$DISK_PATH/$disk.qcow2" ]; then
        size=$(du -h "$DISK_PATH/$disk.qcow2" | cut -f1)
        echo "  ✅ $disk.qcow2 ($size)"
    else
        echo "  ❌ $disk.qcow2 NO ENCONTRADO en $DISK_PATH"
        exit 1
    fi
done
echo ""

# ============================================
# PASO 1: Configurar IPs en servidores
# ============================================
echo "============================================"
echo " PASO 1/4: Configurando IPs estáticas"
echo "============================================"

config_ip() {
    local disk=$1 ip=$2 gw=$3
    echo ""
    echo "→ $disk ($ip/$gw)"
    virt-customize -a $DISK_PATH/$disk.qcow2 \
        --run-command "cat > /etc/netplan/01-netcfg.yaml << 'NETEOF'
network:
  version: 2
  ethernets:
    ens3:
      dhcp4: no
      addresses: [$ip/24]
      routes:
        - to: default
          via: $gw
      nameservers:
        addresses: [10.1.0.5, 8.8.8.8]
NETEOF
netplan generate" 2>&1 | tail -1
}

config_ip "srv-dns-bog" "10.1.0.5" "10.1.0.1"
config_ip "srv-web-cuc" "10.2.0.5" "10.2.0.1"
config_ip "srv-ldap-sm" "10.3.0.5" "10.3.0.1"
config_ip "srv-ldap-bar" "10.4.0.5" "10.4.0.1"

echo ""
echo "✅ IPs configuradas"
echo ""

# ============================================
# PASO 2: DNS + DHCP
# ============================================
echo "============================================"
echo " PASO 2/4: DNS (BIND9) + DHCP"
echo "============================================"

virt-customize -a $DISK_PATH/srv-dns-bog.qcow2 --run-command '
# === DNS: named.conf.local ===
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

# === DNS: zona directa ===
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

# === DNS: zona inversa ===
cat > /etc/bind/db.10.1.0 << EOF
\$TTL 604800
@ IN SOA srv-dns-bog.empresa.local. admin.empresa.local. ( 1 604800 86400 2419200 604000 )
@ IN NS srv-dns-bog.empresa.local.
5 IN PTR srv-dns-bog.empresa.local.
EOF

# === DHCP ===
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

# Habilitar servicios
systemctl enable bind9 2>/dev/null || true
systemctl enable isc-dhcp-server 2>/dev/null || true
' 2>&1 | tail -2

echo "✅ DNS + DHCP configurados"
echo ""

# ============================================
# PASO 3: WEB + FTP
# ============================================
echo "============================================"
echo " PASO 3/4: WEB (Apache) + FTP (vsftpd)"
echo "============================================"

virt-customize -a $DISK_PATH/srv-web-cuc.qcow2 --run-command '
# === WEB: página ===
mkdir -p /var/www/html/empresa
cat > /var/www/html/empresa/index.html << EOF
<html><body>
<h1>Bienvenido a la Red Corporativa</h1>
<p>Servidor WEB - Cucuta</p>
<p>Proyecto Final Redes de Computadores 2026-1</p>
<p><em>Universidad Nacional de Colombia</em></p>
</body></html>
EOF

# === WEB: VirtualHost ===
cat > /etc/apache2/sites-available/empresa.conf << EOF
<VirtualHost *:80>
    ServerName www.empresa.local
    ServerAdmin admin@empresa.local
    DocumentRoot /var/www/html/empresa
    ErrorLog \${APACHE_LOG_DIR}/empresa-error.log
    CustomLog \${APACHE_LOG_DIR}/empresa-access.log combined
</VirtualHost>
EOF
a2ensite empresa.conf 2>/dev/null

# === FTP ===
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

# Habilitar
systemctl enable apache2 2>/dev/null || true
systemctl enable vsftpd 2>/dev/null || true
' 2>&1 | tail -2

echo "✅ WEB + FTP configurados"
echo ""

# ============================================
# PASO 4: LDAP + CUPS + SSH
# ============================================
echo "============================================"
echo " PASO 4/4: LDAP + CUPS + SSH"
echo "============================================"

# SRV_LDAP_SM: OpenLDAP + CUPS
virt-customize -a $DISK_PATH/srv-ldap-sm.qcow2 --install cups 2>&1 | tail -2

virt-customize -a $DISK_PATH/srv-ldap-sm.qcow2 --run-command '
# === LDAP: estructura base ===
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

# Configurar slapd
cat > /tmp/slapd-debconf << EOF
slapd slapd/password1 password admin
slapd slapd/password2 password admin
slapd slapd/domain string empresa.local
slapd slapd/organization string Empresa
EOF

DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive slapd < /tmp/slapd-debconf 2>/dev/null || true
' 2>&1 | tail -2

# SRV_LDAP_Bar: OpenLDAP + SSH
virt-customize -a $DISK_PATH/srv-ldap-bar.qcow2 --run-command '
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

# Habilitar SSH
systemctl enable ssh 2>/dev/null || true
' 2>&1 | tail -2

echo "✅ LDAP + CUPS + SSH configurados"
echo ""

# ============================================
# FINAL
# ============================================
echo "============================================"
echo " 🎉 CONFIGURACIÓN COMPLETA"
echo "============================================"
echo ""
echo "Resumen:"
echo "  SRV_DNS_Bog  (10.1.0.5):  DNS (BIND9) + DHCP"
echo "  SRV_WEB_Cuc  (10.2.0.5):  WEB (Apache) + FTP (vsftpd)"
echo "  SRV_LDAP_SM  (10.3.0.5):  LDAP (OpenLDAP) + CUPS"
echo "  SRV_LDAP_Bar (10.4.0.5):  LDAP (OpenLDAP) + SSH"
echo ""
echo "Para aplicar los cambios, reinicia las VMs en GNS3"
echo "o ejecuta dentro del container:"
echo "  systemctl restart bind9 isc-dhcp-server apache2 vsftpd slapd cups ssh"
echo "============================================"
