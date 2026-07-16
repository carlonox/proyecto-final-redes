# BANCO DE PREGUNTAS - PROYECTO FINAL REDES 2025967
## 100+ preguntas con respuestas para sustentacion

---

## SECCION 1: SETUP DE GNS3 E INSTALACION

**P1: ¿Que es GNS3 y por que lo usaron?**
GNS3 (Graphical Network Simulator) es un simulador de redes que permite usar imagenes reales de Cisco IOS. Lo usamos porque nos da funcionalidad identica a equipos reales, a diferencia de Packet Tracer que solo simula comandos.

**P2: ¿Que componentes de GNS3 utilizaron?**
- **Dynamips:** Emula el hardware de routers Cisco 7200
- **QEMU:** Ejecuta maquinas virtuales (servidores Ubuntu)
- **VPCS:** Simula PCs ligeros para pruebas
- **ubridge:** Conecta los dispositivos simulados entre si
- **Wireshark:** Captura de paquetes (integrado)

**P3: ¿Que son las imagenes IOS y donde se consiguen?**
Son archivos .image que contienen el sistema operativo Cisco IOS. Se descargan de cisco.com con cuenta CCO con contrato de soporte activo, o se obtienen del profesor/monitor si la universidad tiene Cisco Academy.

**P4: ¿Que imagenes usaron?**
- `c7200-adventerprisek9-mz.152-4.S6.image` - IOS 15.2 para routers 7200
- `c3745-adventerprisek9-mz.124-25d.image` - IOS 12.4 para routers 3745
- `i86bi-linux-l2-adventerprisek9-15.1a.bin` - IOU para switches capa 2

**P5: ¿Donde se colocan las imagenes en GNS3?**
En `~/GNS3/images/`:
- IOS: `~/GNS3/images/IOS/`
- IOU: `~/GNS3/images/IOU/`
- QEMU: `~/GNS3/images/QEMU/`

**P6: ¿Que es Dynamips?**
Es el emulador que ejecuta las imagenes IOS de Cisco. Crea maquinas virtuales que emulan el hardware de routers (CPU, memoria, interfaces) y ejecuta el IOS real.

**P7: ¿Que es ubridge y que permisos necesita?**
ubridge es el puente de red de GNS3. Conecta los dispositivos mediante túneles UDP. Necesita el grupo `ubridge` y permisos:
```bash
sudo usermod -aG ubridge $USER
sudo chown root:ubridge /usr/bin/ubridge
sudo chmod 2750 /usr/bin/ubridge
sudo setcap cap_net_admin,cap_net_raw+eip /usr/bin/ubridge
```

**P8: ¿Que es QEMU y para que lo usaron?**
QEMU es un emulador de maquinas virtuales. Lo usamos para ejecutar Ubuntu Server 24.04 como servidores de servicios (DNS, DHCP, LDAP, WEB, FTP, CUPS, SSH).

**P9: ¿Que es VPCS?**
VPCS (Virtual PC Simulator) es un simulador ligero de PCs que solo implementa una pila TCP/IP basica. Se usa para hacer pruebas de conectividad (ping, traceroute) sin consumir recursos de una VM completa.

**P10: ¿Como se instala GNS3 en Linux?**
```bash
sudo add-apt-repository ppa:gns3/ppa
sudo apt update
sudo apt install -y gns3-gui gns3-server
sudo usermod -aG ubridge,kvm,libvirt $USER
```

**P11: ¿Que problema tuvieron con los switches IOU?**
Las imagenes IOU requieren `libcrypto.so.4` (OpenSSL 1.1) que no esta disponible en Ubuntu 24.04 que tiene OpenSSL 3.0. Lo solucionamos con:
```bash
sudo ln -sf /lib/i386-linux-gnu/libcrypto.so.3 /lib/i386-linux-gnu/libcrypto.so.4
```

**P12: ¿Que es el idle-pc en Dynamips?**
Es un valor que indica a Dynamips cuando el router esta "ocioso" para reducir el uso de CPU. Sin idle-pc, Dynamips usa 100% de CPU constantemente. Se calcula con "Auto Compute" en GNS3.

**P13: ¿Que templates crearon en GNS3?**
- C7200 (router Dynamips) - imagen c7200-adventerprisek9
- C3745 (router Dynamips) - imagen c3745-adventerprisek9
- IOU-L2 (switch capa 2) - imagen i86bi-linux-l2
- Ubuntu-Server-24.04 (servidor QEMU) - imagen ubuntu-server.qcow2

**P14: ¿Que es el MCP de GNS3 y para que lo usaron?**
MCP (Model Context Protocol) es un protocolo que permite a asistentes de IA (como OpenCode) interactuar directamente con GNS3 via API para crear, configurar y monitorear dispositivos y enlaces.

---

## SECCION 2: TOPOLOGIA DE RED

