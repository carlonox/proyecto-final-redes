# Guía práctica — Proyecto Final Redes de Computadores (2025967)

Este documento traduce el enunciado en un plan de trabajo concreto: qué hacer, en qué orden, y con qué herramientas. Está pensado para que lo repartan como checklist entre el equipo.

---

## 0. Decisión de arquitectura (la más importante, tómenla primero)

El diagrama pide routers/switches Cisco (WAN con Frame-Relay, HDLC, Metro-Ethernet) **y** servidores con DHCP, DNS, LDAP, WEB, FTP, impresión. Packet Tracer simula muy bien la parte de networking, pero simula muy mal (o nada) los servicios de servidor reales como LDAP u OpenLDAP, BIND, etc.

**Recomendación concreta:** arquitectura híbrida.

1. **Packet Tracer** (o GNS3 si quieren routers IOS reales) → toda la topología de red: routers, switches, VLANs, STP, EIGRP, HSRP/VRRP, enlaces WAN (Frame-Relay/HDLC/Metro-Ethernet simulado como Ethernet punto a punto).
2. **Máquinas virtuales reales** (VirtualBox o VMware, o incluso contenedores Docker si el profesor lo permite) → ahí SÍ instalan y configuran los servicios de verdad:
   - **Ubuntu Server 22.04/24.04** para DNS (BIND9), DHCP (isc-dhcp-server), LDAP (OpenLDAP/slapd), FTP (vsftpd), Web (Apache o Nginx), Impresión (CUPS).
   - Si el profesor insiste en Windows Server (el diagrama menciona Windows 2003/2008, pero eso ya es obsoleto): usar Windows Server 2019/2022 con roles AD DS + AD LDS (para LDAP), DHCP, DNS, IIS.
3. Conectar ambos mundos: en Packet Tracer, los "servidores" son solo íconos con IP; el trabajo real de configurar el servicio lo hacen en las VMs, y documentan que esa IP del servidor en Packet Tracer corresponde a la VM real donde corrieron el servicio (con capturas).

Si el profesor exige que TODO esté dentro de Packet Tracer, hay una alternativa: Packet Tracer sí simula servicios básicos de DHCP, DNS, HTTP, FTP y hasta un LDAP simplificado dentro de sus "Server" genéricos — es más limitado pero cumple el mínimo. En ese caso usan un único simulador y el entregable es el archivo `.pkt`.

Con tu experiencia previa en Packet Tracer (labs VLSM, PVST, IPv6), te sugiero: **networking en Packet Tracer + servicios en VMs Ubuntu**, es el balance más realista para lo que pide el punto 5 (documentar configuración aplicada, archivos de config, pruebas con comandos reales).

---

## 1. Direccionamiento IP (Actividad 1 y 2)

### Qué tienes que producir
- Un Excel con: clase de red, uso de IP privadas/públicas, crecimiento (10% LAN, 3% WAN), plan de NAT, y por cada subred: primera IP válida, última IP válida, broadcast, y si la asignación es dinámica o estática.
- Un Word (o a mano) explicando el paso a paso —método binario o VLSM— de cómo llegaste a esas subredes.

### Cómo hacerlo (igual que tu Laboratorio 6, pero con 4 ciudades en vez de 5)
1. **Cuenta los hosts reales de cada segmento** en el diagrama (cada grupo de usuarios por área: Ingeniería, Área Técnica, Recursos, Marketing, Finanzas, etc., en Bogotá, Cúcuta, Santamarta, Barranquilla). Como el diagrama tiene los números borrosos en el PDF, confirma con tu profesor/monitor los valores exactos de usuarios por segmento — es el input crítico de todo el VLSM.
2. **Aplica el crecimiento antes de calcular el tamaño de subred**: hosts_futuros = hosts_actuales × 1.10 (LAN) o × 1.03 (WAN, típicamente enlaces punto a punto que no crecen en hosts, solo importa para justificar por qué WAN usa /30).
3. **Ordena los segmentos de mayor a menor** cantidad de hosts (regla de oro de VLSM) y ve asignando el bloque más grande primero.
4. **Decide clase y rango privado**: con esas cantidades de usuarios (miles por ciudad), casi seguro necesitas un bloque clase A privado, ej. `10.0.0.0/8`, porque clase B o C se quedan cortas. Justifica esto explícitamente en el documento (punto a del enunciado).
5. **Direcciones públicas**: solo se usan en el borde hacia "Internet" (el router de salida de Bogotá menciona "Internet por Datacenter"). Ahí planificas un bloque público pequeño (puede ser ficticio tipo documentación, ej. rango de ejemplo) + NAT overload (PAT) para que toda la LAN privada salga con esas pocas IPs públicas.
6. **Enlaces WAN** (Frame-Relay, HDLC, Metro-Ethernet entre routers): usa `/30` (2 hosts útiles) — ahí es donde metes tu 3% de crecimiento como justificación de por qué no necesitas más que /30 (los enlaces punto a punto no escalan en hosts).
7. Para cada subred final calcula con la fórmula estándar: dirección de red, primera IP = red+1, última IP = broadcast−1, broadcast = red con todos los bits de host en 1.

