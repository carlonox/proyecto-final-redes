#!/bin/bash
# Detener y configurar routers - Proyecto Final
set -e

PID="6abefd25-14e5-4add-aea8-130ae0a0fdee"
BASE="/data/projects/Proyecto-Final-Redes/project-files/dynamips"

echo "=== Deteniendo routers ==="
curl -s "http://localhost:3080/v2/projects/$PID/nodes" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for n in d:
    if n['node_type']=='dynamips':
        print(n['node_id'])
" | while read nid; do
    curl -s -X POST "http://localhost:3080/v2/projects/$PID/nodes/$nid/stop" >/dev/null
    echo "  ⏹️  deteniendo $nid"
done

echo ""
echo "=== Escribiendo configs ==="

# Configuraciones por router
cat > "$BASE/4d72dadb-82a7-4a31-9928-f7de4005fce4/configs/i1_startup-config.cfg" << 'EOF'
hostname Core_Bogota
interface FastEthernet0/0
 ip address 10.255.0.1 255.255.255.252
 no shutdown
interface Serial1/0.100 point-to-point
 ip address 10.255.1.1 255.255.255.252
 frame-relay interface-dlci 100
interface Serial1/0.101 point-to-point
 ip address 10.255.10.1 255.255.255.252
 frame-relay interface-dlci 101
interface Serial2/0
 ip address 10.255.2.1 255.255.255.252
 no shutdown
interface Serial2/1
 ip address 10.255.3.1 255.255.255.252
 no shutdown
interface GigabitEthernet3/0
 ip address 10.255.4.1 255.255.255.252
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
EOF
echo "  ✅ Core_Bogota"

cat > "$BASE/e4f9ac4e-14b8-4159-a223-be4b1cd811aa/configs/i1_startup-config.cfg" << 'EOF'
hostname Core_Cucuta
interface FastEthernet0/0
 ip address 10.255.5.1 255.255.255.252
 no shutdown
interface Serial1/0
 ip address 10.255.6.1 255.255.255.252
 no shutdown
interface GigabitEthernet3/0
 ip address 10.255.4.2 255.255.255.252
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
EOF
echo "  ✅ Core_Cucuta"

cat > "$BASE/f44e6010-dd3b-43fa-a443-f5070bcdf1e7/configs/i1_startup-config.cfg" << 'EOF'
hostname Core_SantaMarta
interface FastEthernet0/0
 ip address 10.255.7.1 255.255.255.252
 no shutdown
interface Serial1/0.200 point-to-point
 ip address 10.255.1.2 255.255.255.252
 frame-relay interface-dlci 200
interface Serial1/0.201 point-to-point
 ip address 10.255.8.1 255.255.255.252
 frame-relay interface-dlci 201
interface Serial2/0
 ip address 10.255.2.2 255.255.255.252
 no shutdown
interface Serial2/1
 ip address 10.255.9.1 255.255.255.252
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
EOF
echo "  ✅ Core_SantaMarta"

cat > "$BASE/3dce55b3-5ebc-4c4b-a9f1-37e88c860977/configs/i1_startup-config.cfg" << 'EOF'
hostname Core_Barranquilla
interface FastEthernet0/0
 ip address 10.255.11.1 255.255.255.252
 no shutdown
interface Serial1/0.301 point-to-point
 ip address 10.255.10.2 255.255.255.252
 frame-relay interface-dlci 301
interface Serial1/0.302 point-to-point
 ip address 10.255.8.2 255.255.255.252
 frame-relay interface-dlci 302
interface Serial1/1
 ip address 10.255.6.2 255.255.255.252
 no shutdown
interface Serial2/1
 ip address 10.255.3.2 255.255.255.252
 no shutdown
interface Serial2/2
 ip address 10.255.9.2 255.255.255.252
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
EOF
echo "  ✅ Core_Barranquilla"

cat > "$BASE/92b9ae8e-6a16-4eb3-b5ba-9988ae729c7c/configs/i1_startup-config.cfg" << 'EOF'
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
EOF
echo "  ✅ Dist_Bogota"

cat > "$BASE/eaad6e28-dcc0-4e79-8fc9-c7688b55d04a/configs/i1_startup-config.cfg" << 'EOF'
hostname Dist_Cucuta
interface FastEthernet0/0
 ip address 10.255.5.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.2.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
EOF
echo "  ✅ Dist_Cucuta"

cat > "$BASE/e2daade8-7d30-4378-8ed8-a6c962458393/configs/i1_startup-config.cfg" << 'EOF'
hostname Dist_SantaMarta
interface FastEthernet0/0
 ip address 10.255.7.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.3.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
EOF
echo "  ✅ Dist_SantaMarta"

cat > "$BASE/5d69c1da-9ff0-4497-8063-fade215c2407/configs/i1_startup-config.cfg" << 'EOF'
hostname Dist_Barranquilla
interface FastEthernet0/0
 ip address 10.255.11.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.4.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end
EOF
echo "  ✅ Dist_Barranquilla"

echo ""
echo "=== Iniciando routers ==="
curl -s "http://localhost:3080/v2/projects/$PID/nodes" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for n in d:
    if n['node_type']=='dynamips':
        print(n['node_id'])
" | while read nid; do
    curl -s -X POST "http://localhost:3080/v2/projects/$PID/nodes/$nid/start" >/dev/null
    echo "  ▶️  iniciando $nid"
done

echo ""
echo "✅ 8 routers configurados e iniciando"
echo "Esperá 1 minuto y probá ping desde VPCS"