**P15: ¿Cual es la topologia general de la red?**
Es una topologia jerarquica de 3 capas con 4 ciudades colombianas (Bogota, Cucuta, Santa Marta, Barranquilla) interconectadas por una malla WAN hibrida (Frame-Relay + Metro-Ethernet + HDLC).

**P16: ¿Cuantos dispositivos tiene la red?**
32 nodos en total:
- 4 routers core (7200)
- 4 routers distribucion (7200)
- 4 switches Ethernet
- 11 VPCS (estaciones de trabajo)
- 4 servidores Ubuntu (QEMU)
- 1 Frame-Relay switch
- 4 servidores adicionales

**P17: ¿Cuantos enlaces hay?**
27 enlaces: 12 WAN (Frame-Relay + MetroEth + HDLC) + 15 LAN (Dist-Sw + Sw-PC)

**P18: ¿Cual es la funcion de cada capa?**
- **Core (WAN):** Interconexion entre ciudades, enrutamiento EIGRP, tecnologias WAN
- **Distribucion:** Gateway para LAN de cada ciudad, conexion al core
- **Acceso:** Conexion de dispositivos finales (PCs de usuarios, servidores)

**P19: ¿Que routers usaron y que slots tienen?**
Cisco 7200 con slots:
- Slot 0: C7200-IO-FE (FastEthernet0/0)
- Slot 1: PA-4T+ (Serial1/0-1/3)
- Slot 2: PA-4T+ (Serial2/0-2/3)
- Slot 3: PA-GE (GigabitEthernet3/0)

**P20: ¿Que switches usaron?**
Inicialmente switches IOU L2 (i86bi-linux-l2), pero por problemas de librerias los reemplazamos por Ethernet switch built-in de GNS3 que funcionan sin dependencias.

**P21: ¿Que servidores tienen QEMU y que recursos?**
Cada servidor: 1 vCPU, 1024MB RAM, disco QCOW2 de 3.5GB.
- SRV_DNS_Bog: 10.1.0.5
- SRV_WEB_Cuc: 10.2.0.5
- SRV_LDAP_SM: 10.3.0.5
- SRV_LDAP_Bar: 10.4.0.5

---

## SECCION 3: DIRECCIONAMIENTO IP (VLSM)

**P22: ¿Que red base usaron y por que?**
10.0.0.0/8 (Clase A privada). Porque necesitamos mas de 179,000 direcciones para los 179,500 usuarios totales distribuidos en las 4 ciudades. Clase B maximo da 65,534 hosts, no alcanza.

**P23: ¿Explique el proceso VLSM paso a paso?**
1. Identificar hosts por segmento (Ingenieria 10,200, Tecnica 5,400, Internet 14,200...)
2. Aplicar crecimiento: LAN x1.10, WAN x1.03
3. Ordenar segmentos de mayor a menor hosts
4. Calcular 2^n >= hosts_necesarios, despejar n
5. Mascara = /(32-n)
6. Asignar direcciones secuencialmente sin solapamiento

**P24: ¿Que es el crecimiento del 10% y 3%?**
El enunciado del proyecto exige fijar expectativa de crecimiento. Para LAN se aplica 10% (los departamentos pueden contratar mas personal). Para WAN se aplica 3% porque los enlaces punto a punto tipicamente no crecen en cantidad de hosts.

**P25: ¿Por que los enlaces WAN usan /30?**
Los enlaces punto a punto conectan solo 2 dispositivos, necesitan exactamente 2 direcciones utiles. Una mascara /30 da 2^2 - 2 = 2 hosts, optimo sin desperdicio.

**P26: ¿Que son las direcciones de red y broadcast?**
- Red: todos los bits de host en 0 (ej: 192.168.1.0/24). No se asigna a ningun host.
- Broadcast: todos los bits de host en 1 (ej: 192.168.1.255/24). Se usa para comunicarse con todos los hosts de la subred.

**P27: ¿Cuales son las direcciones IP de los enlaces WAN core?**
| Enlace | Subred | IP1 | IP2 |
|---|---|---|---|
| MetroEth Bog-Cuc | 10.255.4.0/30 | 10.255.4.1 | 10.255.4.2 |
| FR Bog-SM | 10.255.1.0/30 | 10.255.1.1 | 10.255.1.2 |
| FR Bog-Bar | 10.255.10.0/30 | 10.255.10.1 | 10.255.10.2 |
| FR SM-Bar | 10.255.8.0/30 | 10.255.8.1 | 10.255.8.2 |
| HDLC Bog-SM | 10.255.2.0/30 | 10.255.2.1 | 10.255.2.2 |
| HDLC Bog-Bar | 10.255.3.0/30 | 10.255.3.1 | 10.255.3.2 |
| HDLC SM-Bar | 10.255.9.0/30 | 10.255.9.1 | 10.255.9.2 |
| MetroEth Cuc-Bar | 10.255.6.0/30 | 10.255.6.1 | 10.255.6.2 |