### IPv6
- Asigna un bloque `/48` de documentación tipo `2001:db8:1::/48` (o tu ULA `fd00::/8` si quieren simular producción interna) para toda la organización.
- Subdivide en `/64` por cada VLAN/segmento (es el estándar, nunca subdividas más chico que /64 para redes con hosts).
- Usa SLAAC + DHCPv6 stateless para autoconfiguración de estaciones, y direcciones estáticas (o DHCPv6 stateful) para servidores y routers.
- Documenta LLA (fe80::/10, automática en cada interfaz), y si usan ULA vs GUA para direccionamiento interno.

**Herramienta:** Excel simple (no necesitas nada especial) + una calculadora VLSM online para verificar tus cálculos a mano (ej. subnetting practice tools), pero el documento debe mostrar el método manual paso a paso, no solo el resultado.

---

## 2. Sistemas operativos y servicios (Actividades 4 y 5)

Para cada ciudad, según el diagrama, monta VMs con:

| Servicio | SO recomendado | Software |
|---|---|---|
| DNS | Ubuntu Server | BIND9 |
| DHCP | Ubuntu Server | isc-dhcp-server |
| LDAP | Ubuntu Server | OpenLDAP (slapd) + phpLDAPadmin para administración visual |
| WEB | Ubuntu Server | Apache2 o Nginx |
| FTP | Ubuntu Server | vsftpd |
| Impresión | Ubuntu Server | CUPS |
| SSH (aparece en Barranquilla) | Ubuntu Server | openssh-server |

Puedes levantar todas las VMs en **VirtualBox** conectadas por red interna ("Internal Network") o red puenteada según cómo las conectes al resto de la topología. Si quieres ahorrar recursos, puedes usar **contenedores Docker** para cada servicio (más liviano), aunque un profesor de redes normalmente prefiere ver VMs completas con systemd/journalctl como evidencia.

Para cada servicio documenta (esto es literal lo que pide la "Nota Importante" del enunciado):
- Archivo de configuración usado (ej. `/etc/bind/named.conf.local`, `/etc/dhcp/dhcpd.conf`, `/etc/vsftpd.conf`, `/etc/ldap/slapd.conf` o el árbol `cn=config`).
- Comando de prueba y su salida (ej. `dig @<ip_dns> dominio.local`, `nslookup`, `ldapsearch -x -b "dc=empresa,dc=local"`, `curl ftp://<ip>`, `ping`, `systemctl status <servicio>`).
- Captura de pantalla del resultado esperado vs obtenido.
- Una prueba de carga simple (puedes usar `ab` (Apache Bench) para WEB, o simplemente lanzar varias peticiones DHCP/DNS simultáneas y medir tiempos).

---

## 3. Networking: switching, VLANs y STP (Actividad 7b)

Como ya hiciste el análisis de convergencia RPVST en tu lab anterior, este punto te va a resultar familiar:

1. **VLANs**: crea una VLAN por área/departamento dentro de cada ciudad (Ingeniería, Marketing, Finanzas, etc. — según lo que muestre tu diagrama), más una VLAN de administración y una de servidores.
2. **STP/PVST/RSTP**: en las topologías con enlaces redundantes (verás en el diagrama líneas rojas entre Bogotá-Santamarta-Barranquilla, que sugieren redundancia física):
   - Define explícitamente qué switch será el **root bridge** (normalmente el del core/distribución, o el que le asignes manualmente la prioridad más baja con `spanning-tree vlan X priority 0`).
   - En cada switch no-root, identifica su **puerto root** (el de menor costo hacia el root).
   - En cada segmento, identifica el **puerto designado** (el que reenvía tráfico hacia ese segmento).
   - Cualquier puerto redundante que no sea root ni designado queda en **blocking**.
   - Documenta esto con el comando `show spanning-tree` en cada switch (capturas), igual que hiciste con tus logs de convergencia.

