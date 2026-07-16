# 🚀 PROYECTO FINAL REDES 2025967
## Configuración de Infraestructura y Servicios Distribuidos de Red

### 📋 Resumen
Red WAN corporativa con 4 ciudades (Bogotá, Cúcuta, Santa Marta, Barranquilla)
implementada en **GNS3** con **Docker** para portabilidad total.

### 🏗️ Tecnologías
- **Routers:** Cisco 7200 (IOS 15.2) con Dynamips
- **Switches:** IOU L2 + Ethernet switch
- **Servidores:** Ubuntu 24.04 LTS en QEMU/KVM
- **WAN:** Frame-Relay, Metro-Ethernet, HDLC
- **Routing:** EIGRP AS 100
- **Servicios:** DNS (BIND9), DHCP, WEB (Apache), FTP (vsftpd), LDAP (OpenLDAP), CUPS, SSH

### 📦 Estructura del proyecto
```
/proyecto/
├── Dockerfile                        # Imagen Docker personalizada
├── docker-compose.yml                # Orquestación
├── Proyecto-Final-Redes.gns3         # Topología GNS3
├── imagenes/
│   ├── IOS/                          # Cisco IOS (7200, 3745)
│   ├── IOU/                          # IOU L2
│   └── QEMU/Servers/                 # Discos Ubuntu (4 servidores)
├── config/                           # Configuraciones GNS3
├── scripts/                          # Scripts de automatización
└── Documentacion-*.md                # Guías técnicas
```

### 🐳 CÓMO USAR (Docker)

#### 🚀 Un solo comando (recomendado)
```bash
bash setup.sh
```
Esto instala git-lfs, descarga imágenes, construye y levanta GNS3 automáticamente.

#### Paso a paso manual
#### Requisitos:
- Docker Engine 24+ con Docker Compose
- WSL2 con virtualización habilitada (Windows)
- Linux con KVM (nativo)
- Mínimo 8GB RAM, 10GB disco libre

#### Paso 1: Clonar / Copiar
```bash
git clone <repo> /proyecto
cd /proyecto
git lfs pull   # Descargar imágenes IOS, IOU y QEMU
```

#### Paso 2: Levantar
```bash
# Opción A: Usando docker compose directamente
docker compose -f docker/docker-compose.yml up -d --build

# Opción B: Usando make (si lo tienes instalado)
make build
make up
```

#### Paso 3: Verificar
```bash
make test
# o
curl http://localhost:3080/v2/version
```

#### Paso 4: Abrir GNS3 GUI
```bash
# En Windows: http://localhost:3080
# O instalar GNS3 GUI local y conectar a localhost:3080
```

#### Paso 5: Configurar servicios en servidores
```bash
# Dentro del container GNS3:
DISK_PATH=/data/imagenes/QEMU/Servers bash scripts/configurar-servidores.sh
DISK_PATH=/data/imagenes/QEMU/Servers bash scripts/configurar-servicios.sh
DISK_PATH=/data/imagenes/QEMU/Servers bash scripts/configurar-pendientes.sh
```

#### Paso 6: Configurar VLANs, STP y HSRP
Ver archivo `config/configuraciones-vlan-stp-hsrp.txt` para comandos a aplicar en los dispositivos.

### 🖥️ CÓMO USAR (Nativo - sin Docker)

```bash
bash docker/setup-native.sh
```

### 🔧 COMANDOS ÚTILES (Makefile)
| Comando | Descripción |
|---|---|
| `make up` | Levantar contenedor |
| `make down` | Detener contenedor |
| `make restart` | Reiniciar |
| `make logs` | Ver logs en vivo |
| `make shell` | Terminal dentro del contenedor |
| `make status` | Estado del servicio |
| `make test` | Pruebas de conectividad |

### 🌐 ACCESO A LA RED
| Ciudad | Subred | Gateway |
|---|---|---|
| Bogotá | 10.1.0.0/24 | 10.1.0.1 |
| Cúcuta | 10.2.0.0/24 | 10.2.0.1 |
| Santa Marta | 10.3.0.0/24 | 10.3.0.1 |
| Barranquilla | 10.4.0.0/24 | 10.4.0.1 |