**P28: ¿Que subredes LAN usaron?**
| Ciudad | Subred | Gateway | Rango | Hosts |
|---|---|---|---|---|
| Bogota | 10.1.0.0/24 | 10.1.0.1 | 10.1.0.2-254 | 254 |
| Cucuta | 10.2.0.0/24 | 10.2.0.1 | 10.2.0.2-254 | 254 |
| Santa Marta | 10.3.0.0/24 | 10.3.0.1 | 10.3.0.2-254 | 254 |
| Barranquilla | 10.4.0.0/24 | 10.4.0.1 | 10.4.0.2-254 | 254 |

**P29: ¿Que IPs tienen los VPCS?**
Bogota: 10.1.0.10/11/12, Cucuta: 10.2.0.10/11/12, SM: 10.3.0.10/11/12, Bar: 10.4.0.10/11. Gateway es la primera IP util de cada subred.

**P30: ¿Que plan IPv6 usaron?**
2001:db8:1::/48 con subredes /64:
- Bogota: 2001:db8:1:1::/64
- Cucuta: 2001:db8:1:2::/64
- SM: 2001:db8:1:3::/64
- Bar: 2001:db8:1:4::/64
- WAN: 2001:db8:1:ff::/64

**P31: ¿Que es NAT Overload (PAT)?**
Traduce multiples IPs privadas a una sola IP publica usando diferentes puertos TCP/UDP para distinguir las conexiones. Ej: 1000 usuarios comparten la IP publica 200.10.0.1 con puertos 1024-65535.

**P32: ¿Que direcciones publicas usaron?**
Se reservo un bloque /28 ficticio (200.10.0.0/28) para NAT en el router de borde hacia Internet. Esto da 14 direcciones publicas para NAT Overload.

---

## SECCION 4: TECNOLOGIAS WAN

**P33: ¿Que es Frame-Relay?**
Frame-Relay es una tecnologia WAN de conmutacion de paquetes que establece circuitos virtuales (PVCs) entre nodos. Es eficiente para trafico intermitente y fue muy usada en los 90s/2000s.

**P34: ¿Como configuraron Frame-Relay?**
1. Switch FR: se configuran los mapeos entre puertos y DLCIs
2. En routers: `encapsulation frame-relay` en la interfaz Serial
3. Subinterfaces point-to-point con `frame-relay interface-dlci [DLCI]`

**P35: ¿Que son los DLCIs que usaron?**
| PVC | DLCI A | DLCI B |
|---|---|---|
| Bogota-SM | 100 | 200 |
| Bogota-Bar | 101 | 301 |
| SM-Bar | 201 | 302 |

**P36: ¿Por que usar subinterfaces?**
Para evitar split horizon en protocolos de enrutamiento. Con subinterfaces point-to-point, cada PVC se comporta como un enlace separado, permitiendo que EIGRP envie actualizaciones por todas las subinterfaces.

**P37: ¿Que es Metro-Ethernet?**
Es un servicio WAN que utiliza Ethernet como protocolo de capa 2 en enlaces metropolitanos. Ofrece altas velocidades (100Mbps-1Gbps) a menor costo que Frame-Relay.

**P38: ¿Que enlaces Metro-Ethernet configuraron?**
- Bogota-Cucuta (GigabitEthernet3/0)
- Cucuta-Barranquilla (Serial1/0 a Serial1/1)

**P39: ¿Que es HDLC?**
High-Level Data Link Control es un protocolo de capa 2 para enlaces seriales sincronos. Es el encapsulado por defecto en interfaces seriales Cisco. No soporta autenticacion ni compresion.

**P40: ¿Para que sirven los enlaces HDLC redundantes?**
Proporcionan rutas alternativas WAN. Si falla Frame-Relay entre Bogota y Barranquilla, EIGRP converge automaticamente usando la ruta HDLC (Serial2/1).

**P41: ¿Que diferencia hay entre HDLC y PPP?**
HDLC es propietario Cisco, sin autenticacion, sin compresion. PPP es estandar IEEE, soporta autenticacion (PAP, CHAP), compresion, multilink, y deteccion de errores mejorada.

---

## SECCION 5: EIGRP (ENRUTAMIENTO)

**P42: ¿Que es EIGRP?**
Enhanced Interior Gateway Routing Protocol es un protocolo de enrutamiento vector-distancia avanzado (hibrido) desarrollado por Cisco. Combina caracteristicas de vector-distancia (facilidad) y link-state (convergencia rapida).

**P43: ¿Por que eligieron EIGRP y no OSPF?**
| Caracteristica | EIGRP | OSPF |
|---|---|---|
| AD | 90 | 110 |
| Tipo | Vector-distancia avanzado | Link-state |
| Algoritmo | DUAL | SPF (Dijkstra) |
| Convergencia | Inmediata | Rapida |
| Configuracion | Simple (1 comando) | Mas compleja |
| Consumo CPU | Bajo | Alto |
Para 8 routers, EIGRP es mas simple y eficiente.

