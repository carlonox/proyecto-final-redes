#!/bin/bash
# Fix rápido: configura Dist_Bogota y prueba ping
set -e

PID="6abefd25-14e5-4add-aea8-130ae0a0fdee"
API="http://localhost:3080"
DIR="/data/projects/Proyecto-Final-Redes/project-files/dynamips"

echo "=== Paso 1: Parar Dist_Bogota ==="
curl -s -X POST "$API/v2/projects/$PID/nodes/92b9ae8e-6a16-4eb3-b5ba-9988ae729c7c/stop" >/dev/null
sleep 3
echo "OK"

echo "=== Paso 2: Escribir config ==="
mkdir -p "$DIR/92b9ae8e-6a16-4eb3-b5ba-9988ae729c7c/configs"
cat > "$DIR/92b9ae8e-6a16-4eb3-b5ba-9988ae729c7c/configs/i1_startup-config.cfg" << 'CFG'
hostname Dist_Bogota
interface FastEthernet0/0
 ip address 10.255.0.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.1.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
CFG
echo "OK"

echo "=== Paso 3: Iniciar Dist_Bogota ==="
curl -s -X POST "$API/v2/projects/$PID/nodes/92b9ae8e-6a16-4eb3-b5ba-9988ae729c7c/start" >/dev/null
echo "OK"

echo "=== Hecho! Esperá 30s y probá ping desde VPCS ==="
