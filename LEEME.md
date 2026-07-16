# 🚀 PROYECTO FINAL REDES 2025967
## Configuración de Infraestructura y Servicios Distribuidos de Red

### ⚡ QUICK START — En cualquier PC

```bash
# 1. Clonar
git clone https://github.com/carlonox/proyecto-final-redes.git
cd proyecto-final-redes

# 2. Descargar imágenes (IOS, IOU, QEMU)
git lfs pull

# 3. Un solo comando: build + up
bash setup.sh

# 4. Abrir GNS3 GUI → Remote Server → localhost:3080
# 5. File → Open Project → Proyecto-Final-Redes.gns3
# 6. Seleccionar todos los nodos → Start
```

### 📋 Resumen
Red WAN corporativa con 4 ciudades (Bogotá, Cúcuta, Santa Marta, Barranquilla)
implementada en **GNS3 v2.2.59** sobre **Docker** para portabilidad total.
**28 nodos**: 8 routers Cisco 7200, 4 switches, 11 VPCS, 4 servidores Ubuntu 24.04, 1 Frame-Relay switch.

### ✅ Conectividad verificada
| Origen | Destino | Resultado |
|---|---|---|
| VPCS Bogotá (10.1.0.10) | Gateway (10.1.0.1) | ✅ 5/5 paquetes, 8ms |
| VPCS Bogotá (10.1.0.10) | Cúcuta (10.2.0.1) | ✅ 5/5 paquetes, 39ms, ttl=252 |

### 🔐 Acceso a servidores
| Servidor | IP | Usuario | Contraseña | Servicios |
|---|---|---|---|---|
| SRV_DNS_Bog | 10.1.0.5 | root | ubuntu | BIND9, DHCP |
| SRV_WEB_Cuc | 10.2.0.5 | root | ubuntu | Apache2, vsftpd |
| SRV_LDAP_SM | 10.3.0.5 | root | ubuntu | OpenLDAP, CUPS |
| SRV_LDAP_Bar | 10.4.0.5 | root | ubuntu | OpenLDAP, SSH |

### 🐳 CÓMO USAR (Docker)

#### Requisitos:
- Docker Engine 24+ con Docker Compose
- WSL2 con virtualización habilitada (Windows) o KVM (Linux)
- Mínimo: 8GB RAM, 10GB disco libre

#### Paso a paso manual
```bash
# 1. Clonar
git clone https://github.com/carlonox/proyecto-final-redes.git
cd proyecto-final-redes

# 2. Descargar imágenes (git LFS)
git lfs pull

# 3. Build + up
docker compose -f docker/docker-compose.yml up -d --build

# 4. Verificar
curl http://localhost:3080/v2/version

# 5. Abrir GNS3 GUI → Remote Server → localhost:3080 → Open Project
```

#### O con setup.sh (automático)
```bash
bash setup.sh
```

### 🌐 ACCESO A LA RED
| Ciudad | Subred | Gateway | VPCS |
|---|---|---|---|
| Bogotá | 10.1.0.0/24 | 10.1.0.1 | PC_Ing_Bog, PC_Tec_Bog, PC_Int_Bog |
| Cúcuta | 10.2.0.0/24 | 10.2.0.1 | PC_Int_Cuc, PC_Tec_Cuc, PC_Mkt_Cuc |
| Santa Marta | 10.3.0.0/24 | 10.3.0.1 | PC_Mkt_SM, PC_Ing_SM, PC_BA_SM |
| Barranquilla | 10.4.0.0/24 | 10.4.0.1 | PC_Man_Bar, PC_Fin_Bar |

### 🔧 COMANDOS ÚTILES
```bash
make up          # Levantar contenedor
make down        # Detener
make restart     # Reiniciar
make logs        # Ver logs
make shell       # Terminal dentro del contenedor
make test        # Pruebas de conectividad
```

### 📦 ENTREGABLES
| Archivo | Contenido |
|---|---|
| `Documentacion-Proyecto-Final-Redes.docx` | Documento Word: IP, SOs, servicios, networking, pruebas |
| `Plan-IP-Proyecto-Final.xlsx` | Excel: VLSM, Subredes, Dispositivos, NAT, IPv6 |
| `Banco-Preguntas-Sustentacion.md` | 122 preguntas con respuestas |
| `Proyecto-Final-Redes.gns3` | Topología GNS3 (28 nodos con configs inline) |
| `config/configuraciones-vlan-stp-hsrp.txt` | Configs VLANs, STP, HSRP |

### 🤖 CI/CD
Al hacer `git push` a `main`, GitHub Actions compila y publica la imagen Docker en `ghcr.io/carlonox/proyecto-final-redes/servidor-gns3`.

### ⚠️ SOLUCIÓN DE PROBLEMAS
**Consolas no conectan:** maperar puertos en docker-compose.yml: `"5000-5050:5000-5050"`
**Servidores no bootean:** esperar 3-5 min (VMs Ubuntu completas), luego `root:ubuntu`

---
*Universidad Nacional de Colombia - Facultad de Ingeniería - Redes de Computadores 2025967 - Julio 2026*