**P44: ¿Como configuraron EIGRP?**
```bash
router eigrp 100
 network 10.0.0.0
 no auto-summary
```
- `100` es el numero de AS (debe coincidir en todos los routers)
- `network 10.0.0.0` habilita EIGRP en todas las interfaces 10.x.x.x
- `no auto-summary` evita la sumarizacion automatica en clases

**P45: ¿Que es DUAL?**
Diffusing Update Algorithm es el algoritmo de EIGRP que:
1. Calcula la mejor ruta (successor)
2. Calcula una ruta de respaldo (feasible successor)
3. Si falla la principal, usa la respaldo inmediatamente sin recalcular

**P46: ¿Que es la distancia administrativa (AD)?**
Es un valor de credibilidad de 0 a 255. Menor numero = mas confiable:
- Conectada: 0
- Estatica: 1
- EIGRP interna: 90
- OSPF: 110
- RIP: 120
- EIGRP externa: 170

**P47: ¿Como verificar vecinos EIGRP?**
```bash
show ip eigrp neighbors
# Muestra: IP del vecino, interfaz, tiempo de espera, estado
show ip route eigrp
# Muestra solo las rutas aprendidas por EIGRP (codigo D)
show ip protocols
# Muestra configuracion de protocolos de enrutamiento
```

**P48: ¿Que significa "no auto-summary"?**
Por defecto, EIGRP resume rutas en los limites de clase (A/B/C). Con `no auto-summary` deshabilitamos esto para que las subredes VLSM se anuncien con su mascara exacta.

**P49: ¿Como EIGRP maneja la redundancia?**
EIGRP soporta balanceo de carga ECMP (Equal Cost Multi-Path) automaticamente. Si hay dos enlaces con la misma metrica, distribuye el trafico entre ambos.

---

## SECCION 6: CONFIGURACION DE ROUTERS

**P50: ¿Que comandos basicos configuraron en cada router?**
```bash
hostname Core_Bogota     # Identifica el dispositivo
banner motd # mensaje #  # Aviso legal al conectar
line con 0               # Consola
 logging synchronous     # No interrumpir escritura con logs
 exec-timeout 0 0       # Sin timeout por inactividad
service password-encryption  # Encripta passwords en config
```

**P51: ¿Como configurar una interfaz?**
```bash
interface FastEthernet0/0
 description Enlace a Dist_Bogota
 ip address 10.255.0.1 255.255.255.252
 no shutdown
```
- `description`: identifica la conexion
- `ip address`: asigna IP y mascara
- `no shutdown`: activa la interfaz

**P52: ¿Como verificar el estado de las interfaces?**
`show ip interface brief` muestra todas las interfaces con su IP, metodo de asignacion, status (up/down) y protocolo (up/down).

**P53: ¿Que significan los estados de una interfaz?**
- **up/up:** Funcionando correctamente
- **administratively down/down:** En shutdown (desactivada con `shutdown`)
- **down/down:** Sin conexion fisica (cable desconectado)
- **up/down:** Problema de capa 2 (encapsulacion incorrecta, clock rate)

---

## SECCION 7: COMANDOS DE LINUX/SERVIDORES

**P54: ¿Como configuraron los servidores Ubuntu?**
Usamos `virt-customize` (libguestfs) para modificar los discos QEMU directamente sin arrancar las VMs:
```bash
sudo virt-customize -a /tmp/srv-dns-bog.qcow2 \
  --hostname srv-dns-bog \
  --root-password password:ubuntu \
  --install bind9,isc-dhcp-server
```

**P55: ¿Que es netplan?**
Netplan es el gestor de red de Ubuntu que usa archivos YAML en `/etc/netplan/`. Ejemplo:
```yaml
network:
  version: 2
  ethernets:
    ens3:
      addresses: [10.1.0.5/24]
      gateway4: 10.1.0.1
      nameservers:
        addresses: [8.8.8.8]
```

**P56: ¿Que es cloud-init?**
Herramienta que configura automaticamente una VM en el primer arranque. Usa un ISO con archivos user-data y meta-data. Nosotros lo usamos para establecer password y hostname.

**P57: ¿Que servicios se instalaron en cada servidor?**
- SRV_DNS_Bog: `bind9` (DNS) + `isc-dhcp-server` (DHCP)
- SRV_WEB_Cuc: `apache2` (WEB) + `vsftpd` (FTP)
- SRV_LDAP_SM: `slapd` (OpenLDAP) + `cups` (Impresion)
- SRV_LDAP_Bar: `slapd` (OpenLDAP) + `openssh-server` (SSH)

**P58: ¿Que es BIND9?**
BIND9 (Berkeley Internet Name Domain) es el servidor DNS mas utilizado en Internet. Resuelve nombres de dominio a direcciones IP. Archivos de configuracion en `/etc/bind/`.

