#!/bin/bash
# ===========================================
# Setup Proyecto Final Redes 2025967
# Un solo comando: bash setup.sh
# Funciona desde ZIP o desde git clone
# ===========================================
set -e

echo "============================================"
echo " 🚀 Proyecto Final Redes 2025967 - Setup"
echo "============================================"
echo ""

# Verificar si venimos de ZIP (imágenes ya presentes) o git
if [ -f "imagenes/QEMU/Servers/srv-dns-bog.qcow2" ]; then
    echo "✅ Imágenes encontradas (modo ZIP)"
    HAS_IMAGES=true
else
    echo "📦 Descargando imágenes (git LFS)..."
    HAS_IMAGES=false
fi

# Verificar git y clonar si es necesario
if [ ! -d ".git" ] && [ ! -f "Proyecto-Final-Redes.gns3" ]; then
    echo "📦 Clonando repositorio..."
    git clone https://github.com/carlonox/proyecto-final-redes.git .
fi
echo ""

# 1. Verificar / instalar git-lfs
echo "[1/5] Verificando git-lfs..."
if ! command -v git-lfs &> /dev/null && ! command -v git lfs &> /dev/null; then
    echo "  ⚠️  git-lfs no encontrado. Instalando..."
    # Linux
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq git-lfs
    elif command -v brew &> /dev/null; then
        brew install git-lfs
    elif command -v choco &> /dev/null; then
        choco install git-lfs
    else
        echo "  ❌ No se pudo instalar git-lfs. Instálalo manualmente:"
        echo "     https://git-lfs.com"
        exit 1
    fi
fi
git lfs install
echo "  ✅ git-lfs listo"
echo ""

# 2. Descargar imágenes (solo si faltan)
echo "[2/5] Verificando imágenes..."
IOS_COUNT=$(ls -1 imagenes/IOS/*.image 2>/dev/null | wc -l)
QEMU_COUNT=$(ls -1 imagenes/QEMU/Servers/*.qcow2 2>/dev/null | wc -l)

if [ "$IOS_COUNT" -lt 2 ] || [ "$QEMU_COUNT" -lt 4 ]; then
    echo "  ⏬ Descargando imágenes desde LFS (~9GB)..."
    git lfs pull
    echo "  ✅ Imágenes descargadas"
else
    echo "  ✅ Imágenes ya presentes"
fi
echo ""

# 3. Verificar Docker
echo "[3/5] Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo "  ❌ Docker no encontrado. Instálalo desde:"
    echo "     https://docker.com"
    exit 1
fi
echo "  ✅ Docker disponible"
echo ""

# 4. Construir imagen y levantar
echo "[4/5] Preparando imagen Docker..."
# Intentar descargar desde GHCR (más rápido)
echo "  → Intentando descargar desde ghcr.io..."
if docker compose -f docker/docker-compose.yml pull 2>/dev/null; then
    echo "  ✅ Imagen descargada desde GHCR"
else
    echo "  → No disponible en GHCR. Compilando localmente..."
    docker compose -f docker/docker-compose.yml build
    echo "  ✅ Imagen compilada localmente"
fi
echo ""

echo "[5/5] Levantando GNS3 Server..."
docker compose -f docker/docker-compose.yml up -d
echo ""

# Esperar a que GNS3 esté listo
echo "⏳ Esperando a que GNS3 inicie..."
for i in $(seq 1 30); do
    if curl -s http://localhost:3080/v2/version >/dev/null 2>&1; then
        echo "  ✅ GNS3 listo en http://localhost:3080"
        break
    fi
    sleep 2
done

# Configurar servicios si estamos dentro del container
echo ""
echo "[6/6] Configurando servicios en servidores..."
if command -v virt-customize &> /dev/null; then
    # Estamos dentro del container GNS3 → ejecutar directo
    bash scripts/configurar-servicios-total.sh
    echo "  ✅ Servicios configurados"
elif docker ps --filter name=gns3-proyecto-final --format "{{.Names}}" | grep -q "gns3-proyecto-final"; then
    # El container GNS3 está corriendo → copiar script y ejecutar adentro
    echo "  → Copiando scripts al container GNS3..."
    docker cp scripts/configurar-servicios-total.sh gns3-proyecto-final:/scripts/
    docker exec gns3-proyecto-final chmod +x /scripts/configurar-servicios-total.sh
    echo "  → Ejecutando configuración dentro del container..."
    docker exec gns3-proyecto-final bash /scripts/configurar-servicios-total.sh
    echo "  ✅ Servicios configurados"
else
    echo "  ⚠️  Container GNS3 no detectado. Para configurar servicios manualmente:"
    echo "     docker exec -it gns3-proyecto-final bash /scripts/configurar-servicios-total.sh"
fi

# 5. Verificar
echo "============================================"
echo " Verificando estado..."
echo "============================================"
sleep 3
API_CHECK=$(curl -s http://localhost:3080/v2/version 2>/dev/null || echo "")
if [ -n "$API_CHECK" ]; then
    echo "  ✅ GNS3 Server corriendo en http://localhost:3080"
    echo "  📊 Versión: $(echo $API_CHECK | python3 -c 'import json,sys; print(json.load(sys.stdin).get(\"version\",\"?\"))' 2>/dev/null || echo '?')"
else
    echo "  ⚠️  GNS3 puede estar iniciando... intentá:"
    echo "     docker compose -f docker/docker-compose.yml logs -f"
fi
echo ""
echo "============================================"
echo " 🎉 TODO LISTO!"
echo "============================================"
echo " Abrí GNS3 y cargá: Proyecto-Final-Redes.gns3"
echo " Documentación en:  Documentacion-Proyecto-Final-Redes.docx"
echo " Excel IP en:       Plan-IP-Proyecto-Final.xlsx"
echo "============================================"
