# Documentación Proyecto Final - Redes de Computadores 2026-1

**Asignatura:** 2025967 - Redes de Computadores  
**Grupo:** [Número de Grupo]  
**Fecha:** 14 Julio 2026  
**Profesor:** Jesús Guillermo Tovar Rache  
**Monitor:** Cristian Camilo García Palacios  
**Simulador:** GNS3 v2.2.59  
**Imágenes IOS:** c7200-adventerprisek9-mz.152-4.S6 + i86bi-linux-l2-adventerprisek9-15.1a  

---

## Índice

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Topología de Red](#2-topología-de-red)
3. [Inventario de Dispositivos](#3-inventario-de-dispositivos)
4. [Matriz de Conexiones](#4-matriz-de-conexiones)
5. [Tecnologías WAN](#5-tecnologías-wan)
6. [Direccionamiento IP](#6-direccionamiento-ip)
7. [Configuración de Routers Core](#7-configuración-de-routers-core)
8. [Configuración de Routers de Distribución](#8-configuración-de-routers-de-distribución)
9. [EIGRP](#9-eigrp)
10. [VLANs y STP](#10-vlans-y-stp)
11. [HSRP (Alta Disponibilidad)](#11-hsrp-alta-disponibilidad)
12. [Servidores Ubuntu](#12-servidores-ubuntu)
13. [Flujo de Tráfico](#13-flujo-de-tráfico)
14. [Comandos de Verificación](#14-comandos-de-verificación)
15. [Resolución de Problemas](#15-resolución-de-problemas)
16. [Estado del Proyecto](#16-estado-del-proyecto)

---

## 1. Resumen Ejecutivo

### 1.1 Descripción General

Red WAN corporativa que interconecta 4 ciudades colombianas (Bogotá, Cúcuta, Santa Marta, Barranquilla) mediante una infraestructura de red híbrida que combina tecnologías WAN tradicionales (Frame-Relay, HDLC) y modernas (Metro-Ethernet). El núcleo de la red utiliza EIGRP como protocolo de enrutamiento dinámico.

### 1.2 Arquitectura

```
                    ┌─────────────────────────────────────┐
                    │         NUBE FRAME-RELAY            │
                    │   (Bogota - Santa Marta - Barq)     │
                    └──────┬──────────────┬───────────────┘
                           │              │
      ┌──── FR ────────────┼──────────────┼──────────────────┐
      │                    │              │                  │
┌─────┴──────┐     ┌──────┴──────┐ ┌─────┴──────┐     ┌─────┴──────┐
│ Core_Bogota│─────│Core_Cucuta │ │Core_SMarta │─────│Core_Barranq│
│  (7200)    │     │  (7200)    │ │  (7200)    │     │  (7200)    │
└──┬──┬──┬───┘     └──┬──┬──┬───┘ └──┬──┬──┬───┘     └──┬──┬──┬───┘
   │  │  │            │  │  │       │  │  │           │  │  │
   │  │  └─MetroEth───┘  │  └─MetroEth───┼────────────┘  │  │
   │  └──────── HDLC ─────────────────────┘──────────────┘  │
   └───────────────── HDLC ─────────────────────────────────┘
```

### 1.3 Distribución por Ciudades

| Ciudad | Usuarios | Departamentos | Servidores | Conexión WAN |
|---|---|---|---|---|
| **Bogotá** | 29,800 | Ingeniería (10.2K), Técnica (5.4K), Internet (14.2K) | DNS, DHCP, LDAP | FR + HDLC + MetroEth |
| **Cúcuta** | 55,000 | Internet (12.9K), Técnica (14.7K), Marketing (27.4K) | WEB/FTP, DNS, LDAP | MetroEth + HDLC |
| **Santa Marta** | 67,300 | Marketing (15.6K), Ingeniería (9.3K), Banda Ancha (42.4K) | Impresión, LDAP, WEB | FR (redundante) |
| **Barranquilla** | 27,400 | Mantenimiento (10.2K), Finanzas (17.2K) | LDAP, SSH, DNS | MetroEth + FR + HDLC |

---

## 2. Topología de Red

### 2.1 Diagrama de Topología (GNS3)

```
COORDENADAS EN GNS3 (x,y):
Core_Bogota:       (-450, -280)    Core_Cucuta:       (-200, -280)
Core_SantaMarta:   (-325, -350)    Core_Barranquilla: (-200, -150)
Frame-Relay-Core:  (-325, -250)

Dist_Bogota:       (-450, -100)    Sw_Bogota:         (-450, 50)
PC_Ing_Bog:        (-300, 0)       PC_Tec_Bog:        (-300, 70)
PC_Int_Bog:        (-300, 140)

Dist_Cucuta:       (0, -120)       Sw_Cucuta:         (0, 50)
PC_Int_Cuc:        (180, 20)       PC_Tec_Cuc:        (180, 90)
PC_Mkt_Cuc:        (180, 160)

Dist_SantaMarta:   (0, -350)       Sw_SantaMarta:     (0, -250)
PC_Mkt_SM:         (180, -270)     PC_Ing_SM:         (180, -200)
PC_BA_SM:          (180, -130)

Dist_Barranquilla: (0, 0)          Sw_Barranquilla:   (0, 150)
PC_Man_Bar:        (180, 140)      PC_Fin_Bar:        (180, 210)
```

### 2.2 Estructura por Capas

```
Capa de Core (WAN)
  ├── 4 Routers 7200 interconectados
  ├── Frame-Relay: Malla entre Bogotá, Santa Marta, Barranquilla
  ├── Metro-Ethernet: Bogotá-Cúcuta, Cúcuta-Barranquilla
  └── HDLC: Enlaces redundantes Bogotá-SM-Barranquilla

Capa de Distribución (por ciudad)
  ├── 1 Router 7200 por ciudad (conectado al core)
  └── 1 Switch IOU L2 por ciudad

Capa de Acceso
  └── VPCS como estaciones de trabajo
      ├── 3 PCs por ciudad (Bogotá, Cúcuta, Santa Marta)
      └── 2 PCs (Barranquilla)
```

---

## 3. Inventario de Dispositivos

### 3.1 Routers Core (Capa 3 - WAN)

| # | Nombre | Modelo | Console | Slot0 | Slot1 | Slot2 | Slot3 |
|---|---|---|---|---|---|---|---|
| 1 | Core_Bogota | c7200 | 5000 | C7200-IO-FE | PA-4T+ | PA-4T+ | PA-GE |
| 2 | Core_Cucuta | c7200 | 5001 | C7200-IO-FE | PA-4T+ | PA-4T+ | PA-GE |
| 3 | Core_SantaMarta | c7200 | 5002 | C7200-IO-FE | PA-4T+ | PA-4T+ | PA-GE |
| 4 | Core_Barranquilla | c7200 | 5003 | C7200-IO-FE | PA-4T+ | PA-4T+ | PA-GE |

**Puertos disponibles por router:**
- Slot0 (C7200-IO-FE): FastEthernet0/0
- Slot1 (PA-4T+): Serial1/0, Serial1/1, Serial1/2, Serial1/3
- Slot2 (PA-4T+): Serial2/0, Serial2/1, Serial2/2, Serial2/3
- Slot3 (PA-GE): GigabitEthernet3/0

### 3.2 Routers de Distribución

| # | Nombre | Modelo | Console | Puerto a Core | Puerto a Switch |
|---|---|---|---|---|---|
| 5 | Dist_Bogota | c7200 | 5004 | Fa0/0 | G2/0 |
| 6 | Dist_Cucuta | c7200 | 5012 | Fa0/0 | G2/0 |
| 7 | Dist_SantaMarta | c7200 | 5014 | Fa0/0 | G2/0 |
| 8 | Dist_Barranquilla | c7200 | 5016 | Fa0/0 | G2/0 |

### 3.3 Switches de Acceso (IOU L2)

| # | Nombre | Console | Puertos usados |
|---|---|---|---|
| 9 | Sw_Bogota | 5005 | E0/0(Dist), E0/1(PC1), E0/2(PC2), E0/3(PC3) |
| 10 | Sw_Cucuta | 5013 | E0/0(Dist), E0/1(PC1), E0/2(PC2), E0/3(PC3) |
| 11 | Sw_SantaMarta | 5015 | E0/0(Dist), E0/1(PC1), E0/2(PC2), E0/3(PC3) |
| 12 | Sw_Barranquilla | 5017 | E0/0(Dist), E0/1(PC1), E0/2(PC2) |

### 3.4 Estaciones de Trabajo (VPCS)

| # | Nombre | Console | Ciudad | Departamento | IP Propuesta | Gateway |
|---|---|---|---|---|---|---|
| 13 | PC_Ing_Bog | 5006 | Bogotá | Ingeniería | - | - |
| 14 | PC_Tec_Bog | 5008 | Bogotá | Área Técnica | - | - |
| 15 | PC_Int_Bog | 5010 | Bogotá | Internet por Demanda | - | - |
| 16 | PC_Int_Cuc | 5018 | Cúcuta | Internet por Demanda | - | - |
| 17 | PC_Tec_Cuc | 5020 | Cúcuta | Área Técnica | - | - |
| 18 | PC_Mkt_Cuc | 5022 | Cúcuta | Marketing | - | - |
| 19 | PC_Mkt_SM | 5024 | Santa Marta | Marketing | - | - |
| 20 | PC_Ing_SM | 5026 | Santa Marta | Ingeniería | - | - |
| 21 | PC_BA_SM | 5028 | Santa Marta | Banda Ancha | - | - |
| 22 | PC_Man_Bar | 5030 | Barranquilla | Mantenimiento | - | - |
| 23 | PC_Fin_Bar | 5032 | Barranquilla | Finanzas | - | - |

### 3.5 Infraestructura WAN

| # | Nombre | Tipo | Puertos |
|---|---|---|---|
| 24 | Frame-Relay-Core | Frame Relay Switch | 3 puertos seriales |

---

## 4. Matriz de Conexiones

### 4.1 Enlaces WAN (Capa 2)

#### Frame-Relay (Nube FR)

El switch Frame-Relay tiene 3 puertos con los siguientes PVCs:

```
FR Switch Mappings:
  Puerto 1:100  <-->  Puerto 2:200   (DLCI 100/200)
  Puerto 1:101  <-->  Puerto 3:301   (DLCI 101/301)
  Puerto 2:201  <-->  Puerto 3:302   (DLCI 201/302)
```

**Representación:**

```
Core_Bogota(S1/0) ─── FR P1 ── DLCI 100/200 ── FR P2 ─── Core_SantaMarta(S1/0)
                    │                                │
                    └──── DLCI 101/301 ────── FR P3 ──┴── Core_Barranquilla(S1/0)
                                                    DLCI 201/302 ───┘
```

#### Metro-Ethernet

| De | Puerto | A | Puerto | Tipo |
|---|---|---|---|---|
| Core_Bogota | G3/0 | Core_Cucuta | G3/0 | Ethernet directa |
| Core_Cucuta | S1/0 | Core_Barranquilla | S1/1 | Serial directa |

#### HDLC (Redundancia)

| De | Puerto | A | Puerto |
|---|---|---|---|
| Core_Bogota | S2/0 | Core_SantaMarta | S2/0 |
| Core_Bogota | S2/1 | Core_Barranquilla | S2/1 |
| Core_SantaMarta | S2/1 | Core_Barranquilla | S2/2 |

### 4.2 Enlaces LAN (Por Ciudad)

#### Bogotá

| De | Puerto | A | Puerto |
|---|---|---|---|
| Core_Bogota | Fa0/0 | Dist_Bogota | Fa0/0 |
| Dist_Bogota | G2/0 | Sw_Bogota | E0/0 |
| Sw_Bogota | E0/1 | PC_Ing_Bog | Eth0 |
| Sw_Bogota | E0/2 | PC_Tec_Bog | Eth0 |
| Sw_Bogota | E0/3 | PC_Int_Bog | Eth0 |

#### Cúcuta

| De | Puerto | A | Puerto |
|---|---|---|---|
| Core_Cucuta | Fa0/0 | Dist_Cucuta | Fa0/0 |
| Dist_Cucuta | G2/0 | Sw_Cucuta | E0/0 |
| Sw_Cucuta | E0/1 | PC_Int_Cuc | Eth0 |
| Sw_Cucuta | E0/2 | PC_Tec_Cuc | Eth0 |
| Sw_Cucuta | E0/3 | PC_Mkt_Cuc | Eth0 |

#### Santa Marta

| De | Puerto | A | Puerto |
|---|---|---|---|
| Core_SantaMarta | Fa0/0 | Dist_SantaMarta | Fa0/0 |
| Dist_SantaMarta | G2/0 | Sw_SantaMarta | E0/0 |
| Sw_SantaMarta | E0/1 | PC_Mkt_SM | Eth0 |
| Sw_SantaMarta | E0/2 | PC_Ing_SM | Eth0 |
| Sw_SantaMarta | E0/3 | PC_BA_SM | Eth0 |

#### Barranquilla

| De | Puerto | A | Puerto |
|---|---|---|---|
| Core_Barranquilla | Fa0/0 | Dist_Barranquilla | Fa0/0 |
| Dist_Barranquilla | G2/0 | Sw_Barranquilla | E0/0 |
| Sw_Barranquilla | E0/1 | PC_Man_Bar | Eth0 |
| Sw_Barranquilla | E0/2 | PC_Fin_Bar | Eth0 |

---

## 5. Tecnologías WAN

### 5.1 Frame-Relay

**Descripción:** Tecnología de conmutación de paquetes por circuitos virtuales (PVC).  
**Uso en el proyecto:** Interconexión de Bogotá, Santa Marta y Barranquilla en malla parcial.  
**Configuración:**

**Switch Frame-Relay:**
```
mappings:
  1:100 <-> 2:200   (Bogotá <-> Santa Marta)
  1:101 <-> 3:301   (Bogotá <-> Barranquilla)
  2:201 <-> 3:302   (Santa Marta <-> Barranquilla)
```

**En routers (subinterfaces point-to-point):**
```
interface Serial1/0
 encapsulation frame-relay
 no shutdown

interface Serial1/0.100 point-to-point
 description Enlace FR a Santa Marta
 ip address 10.255.1.1 255.255.255.252
 frame-relay interface-dlci 100
```

### 5.2 Metro-Ethernet

**Descripción:** Enlaces de alta velocidad basados en portadoras Ethernet de área metropolitana.  
**Uso en el proyecto:** Conexión directa Bogotá-Cúcuta y Cúcuta-Barranquilla.  
**Particularidad:** En GNS3 se simula como enlace directo GigabitEthernet o serial con encapsulación por defecto.

### 5.3 HDLC (High-Level Data Link Control)

**Descripción:** Protocolo de control de enlace de datos síncrono.  
**Uso en el proyecto:** Enlaces redundantes entre Bogotá-Santa Marta-Barranquilla.  
**Nota:** Es el encapsulado por defecto en interfaces seriales Cisco (no requiere comando `encapsulation hdlc`).

---

## 6. Direccionamiento IP

### 6.1 Plan de Direccionamiento (Propuesto)

**Red base:** 10.0.0.0/8 (Clase A privada)  
**Crecimiento:** 10% LAN, 3% WAN  
**NAT:** Overload (PAT) en router de borde hacia Internet

#### Enlaces WAN Core (/30)

| Enlace | Subred | Nodo A | IP A | Nodo B | IP B |
|---|---|---|---|---|---|
| MetroEth Bog-Cuc | 10.255.4.0/30 | Core_Bogota G3/0 | 10.255.4.1 | Core_Cucuta G3/0 | 10.255.4.2 |
| FR Bog-SM | 10.255.1.0/30 | Core_Bogota S1/0.100 | 10.255.1.1 | Core_SM S1/0.200 | 10.255.1.2 |
| FR Bog-Bar | 10.255.10.0/30 | Core_Bogota S1/0.101 | 10.255.10.1 | Core_Bar S1/0.301 | 10.255.10.2 |
| FR SM-Bar | 10.255.8.0/30 | Core_SM S1/0.201 | 10.255.8.1 | Core_Bar S1/0.302 | 10.255.8.2 |
| HDLC Bog-SM | 10.255.2.0/30 | Core_Bogota S2/0 | 10.255.2.1 | Core_SM S2/0 | 10.255.2.2 |
| HDLC Bog-Bar | 10.255.3.0/30 | Core_Bogota S2/1 | 10.255.3.1 | Core_Bar S2/1 | 10.255.3.2 |
| HDLC SM-Bar | 10.255.9.0/30 | Core_SM S2/1 | 10.255.9.1 | Core_Bar S2/2 | 10.255.9.2 |
| MetroEth Cuc-Bar | 10.255.6.0/30 | Core_Cucuta S1/0 | 10.255.6.1 | Core_Bar S1/1 | 10.255.6.2 |

#### Enlaces a Distribución (/30)

| Ciudad | Subred | Core | IP Core | Dist | IP Dist |
|---|---|---|---|---|---|
| Bogotá | 10.255.0.0/30 | Core_Bogota Fa0/0 | 10.255.0.1 | Dist_Bogota Fa0/0 | 10.255.0.2 |
| Cúcuta | 10.255.5.0/30 | Core_Cucuta Fa0/0 | 10.255.5.1 | Dist_Cucuta Fa0/0 | 10.255.5.2 |
| Santa Marta | 10.255.7.0/30 | Core_SM Fa0/0 | 10.255.7.1 | Dist_SM Fa0/0 | 10.255.7.2 |
| Barranquilla | 10.255.11.0/30 | Core_Bar Fa0/0 | 10.255.11.1 | Dist_Bar Fa0/0 | 10.255.11.2 |

### 6.2 Subredes LAN (Por Ciudad - Por Definir)

*Las subredes LAN deben calcularse con VLSM según usuarios por departamento:*

| Ciudad | Depto | Usuarios | Crec. 10% | Hosts req. | Máscara |
|---|---|---|---|---|---|
| Bogotá | Ingeniería | 10,200 | 11,220 | - | - |
| Bogotá | Área Técnica | 5,400 | 5,940 | - | - |
| Bogotá | Internet Demanda | 14,200 | 15,620 | - | - |
| Cúcuta | Internet Demanda | 12,900 | 14,190 | - | - |
| Cúcuta | Área Técnica | 14,700 | 16,170 | - | - |
| Cúcuta | Marketing | 27,400 | 30,140 | - | - |
| Santa Marta | Marketing | 15,600 | 17,160 | - | - |
| Santa Marta | Ingeniería | 9,300 | 10,230 | - | - |
| Santa Marta | Banda Ancha | 42,400 | 46,640 | - | - |
| Barranquilla | Mantenimiento | 10,200 | 11,220 | - | - |
| Barranquilla | Finanzas | 17,200 | 18,920 | - | - |

---

## 7. Configuración de Routers Core

### 7.1 Core_Bogota ✅ Hostname configurado

```
hostname Core_Bogota
banner motd # RED CORPORATIVA - CORE BOGOTA #
line con 0
 logging synchronous
 exec-timeout 0 0
!
```

**Configuración de interfaces pendiente:**
```
interface FastEthernet0/0
 description Enlace a Dist_Bogota
 ip address 10.255.0.1 255.255.255.252
 no shutdown
!
interface Serial1/0
 encapsulation frame-relay
 no shutdown
interface Serial1/0.100 point-to-point
 description Enlace FR a Santa Marta
 ip address 10.255.1.1 255.255.255.252
 frame-relay interface-dlci 100
interface Serial1/0.101 point-to-point
 description Enlace FR a Barranquilla
 ip address 10.255.10.1 255.255.255.252
 frame-relay interface-dlci 101
!
interface Serial2/0
 description HDLC a Santa Marta
 ip address 10.255.2.1 255.255.255.252
 no shutdown
interface Serial2/1
 description HDLC a Barranquilla
 ip address 10.255.3.1 255.255.255.252
 no shutdown
!
interface GigabitEthernet3/0
 description Metro-Ethernet a Cucuta
 ip address 10.255.4.1 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
write memory
```

### 7.2 Core_Cucuta ✅ Hostname configurado

```
hostname Core_Cucuta
banner motd # CORE CUCUTA #
line con 0
 logging synchronous
 exec-timeout 0 0
!
interface FastEthernet0/0
 description Enlace a Dist_Cucuta
 ip address 10.255.5.1 255.255.255.252
 no shutdown
interface Serial1/0
 description Metro-Ethernet a Barranquilla
 ip address 10.255.6.1 255.255.255.252
 no shutdown
interface GigabitEthernet3/0
 description Metro-Ethernet a Bogota
 ip address 10.255.4.2 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
write memory
```

### 7.3 Core_SantaMarta ✅ Hostname configurado

```
hostname Core_SantaMarta
banner motd # CORE SANTA MARTA #
!
interface FastEthernet0/0
 description Enlace a Dist_SantaMarta
 ip address 10.255.7.1 255.255.255.252
 no shutdown
interface Serial1/0
 encapsulation frame-relay
 no shutdown
interface Serial1/0.200 point-to-point
 description Enlace FR a Bogota
 ip address 10.255.1.2 255.255.255.252
 frame-relay interface-dlci 200
interface Serial1/0.201 point-to-point
 description Enlace FR a Barranquilla
 ip address 10.255.8.1 255.255.255.252
 frame-relay interface-dlci 201
!
interface Serial2/0
 description HDLC a Bogota
 ip address 10.255.2.2 255.255.255.252
 no shutdown
interface Serial2/1
 description HDLC a Barranquilla
 ip address 10.255.9.1 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
write memory
```

### 7.4 Core_Barranquilla ✅ Hostname configurado

```
hostname Core_Barranquilla
banner motd # CORE BARRANQUILLA #
!
interface FastEthernet0/0
 description Enlace a Dist_Barranquilla
 ip address 10.255.11.1 255.255.255.252
 no shutdown
interface Serial1/0
 encapsulation frame-relay
 no shutdown
interface Serial1/0.301 point-to-point
 description Enlace FR a Bogota
 ip address 10.255.10.2 255.255.255.252
 frame-relay interface-dlci 301
interface Serial1/0.302 point-to-point
 description Enlace FR a Santa Marta
 ip address 10.255.8.2 255.255.255.252
 frame-relay interface-dlci 302
!
interface Serial1/1
 description Metro-Ethernet a Cucuta
 ip address 10.255.6.2 255.255.255.252
 no shutdown
interface Serial2/1
 description HDLC a Bogota
 ip address 10.255.3.2 255.255.255.252
 no shutdown
interface Serial2/2
 description HDLC a Santa Marta
 ip address 10.255.9.2 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
write memory
```

---

## 8. Configuración de Routers de Distribución

*Pendiente - Configurar después de las IPs del core*

**Comandos básicos para todos:**
```
enable
configure terminal
hostname Dist_[Ciudad]
banner motd # DISTRIBUCION [CIUDAD] #
line con 0
 logging synchronous
 exec-timeout 0 0
exit
!
interface FastEthernet0/0
 description Enlace a Core_[Ciudad]
 ip address 10.255.X.2 255.255.255.252
 no shutdown
!
interface GigabitEthernet2/0
 description Enlace a Sw_[Ciudad]
 no shutdown
!
ip default-gateway 10.255.X.1
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
write memory
```

---

## 9. EIGRP

### 9.1 Justificación

EIGRP (Enhanced Interior Gateway Routing Protocol) fue seleccionado por:

| Característica | EIGRP | OSPF | RIP |
|---|---|---|---|
| Tipo | Vector-distancia avanzado | Link-state | Vector-distancia |
| AD interna | 90 | 110 | 120 |
| Convergencia | DUAL (inmediata) | SPF (rápida) | Lenta |
| VLSM/CIDR | ✅ | ✅ | ✅ (v2) |
| Balanceo carga | ✅ Automático | ✅ ECMP | ✅ ECMP |
| Complejidad | Baja | Media | Baja |
| Consumo recursos | Bajo | Alto | Bajo |

**Decisión:** EIGRP ofrece la mejor relación convergencia rápida + baja complejidad para esta topología con enlaces WAN heterogéneos.

### 9.2 Configuración

```
router eigrp 100
 network 10.0.0.0
 no auto-summary
```

**Nota:** `network 10.0.0.0` habilita EIGRP en todas las interfaces con IP en el rango 10.0.0.0/8.

### 9.3 Redistribución

Para conectar con redes externas (Millicom/Internet):
```
router eigrp 100
 redistribute static metric 10000 100 255 1 1500
!
ip route 0.0.0.0 0.0.0.0 [next-hop]
```

---

## 10. VLANs y STP

### 10.1 Plan de VLANs (Propuesto)

| VLAN | Nombre | Ciudad | Subred |
|---|---|---|---|
| 10 | ADMINISTRACION | Todas | - |
| 20 | INGENIERIA | Bogotá, Santa Marta | - |
| 30 | TECNICA | Bogotá, Cúcuta | - |
| 40 | INTERNET | Bogotá, Cúcuta | - |
| 50 | MARKETING | Cúcuta, Santa Marta | - |
| 60 | BANDA_ANCHA | Santa Marta | - |
| 70 | MANTENIMIENTO | Barranquilla | - |
| 80 | FINANZAS | Barranquilla | - |

### 10.2 Configuración de Switch IOU

```
vlan database
 vlan 10 name ADMINISTRACION
 vlan 20 name INGENIERIA
 vlan 30 name TECNICA
!
interface Ethernet0/1
 switchport mode access
 switchport access vlan 20
!
interface Ethernet0/2
 switchport mode access
 switchport access vlan 30
!
interface Ethernet0/0
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
```

### 10.3 STP/PVST

*Pendiente - Configurar root bridge, puertos root, designados y bloqueados*

---

## 11. HSRP (Alta Disponibilidad)

*Pendiente - Para ciudades con redundancia de enrutadores*

**Comandos de referencia:**
```
interface FastEthernet0/0
 standby 1 ip 10.X.X.1
 standby 1 priority 105
 standby 1 preempt
```

---

## 12. Servidores Ubuntu

### 12.1 Servicios por Ciudad

| Ciudad | Servidores | IP Propuesta |
|---|---|---|
| **Bogotá** | DNS, DHCP, LDAP | - |
| **Cúcuta** | WEB, FTP, DNS, LDAP | - |
| **Santa Marta** | Impresión, LDAP, WEB | - |
| **Barranquilla** | LDAP, SSH, DNS | - |

### 12.2 LDAP (OpenLDAP) - Servicio Crítico

El servicio LDAP está replicado en las 4 ciudades para que la autenticación no dependa de la conectividad WAN.

**Estructura del directorio:**
```
dc=empresa,dc=local
├── ou=Bogota
│   ├── cn=usuarios
│   └── cn=grupos
├── ou=Cucuta
├── ou=SantaMarta
└── ou=Barranquilla
```

---

## 13. Flujo de Tráfico

### 13.1 Comunicación dentro de la misma ciudad

```
PC_Ing_Bog (10.X.X.X) → Sw_Bogota → Dist_Bogota → Sw_Bogota → PC_Tec_Bog
                                                                    │
                                                        ┌─ routing si son
                                                        │  VLANs distintas
                                                        └─ switch si misma VLAN
```

### 13.2 Comunicación entre ciudades (ej: Bogotá → Cúcuta)

```
PC_Bog → Sw_Bog → Dist_Bog → Core_Bog(G3/0)
                                    │
                              Metro-Ethernet
                                    │
                              Core_Cuc(G3/0) → Dist_Cuc → Sw_Cuc → PC_Cuc
```

### 13.3 Redundancia (caída de Frame-Relay)

Si cae Frame-Relay entre Bogotá y Barranquilla:
```
PC_Bog → Core_Bog(S2/1) ─── HDLC ─── Core_Bar(S2/1) → PC_Bar
```
EIGRP converge automáticamente usando la ruta HDLC alternativa.

---

## 14. Comandos de Verificación

### 14.1 Estado de Interfaces
```
show ip interface brief
show interfaces description
show interfaces trunk              (switches)
```

### 14.2 Tabla de Enrutamiento
```
show ip route
show ip route eigrp
show ip route 10.255.0.0
```

### 14.3 EIGRP
```
show ip eigrp neighbors
show ip eigrp topology
show ip protocols
```

### 14.4 Frame-Relay
```
show frame-relay pvc
show frame-relay map
show frame-relay lmi
```

### 14.5 VLANs / STP (Switches IOU)
```
show vlan brief
show spanning-tree
show interfaces status
```

### 14.6 HSRP
```
show standby brief
show standby
```

### 14.7 Diagnóstico General
```
ping X.X.X.X
traceroute X.X.X.X
telnet X.X.X.X
debug eigrp packets
debug frame-relay events
```

---

## 15. Setup en otro PC (Guía de instalación)

### 15.1 Requisitos
- **GNS3 v2.2.59+** (https://www.gns3.com/software/download)
- **Dynamips** (incluido con GNS3)
- **QEMU/KVM** (para servidores Ubuntu)
- **Imágenes Cisco IOS** (ver sección 15.2)
- **Ubuntu Server 24.04 cloud image** (https://cloud-images.ubuntu.com/noble/)

### 15.2 Dónde conseguir las imágenes

**Cisco IOS (7200):**
Las imágenes NO se distribuyen gratuitamente. Opciones:
1. **Cisco Academy / CCO:** Descargar desde cisco.com con cuenta con contrato de soporte
2. **Profesor/Monitor:** Solicitar a tu profesor o monitor del curso
3. **Cisco Modeling Labs (CML):** Si la universidad tiene acceso, extraer las .image de CML

Imágenes necesarias:
- `c7200-adventerprisek9-mz.152-4.S6.image` (routers core y distribución)
- `c3745-adventerprisek9-mz.124-25d.image` (alternativa)

**IOU/IOL (Switches):**
- `i86bi-linux-l2-adventerprisek9-15.1a.bin` (switch capa 2)

**Ubuntu Server:**
- Descarga gratuita de https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
- O usa el script: `wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img`

### 15.3 Pasos de instalación

1. **Instalar GNS3** con todos los componentes (Dynamips, QEMU, VPCS, ubridge)
2. **Agregar usuario a grupos:**
   ```bash
   sudo usermod -aG ubridge,kvm,libvirt $USER
   # Cerrar sesión y volver a entrar
   ```
3. **Colocar imágenes IOS** en `~/GNS3/images/IOS/`
4. **Colocar imagen IOU** en `~/GNS3/images/IOU/`
5. **Colocar imagen Ubuntu** en `~/GNS3/images/QEMU/Ubuntu-Server-24.04/`
6. **Crear disco personalizado para servidores** (con contraseña root):
   ```bash
   sudo apt install -y libguestfs-tools
   cp ~/GNS3/images/QEMU/Ubuntu-Server-24.04/ubuntu-server.qcow2 /tmp/custom.qcow2
   sudo virt-customize -a /tmp/custom.qcow2 --root-password password:ubuntu
   sudo mkdir -p ~/GNS3/images/QEMU/Servers
   sudo cp /tmp/custom.qcow2 ~/GNS3/images/QEMU/Servers/srv-dns-bog.qcow2
   # Repetir para cada servidor...
   ```
7. **Abrir proyecto:** File → Open → `Proyecto-Final-Redes.gns3`
8. **Iniciar nodos:** Botón "Start all nodes" (triángulo verde)

### 15.4 Si GNS3 pide imágenes faltantes
Al abrir el proyecto, GNS3 preguntará por las imágenes. Seleccionar:
- Para routers 7200: `c7200-adventerprisek9-mz.152-4.S6.image`
- Para switches: `i86bi-linux-l2-adventerprisek9-15.1a.bin`
- Para servidores: `Servers/srv-*-bog.qcow2`

### 15.5 Configurar IOU License
```bash
echo "[license]
$(hostname) = 3176c959;" > ~/.iourc
```
En GNS3: Preferences → IOU → desmarcar "License check"

### 15.6 Comandos de verificación rápida
```bash
# En VPCS:
ping 10.1.0.1
ping 10.1.0.5

# En routers:
show ip interface brief
show ip route
show ip eigrp neighbors

# En servidores (root/ubuntu):
ip addr show
systemctl status bind9
systemctl status apache2
```

---

## 16. Resolución de Problemas

### 15.1 Los switches IOU no inician

**Error:** `cannot create UNIX domain socket: chown: Operation not permitted`  
**Solución:** Agregar usuario al grupo `ubridge`:
```bash
sudo usermod -aG ubridge $USER
# Cerrar sesión y volver a entrar
```

### 15.2 Los routers usan 100% CPU (idle-pc)

**Solución:** Calcular idle-pc value:
```
En GNS3 GUI: botón derecho en router → "Idle-PC" → "Auto Compute"
```

### 15.3 EIGRP no forma vecinos

Causas comunes:
1. **Misma subred:** Las IPs deben estar en la misma subred /30
2. **MTU mismatch:** Verificar `show interfaces`
3. **K-values:** Todos los routers deben tener los mismos K-values
4. **Passive-interface:** No poner passive-interface en interfaces WAN
5. **Autenticación:** Si se usa, debe coincidir en ambos extremos

### 15.4 Frame-Relay no funciona

Verificar:
```
show frame-relay pvc           # PVCs activos?
show frame-relay map           # Mapeos DLCI-IP correctos?
show interfaces serial1/0      | include protocol  # Serial up/up?
```
Solución común: asegurar que `encapsulation frame-relay` y subinterfaces point-to-point con DLCI correctos.

### 15.5 Metro-Ethernet / HDLC no levanta

```
show interfaces serialX/Y     # Ver estado
```
Si está down/down: verificar cableado y `no shutdown`.
Si está up/down: problema de encapsulación o clock rate (enlace serial).

---

## 16. Estado del Proyecto

### 16.1 Resumen de Avance

| Componente | Estado | % |
|---|---|---|
| Topología GNS3 (28 nodos) | ✅ Completa | 100% |
| Templates (7200, 3745, IOU-L2, Ubuntu) | ✅ Creados | 100% |
| Hostnames + IPs + FR + EIGRP Core | ✅ Configurados | 100% |
| Documentación .md | ✅ Completa | 100% |
| Routers Distribución (hostname + IPs + EIGRP) | ✅ Configurados | 100% |
| Switches LAN (Ethernet switch built-in) | ✅ Arrancados | 100% |
| Servidores Ubuntu (4 VMs QEMU) | ✅ Agregados a GNS3 | 50% |
| VLANs en switches | ⚠️ Reemplazar IOU por Ethernet switch | 0% |
| STP/PVST | 🔄 Pendiente | 0% |
| HSRP (alta disponibilidad) | 🔄 Pendiente | 0% |
| Instalar servicios en servidores | 🔄 Pendiente | 0% |
| Pruebas conectividad | 🔄 Pendiente | 0% |
| Documento Word | 🔄 Pendiente | 0% |
| Excel IP planning (VLSM) | 🔄 Pendiente | 0% |

### 16.2 Checklist de Entregables

- [ ] Word: paso a paso direccionamiento IP, SOs, servicios, networking, pruebas
- [ ] Excel: planeación IPv4/IPv6, tabla de subredes, política de direccionamiento
- [ ] Archivo GNS3 `.gns3`: `Proyecto-RedesFecha.gns3`
- [ ] Capturas/logs de cada servicio funcionando
- [ ] Todo comprimido `.zip`: `NumeroDeGrupo-proyecto final-redes de computadores-grupo 1 o 2-fecha`

---

### 16.9 Imágenes faltantes al abrir proyecto
Al abrir el .gns3 en otro PC, GNS3 mostrará ventanas pidiendo localizar imágenes:
- **c7200 image:** Buscar el archivo `.image` en tu disco
- **IOU image:** Buscar el archivo `.bin`
- **QEMU disk:** Buscar los archivos `.qcow2`

Solución: tener las imágenes en las carpetas:
```
~/GNS3/images/IOS/           → *.image
~/GNS3/images/IOU/           → *.bin  
~/GNS3/images/QEMU/Servers/ → *.qcow2
```

### 16.10 Dynamips no inicia routers
```bash
# Verificar que dynamips está instalado
which dynamips
# Si no: reinstalar GNS3 o ejecutar:
sudo apt install -y dynamips
```

### 16.11 QEMU/KVM no disponible
```bash
# Verificar virtualización
egrep -c '(vmx|svm)' /proc/cpuinfo
# Si es 0: activar VT-x/AMD-V en BIOS
# Si es >0: instalar KVM
sudo apt install -y qemu-kvm libvirt-daemon-system
sudo usermod -aG kvm,libvirt $USER
```

### 16.12 ubridge: Operation not permitted
```bash
sudo chown root:ubridge /usr/bin/ubridge
sudo chmod 2750 /usr/bin/ubridge
sudo setcap cap_net_admin,cap_net_raw+eip /usr/bin/ubridge
```

---

*Documento generado el 15 de Julio de 2026 como parte del Proyecto Final de Redes de Computadores 2025967.*
*Universidad Nacional de Colombia - Facultad de Ingeniería*