**P59: ¿Como configurar una zona DNS en BIND9?**
```bash
# /etc/bind/named.conf.local
zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
};
# /etc/bind/db.empresa.local
@ IN SOA srv-dns-bog.empresa.local. admin.empresa.local. (...)
@ IN NS srv-dns-bog.empresa.local.
@ IN A 10.1.0.5
www IN CNAME srv-web-cuc.empresa.local.
```

**P60: ¿Que es Apache2?**
Servidor web HTTP de codigo abierto. Sirve paginas web en el puerto 80. Archivos en `/var/www/html/`. Sitios virtuales en `/etc/apache2/sites-available/`.

**P61: ¿Que es vsftpd?**
Very Secure FTP Daemon es un servidor FTP ligero y seguro. Permite transferencia de archivos. Archivo de config: `/etc/vsftpd.conf`.

**P62: ¿Que es OpenLDAP (slapd)?**
Servidor de directorio LDAP. Almacena informacion jerarquica de usuarios, grupos y recursos. Estructura basada en entradas con atributos, organizadas en un arbol (DIT).

**P63: ¿Que es CUPS?**
Common Unix Printing System es el sistema de impresion estandar en Linux. Permite compartir impresoras en red con colas de impresion. Archivo de config: `/etc/cups/cupsd.conf`.

**P64: ¿Que comando usar para verificar servicios?**
```bash
systemctl status bind9     # Estado de DNS
systemctl status apache2   # Estado de WEB
systemctl status slapd     # Estado de LDAP
systemctl status cups      # Estado de impresion
systemctl status vsftpd    # Estado de FTP
systemctl status ssh       # Estado de SSH
```

**P65: ¿Que comando instala paquetes en Ubuntu?**
```bash
apt update        # Actualiza lista de paquetes
apt install bind9 # Instala BIND9
apt remove bind9  # Desinstala
apt upgrade       # Actualiza todos los paquetes
```

---

## SECCION 8: SERVICIOS DE RED

**P66: ¿Como funciona DNS?**
1. Cliente consulta a servidor DNS por un nombre (ej: www.google.com)
2. Servidor DNS busca en sus registros (A, AAAA, CNAME, MX)
3. Si no lo tiene, consulta a servidores DNS raiz, TLD, y autoritativos
4. Devuelve la direccion IP al cliente

**P67: ¿Que tipos de registro DNS existen?**
- **A**: nombre a IPv4 (www → 10.2.0.5)
- **AAAA**: nombre a IPv6
- **CNAME**: alias (www → srv-web-cuc)
- **MX**: servidor de correo
- **NS**: servidor de nombres autoritativo
- **PTR**: IP a nombre (resolucion inversa)

**P68: ¿Como probar DNS?**
```bash
nslookup www.empresa.local 10.1.0.5
dig @10.1.0.5 empresa.local ANY
```

**P69: ¿Como funciona DHCP (DORA)?**
1. **Discover** (broadcast): Cliente busca servidor DHCP
2. **Offer** (unicast/broadcast): Servidor ofrece una IP
3. **Request** (broadcast): Cliente solicita esa IP
4. **Acknowledge** (unicast/broadcast): Servidor confirma

**P70: ¿Que es DHCP Relay?**
Cuando el servidor DHCP esta en otra subred, se configura `ip helper-address [IP]` en la interfaz del router para reenviar las solicitudes broadcast como unicast al servidor.

**P71: ¿Que es LDAP y cuando se usa?**
Lightweight Directory Access Protocol es un protocolo para acceder a directorios de informacion. Se usa para autenticacion centralizada de usuarios en redes corporativas.

**P72: ¿Que estructura tiene el directorio LDAP?**
Arbol con nodos (entries) que tienen atributos. Ej:
```
dc=empresa,dc=local
├── ou=Bogota
├── ou=Cucuta
├── ou=SantaMarta
├── ou=Barranquilla
└── cn=admin
```

**P73: ¿Como probar LDAP?**
```bash
ldapsearch -x -b "dc=empresa,dc=local" -H ldap://10.3.0.5
```

**P74: ¿Que es HTTP y en que puerto funciona?**
HTTP (Hypertext Transfer Protocol) es el protocolo de la web. Funciona en puerto TCP 80. HTTPS (seguro) en puerto 443.

**P75: ¿Que es FTP y en que puertos funciona?**
FTP (File Transfer Protocol) transfiere archivos. Usa puerto 21 para control y 20 para datos. Modos: activo (cliente se conecta) y pasivo (servidor abre puerto).

---

## SECCION 9: COMANDOS DE VERIFICACION

**P76: ¿Que comandos usan para verificar la red?**
```bash
# Estado de interfaces
show ip interface brief
show interfaces description

# Tabla de enrutamiento
show ip route
show ip route eigrp

# EIGRP
show ip eigrp neighbors
show ip eigrp topology
show ip protocols

# Frame-Relay
show frame-relay pvc
show frame-relay map
show frame-relay lmi

# Diagnostico
ping X.X.X.X
traceroute X.X.X.X
telnet X.X.X.X
```