**Herramienta:** Packet Tracer, comandos IOS estándar de switch.

---

## 4. Routing (Actividad 7c)

- Dado que el diagrama menciona explícitamente **EIGRP** en la nube central, usa EIGRP como tu protocolo dinámico interno.
- Justifica la elección: EIGRP es *vector distancia avanzado* (híbrido), tiene distancia administrativa 90 (interna), converge rápido con DUAL, y es más simple de configurar que OSPF para una topología de este tamaño — esa es la explicación que pide el punto 7c-2.
- Si quieres mostrar dominio de ambos protocolos, puedes usar OSPF en un área y redistribuir hacia EIGRP en otra, pero no es obligatorio.
- Enlaces WAN con Frame-Relay y HDLC: en Packet Tracer se configuran en la interfaz serial (`encapsulation frame-relay` / `encapsulation hdlc`), y EIGRP corre encima sin problema.

---

## 5. Alta disponibilidad (Actividad 3 y 6)

### LAN — HSRP/VRRP/GLBP
- En cada ciudad con dos routers/gateways redundantes hacia la LAN, configura **HSRP** (nativo Cisco, más simple de explicar) con una IP virtual compartida.
- Define un router activo y uno standby, con `standby priority` y `standby preempt`.
- Prueba apagando el router activo y mostrando que el standby toma el control (`show standby brief`).

### WAN — BGP o balanceo de carga
- Si tienen doble salida a Internet o doble enlace entre ciudades, puedes simular **BGP** básico entre los routers de borde, o simplemente mostrar balanceo de carga con rutas de igual costo (`ip route` múltiples o EIGRP con enlaces de igual métrica, que balancea automáticamente).

### Replicación de servidores (Actividad 6, es opcional — sopesen el tiempo que tienen)
- Ejemplo real y factible: dos VMs con **BIND9** en modo maestro-esclavo (zona primaria/secundaria con `also-notify` y transferencias de zona AXFR).
- Balanceador: **HAProxy** o **Nginx** como reverse proxy/load balancer en una VM adicional, con `least_conn` o round robin, y health checks activos para detección de fallos.
- Prueba de fallo: apaga una VM y muestra que el balanceador redirige tráfico a la otra (logs de HAProxy).

---

## 6. LDAP como autenticación centralizada (Actividad 8)

- Instala OpenLDAP como directorio central con una estructura tipo `dc=empresa,dc=local`, con OUs por ciudad o departamento y usuarios de prueba.
- En clientes Linux, usa `sssd` o `nslcd` + PAM para autenticar contra el LDAP (`ldapsearch`, login remoto vía SSH probando el usuario del LDAP).
- Protocolo de pruebas sugerido: crear usuario en LDAP → intentar login SSH en una máquina cliente distinta → verificar en logs (`/var/log/auth.log`) que la autenticación pasó por LDAP y no por cuenta local.

---

## 7. Checklist de entregables finales

- [ ] Word o documento a mano: paso a paso de direccionamiento IP, SOs instalados, servicios instalados, configuración de networking, protocolo de pruebas, resultados.
- [ ] Excel: planeación IPv4/IPv6, tabla de subredes, política de direccionamiento (NAT, DHCP vs estático).
- [ ] Archivo `.pkt` de Packet Tracer (o equivalente del simulador que usen), nombrado `Proyecto-RedesFecha`.
- [ ] Capturas/logs de cada servicio funcionando + pruebas de carga.
- [ ] Todo comprimido en `.zip`: `NumeroDeGrupo-proyecto final-redes de computadores-grupo 1 o 2-fecha`.

---

## Orden de trabajo sugerido para el equipo (reparto de tareas)

1. **Persona A:** direccionamiento IP completo (Excel + Word) — es la base de todo lo demás, hazlo primero.
2. **Persona B:** topología en Packet Tracer (switching, VLANs, STP, EIGRP, HSRP).
3. **Persona C:** VMs con DNS, DHCP, LDAP.
4. **Persona D:** VMs con WEB, FTP, impresión + documentación de pruebas.
5. Todos: sesión conjunta al final para probar que el LDAP autentica en los clientes, que el DNS resuelve los nombres de los servidores WEB/FTP, y que el HSRP falla correctamente — esa integración es lo que más impresiona en la sustentación.
