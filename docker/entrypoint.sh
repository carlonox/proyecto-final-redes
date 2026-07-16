#!/bin/bash
# ===========================================
# Entrypoint del contenedor GNS3
# Configura el entorno y arranca GNS3 server
# ===========================================
set -e

echo "============================================"
echo " GNS3 Server - Proyecto Final Redes 2025967"
echo "============================================"
echo ""

# 1. Verificar KVM
echo "[1/5] Verificando KVM..."
if [ -e /dev/kvm ]; then
    echo "  ✅ KVM disponible"
    chmod 666 /dev/kvm 2>/dev/null || true
else
    echo "  ⚠️  KVM no disponible (modo lento)"
fi

# 2. Verificar /dev/net/tun
echo "[2/5] Verificando TUN/TAP..."
if [ -e /dev/net/tun ]; then
    echo "  ✅ TUN/TAP disponible"
else
    echo "  ⚠️  TUN/TAP no disponible"
fi

# 3. Configurar ubridge
echo "[3/5] Configurando ubridge..."
chmod u+s /usr/bin/ubridge 2>/dev/null || true

# 4. Listar imágenes disponibles
echo "[4/5] Imágenes disponibles:"
find /data/imagenes -type f | while read f; do
    size=$(du -h "$f" | cut -f1)
    echo "  📦 $f ($size)"
done | head -20

# 5. Verificar configuración
echo "[5/5] Verificando configuración..."
ls -la /home/gns3/.config/GNS3/2.2/ 2>/dev/null

echo ""
echo "============================================"
echo " Iniciando GNS3 Server..."
echo " Puerto: 3080"
echo " API:    http://localhost:3080/v2/version"
echo "============================================"
echo ""

# Arrancar GNS3 server (primer plano — sin --daemon)
echo "> gns3server --local"
exec gns3server --local 2>&1