**P77: ¿Que comando verifica conectividad basica?**
`ping [IP]` envia paquetes ICMP Echo Request y espera Echo Reply. Mide RTT (Round Trip Time) en milisegundos.

**P78: ¿Que comando muestra la ruta que sigue un paquete?**
`traceroute [IP]` muestra cada salto (router) por el que pasa un paquete hasta llegar al destino, con tiempos por salto.

---

## SECCION 10: SEGURIDAD

**P79: ¿Que medidas de seguridad implementaron?**
- `service password-encryption`: encripta passwords en la configuracion
- Password en line vty (acceso telnet)
- Banners de advertencia legal
- Native VLAN cambiada de 1 (seguridad basica en switches)

**P80: ¿Por que cambiar la native VLAN?**
VLAN 1 es la default y conocida por todos. Atacantes pueden explotarla. Se recomienda cambiarla a una VLAN numerica alta (99, 1000).

**P81: ¿Que es SSH vs Telnet?**
SSH encripta todo el trafico (incluyendo passwords). Telnet envia todo en texto plano. SSH usa puerto 22, Telnet puerto 23.

---

## SECCION 11: FRAME-RELAY (DETALLADO)

**P82: ¿Que comando configura Frame-Relay en el router?**
```bash
interface Serial1/0
 encapsulation frame-relay
 no shutdown
interface Serial1/0.100 point-to-point
 description Enlace FR a Santa Marta
 ip address 10.255.1.1 255.255.255.252
 frame-relay interface-dlci 100
```

**P83: ¿Que es DLCI?**
Data Link Connection Identifier. Es un numero que identifica un circuito virtual en Frame-Relay (0-1023). Cada PVC tiene un DLCI diferente.

**P84: ¿Que es LMI?**
Local Management Interface es el protocolo entre el router y el switch Frame-Relay. Verifica el estado de los PVCs. Tipos: Cisco, ANSI, Q933a.

**P85: ¿Como verificar PVCs Frame-Relay?**
```bash
show frame-relay pvc       # Muestra PVCs activos
show frame-relay map       # Mapeo DLCI - IP
show frame-relay lmi       # Estadisticas LMI
```

---

## SECCION 12: EIGRP (DETALLADO)

**P86: ¿Que es el "successor" y "feasible successor"?**
- Successor: la mejor ruta al destino (la que se usa actualmente)
- Feasible successor: ruta de respaldo que cumple la condicion de factibilidad (AD < FD)
Si falla el successor, el feasible successor se activa inmediatamente sin recalcular.

**P87: ¿Que es la metrica de EIGRP?**
Por defecto: `metrica = BW + Delay` donde:
- BW = (10^7 / ancho_de_banda_kbps) x 256
- Delay = (retardo_us / 10) x 256
Puede incluir carga, confiabilidad, MTU.

**P88: ¿Que es el comando `passive-interface`?**
Evita que se envien actualizaciones EIGRP por una interfaz. Se usa en interfaces LAN donde no hay otros routers EIGRP para reducir trafico innecesario.

---

## SECCION 13: VLANs Y SWITCHING

**P89: ¿Que son las VLANs?**
Virtual LANs segmentan una red fisica en redes logicas separadas. Cada VLAN es un dominio de broadcast independiente. Se etiquetan con 802.1Q.

**P90: ¿Que es 802.1Q?**
Estandar IEEE para etiquetar tramas Ethernet con informacion de VLAN. Inserta un tag de 4 bytes entre la direccion MAC y el tipo de protocolo.

**P91: ¿Que es un puerto trunk?**
Puerto que transporta multiples VLANs etiquetadas. Se usa entre switches, o entre switch y router para enrutamiento inter-VLAN.

**P92: ¿Que es un puerto access?**
Puerto que pertenece a una sola VLAN. Los dispositivos conectados no saben que estan en una VLAN (no ven el tag 802.1Q).

**P93: ¿Que comando configura un trunk?**
```bash
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk native vlan 99
 switchport trunk allowed vlan 10,20,30
```

---

## SECCION 14: HSRP Y ALTA DISPONIBILIDAD

**P94: ¿Que es HSRP?**
Hot Standby Router Protocol es un protocolo de Cisco que permite tener 2 routers como gateway con una IP virtual compartida. Si el router activo falla, el standby toma el control.

**P95: ¿Por que no implementaron HSRP?**
HSRP requiere al menos 2 routers por segmento LAN. Cada ciudad solo tiene 1 router de distribucion. Si hubieramos tenido 2, habriamos configurado:
```bash
interface FastEthernet0/0
 standby 1 ip 10.1.0.1
 standby 1 priority 105
 standby 1 preempt
```

**P96: ¿Como logran redundancia WAN entonces?**
Mediante los enlaces HDLC redundantes. Si cae Frame-Relay entre Bogota y Barranquilla, EIGRP detecta la falla y usa automaticamente la ruta HDLC alternativa.

---