### 🖥️ SERVIDORES (root/ubuntu)
| Servidor | IP | Servicios |
|---|---|---|
| SRV_DNS_Bog | 10.1.0.5 | BIND9, DHCP |
| SRV_WEB_Cuc | 10.2.0.5 | Apache, vsftpd |
| SRV_LDAP_SM | 10.3.0.5 | OpenLDAP, CUPS |
| SRV_LDAP_Bar | 10.4.0.5 | OpenLDAP, SSH |

### 🔌 PARA OPENCODE/MCP
```bash
# Configurar en ~/.config/opencode/opencode.json:
# {
#   "mcp": {
#     "gns3": {
#       "type": "local",
#       "command": ["uv", "run", "python", "-m", "gns3_mcp.server"],
#       "env": {
#         "GNS3_SERVER_URL": "http://127.0.0.1:3080"
#       },
#       "enabled": true
#     }
#   }
# }
```

|### 📦 ENTREGABLES GENERADOS
| Archivo | Contenido |
|---|---|
| `Documentacion-Proyecto-Final-Redes.docx` | Documento Word completo: IP, SOs, servicios, networking, pruebas |
| `Plan-IP-Proyecto-Final.xlsx` | Excel con 6 hojas: Portada, VLSM, Subredes, Dispositivos, NAT, IPv6 |
| `Plan-IP-Proyecto-Final.html` | Vista HTML del plan IP (abrir en navegador) |
| `Plan-IP-Proyecto-Final.csv` | IP planning para Excel (formato CSV) |
| `Banco-Preguntas-Sustentacion.md` | 122 preguntas con respuestas para sustentación |
| `Documentacion-Proyecto-Final-Redes.md` | Documentación técnica completa |
| `config/configuraciones-vlan-stp-hsrp.txt` | Configuraciones de VLANs, STP y HSRP listas para aplicar |
| `Proyecto-Final-Redes.gns3` | Topología GNS3 (28 nodos) |
| `scripts/` | Scripts de automatización de servidores |

### 🤖 CI/CD (GitHub Actions)
Al hacer `git push` a `main`, el workflow en `.github/workflows/docker-publish.yml`:
1. Compila la imagen Docker automáticamente
2. La publica en `ghcr.io/carlonox/proyecto-final-redes/servidor-gns3`
3. Tus compañeros descargan la imagen pre-compilada (no necesitan compilar)
4. Ver `SECURITY-GHCR.md` para hacer la imagen pública

### 📚 DOCUMENTACIÓN
| Archivo | Contenido |
|---|---|
| `Documentacion-Proyecto-Final-Redes.md` | Documentación técnica completa |
| `Banco-Preguntas-Sustentacion.md` | 105 preguntas para sustentación |
| `Plan-IP-Proyecto-Final.html` | Tablas de IP (abrir en navegador) |
| `Plan-IP-Proyecto-Final.csv` | IP planning para Excel |

### ⚠️ SOLUCIÓN DE PROBLEMAS

**Error: /dev/kvm no encontrado**
```bash
# En WSL2: Asegurar virtualización anidada
# En Linux: kvm-ok debe decir "KVM acceleration can be used"
# Alternativa: QEMU funcionará sin KVM (más lento)
```

**Error: Permission denied en ubridge**
```bash
# Dentro del contenedor:
chmod u+s /usr/bin/ubridge
# O en el host:
sudo setcap cap_net_admin,cap_net_raw+eip /usr/bin/ubridge
```

**Error: No se encuentran las imágenes IOS**
```bash
# Las imágenes deben estar en /proyecto/imagenes/IOS/
# Formatos esperados:
#   - c7200-adventerprisek9-mz.152-4.S6.image
#   - c3745-adventerprisek9-mz.124-25d.image
```

---
*Universidad Nacional de Colombia - Facultad de Ingeniería - Julio 2026*