## SECCION 15: PREGUNTAS GENERALES

**P97: ¿Que aprendieron con este proyecto?**
Aplicamos conceptos de VLSM, enrutamiento dinamico EIGRP, tecnologias WAN (Frame-Relay, HDLC, Metro-Ethernet), servicios de red (DNS, DHCP, LDAP, WEB, FTP, impresion, SSH), y administracion de servidores Linux, todo integrado en un escenario corporativo realista.

**P98: ¿Que problemas enfrentaron?**
1. Incompatibilidad de librerias IOU (libcrypto.so.4) en Ubuntu 24.04
2. Permisos de ubridge (chown: Operation not permitted)
3. Configuracion de cloud-init para servidores Ubuntu
4. Consola serial de QEMU no mostraba output sin kernel cmdline

**P99: ¿Que mejorarias del proyecto?**
1. Usar switches capa 3 para VLANs y routing inter-VLAN
2. Implementar HSRP con routers redundantes por ciudad
3. Configurar BGP en el borde WAN para redundancia
4. Automatizar deploy de servidores con Ansible
5. Agregar monitoreo con SNMP o Zabbix

**P100: ¿Cual es el flujo de un ping de Bogota a Cucuta?**
1. PC_Ing_Bog (10.1.0.10) → Sw2_Bogota → Dist_Bogota (10.1.0.1)
2. Dist_Bogota (10.255.0.2) → Core_Bogota (10.255.0.1)
3. Core_Bogota G3/0 (10.255.4.1) → Metro-Ethernet → Core_Cucuta G3/0 (10.255.4.2)
4. Core_Cucuta (10.255.5.1) → Dist_Cucuta (10.255.5.2)
5. Dist_Cucuta (10.2.0.1) → Sw2_Cucuta → PC_Int_Cuc (10.2.0.10)

**P101: ¿Cual es el flujo de un ping de Bogota a Barranquilla por Frame-Relay?**
1. PC_Ing_Bog → Dist_Bogota → Core_Bogota
2. Core_Bogota S1/0.101 (10.255.10.1) → FR (DLCI 101/301) → Core_Bar S1/0.301 (10.255.10.2)
3. Core_Bar → Dist_Bar (10.255.11.2)
4. Dist_Bar (10.4.0.1) → Sw2_Bar → PC_Fin_Bar (10.4.0.11)

**P102: ¿Que pasa si cae Frame-Relay entre Bogota y Barranquilla?**
EIGRP detecta la perdida del vecino y activa la ruta de respaldo via HDLC:
1. Core_Bogota S2/1 (10.255.3.1) → HDLC → Core_Bar S2/1 (10.255.3.2)
La convergencia es inmediata (sin recalculo DUAL) si existe feasible successor.

**P103: ¿Que es el archivo .gns3?**
Es el archivo de proyecto de GNS3. Contiene toda la topologia: dispositivos, conexiones, configuraciones, posiciones en el canvas, etc. Se abre con File → Open en GNS3.

**P104: ¿Cuanto tiempo tomo el proyecto?**
Varias sesiones intensivas con el asistente IA via MCP. La topologia se construyo en horas, mientras que la configuracion de servicios en servidores requirio mas tiempo por la instalacion de paquetes.

**P105: ¿Que herramientas usaron ademas de GNS3?**
- OpenCode (asistente IA con MCP)
- virt-customize/libguestfs (modificar discos)
- Python (scripts de interaccion por consola)
- Bash (scripts de automatizacion)
- Excel/LibreOffice (plan IP)
- Markdown (documentacion)

---

## SECCION 12: PLANEACION IP Y VLSM (ampliacion)

**P106: ¿Como calcularon el VLSM para las 4 ciudades?**
Ordenamos los segmentos por cantidad de hosts (con crecimiento 10%), de mayor a menor:
1. Santa Marta (74,030 futuros) → /15 → 10.0.0.0/15
2. Bogota (32,780 futuros) → /16 → 10.2.0.0/16
3. Cucuta (60,500 futuros) → /16 → 10.3.0.0/16
4. Barranquilla (30,140 futuros) → /17 → 10.4.0.0/17

**P107: ¿Por que usaron clase A privada (10.0.0.0/8)?**
Porque con ~180,000 hosts totales entre las 4 ciudades, un bloque clase B (172.16.0.0/12, ~1M hosts) o clase C (192.168.0.0/16, ~65K hosts) no seria suficiente para el crecimiento proyectado con el 10% LAN.

**P108: ¿Como planificaron NAT?**
Usamos NAT Overload (PAT) con un pool publico de 14 IPs (200.10.10.0/28). Toda la red privada 10.0.0.0/8 se traduce a ese pool mediante puertos efimeros. Justificacion: ~180,000 hosts internos y solo 14 IPs publicas requiere PAT para que todos compartan el pool.

**P109: ¿Que politicas de asignacion IP definieron?**
- Estatica: routers (todas las interfaces), servidores (.5 en cada subred), enlaces WAN (/30)
- Dinamica (DHCP): estaciones de trabajo en rango .100 - .200 de cada ciudad
- Excluidas: .1 - .10 (gateways, servidores, reservadas)

**P110: ¿Como planificaron IPv6?**
Usamos el bloque de documentacion 2001:db8:1::/48. Cada ciudad tiene un /64 (2001:db8:1:1::/64 Bogota, :2::/64 Cucuta, etc.). Los enlaces WAN usan 2001:db8:1:ff::/64. Asignacion: SLAAC + DHCPv6 stateless para estaciones, estatica para servidores y routers.

---

## SECCION 13: SERVICIOS EN SERVIDORES

**P111: ¿Que servicios instalaron en SRV_DNS_Bog?**
DNS (BIND9) con zonas directa (empresa.local) e inversa (0.1.10.in-addr.arpa), y DHCP (isc-dhcp-server) con rango 10.1.0.100-200.

**P112: ¿Que registros DNS configuraron?**
- srv-dns-bog.empresa.local → 10.1.0.5
- srv-web-cuc.empresa.local → 10.2.0.5
- srv-ldap-sm.empresa.local → 10.3.0.5
- srv-ldap-bar.empresa.local → 10.4.0.5
- www.empresa.local → CNAME a srv-web-cuc

**P113: ¿Que servicios tiene SRV_WEB_Cuc?**
Apache2 (servicio WEB) con VirtualHost www.empresa.local, y vsftpd (servicio FTP) con acceso local, escritura habilitada y chroot.

**P114: ¿Que servicios tienen SRV_LDAP_SM y SRV_LDAP_Bar?**
SRV_LDAP_SM: OpenLDAP con OUs por ciudad (Bogota, Cucuta, SantaMarta, Barranquilla) y CUPS (impresion).
SRV_LDAP_Bar: OpenLDAP y SSH.

**P115: ¿Como configuraron la autenticacion LDAP?**
OpenLDAP con estructura dc=empresa,dc=local. OUs por ciudad. En clientes Linux se usa sssd/nslcd + PAM para autenticar contra el LDAP. Prueba: ldapsearch -x -b "dc=empresa,dc=local".

**P116: ¿Como probaron cada servicio?**
Protocolo de pruebas por servicio:
1. systemctl status (disponibilidad)
2. ping al servidor (conectividad)
3. Comando especifico (dig, curl, ftp, ldapsearch)
4. Prueba de integracion entre servicios
5. Captura de pantalla y logs

---

## SECCION 14: STP y HSRP

**P117: ¿Que protocolo STP usaron y por que?**
PVST+ (Per-VLAN Spanning Tree Plus). Es el protocolo nativo de Cisco que ejecuta una instancia de STP por cada VLAN, permitiendo balanceo de carga y optimizacion por VLAN. Elegimos PVST+ sobre RSTP porque es compatible con los switches IOU L2 y permite control granular por VLAN.

**P118: ¿Como definieron el Root Bridge?**
Asignamos manualmente prioridad 4096 al switch de distribucion de cada ciudad (la prioridad por defecto es 32768). El switch con menor prioridad es elegido root. Para verificar: show spanning-tree root.

**P119: ¿Que es HSRP y como lo configuraron?**
HSRP (Hot Standby Router Protocol) permite que dos routers compartan una IP virtual como gateway. El router activo (prioridad mayor) reenvia trafico; si falla, el standby toma el control. Configuramos con standby priority 110 (activo), standby preempt y standby version 2.

**P120: ¿Como probaron la alta disponibilidad HSRP?**
Desconectando el router activo y verificando con show standby brief que el standby toma el rol de activo. El ping desde un cliente no debe perder mas de 1-2 paquetes durante la transicion.

---

## SECCION 15: DOCUMENTACION Y ENTREGABLES

**P121: ¿Que documentos entregaron?**
1. Documento Word (.docx) con: paso a paso IP, SOs instalados, servicios, config networking, protocolo de pruebas, resultados.
2. Excel (.xlsx) con: portada, VLSM, tabla de subredes IPv4, asignacion por dispositivo, politica NAT, IPv6.
3. Archivo GNS3 (.gns3) con la topologia completa.
4. Scripts de automatizacion de servicios.
5. Capturas de pruebas.

**P122: ¿Como se nombra el ZIP final?**
NumeroDeGrupo-proyecto final-redes de computadores-grupo 1 o 2-fecha.zip

---

*Banco de preguntas preparado para sustentacion del Proyecto Final de Redes de Computadores 2025967*
*Universidad Nacional de Colombia - Facultad de Ingenieria - Julio 2026*
*122 preguntas cubriendo: Setup GNS3, Topologia, VLSM, WAN, EIGRP, Config routers, Linux, Servicios, Verificacion, Seguridad, Frame-Relay detallado, EIGRP detallado, VLANs, HSRP, Planeacion IP, Servidores, STP, HSRP, y entregables*
