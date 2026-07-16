#!/bin/bash
# Generar todas las configs de routers - Proyecto Final Redes
# Ejecutar DENTRO del container GNS3: bash /scripts/generar-configs.sh
set -e

BASE="/data/projects/Proyecto-Final-Redes/project-files/dynamips"

# ============================================
# Mapa node_id -> nombre (obtener de la API)
# ============================================
echo "Obteniendo IDs de nodos..."
declare -A NODES
while IFS='|' read -r nid name; do
    NODES["$name"]="$nid"
done < <(curl -s http://localhost:3080/v2/projects/6abefd25-14e5-4add-aea8-130ae0a0fdee/nodes | python3 -c "import json,sys;d=json.load(sys.stdin);[print(f\"{n['node_id']}|{n['name']}\") for n in d if n['node_type']=='dynamips']")

echo "Nodos encontrados: ${#NODES[@]}"

# ============================================
# CONFIGURACIONES
# ============================================

write_config() {
    local name="$1"
    local nid="${NODES[$name]}"
    local config="$2"
    local dir="$BASE/$nid/configs"
    
    mkdir -p "$dir"
    echo "$config" > "$dir/i1_startup-config.cfg"
    echo "  ✅ $name ($nid)"
}

# Core_Bogota
write_config "Core_Bogota" 'enable
config t
hostname Core_Bogota
!
interface FastEthernet0/0
 ip address 10.255.0.1 255.255.255.252
 no shutdown
!
interface Serial1/0.100 point-to-point
 ip address 10.255.1.1 255.255.255.252
 frame-relay interface-dlci 100
!
interface Serial1/0.101 point-to-point
 ip address 10.255.10.1 255.255.255.252
 frame-relay interface-dlci 101
!
interface Serial2/0
 ip address 10.255.2.1 255.255.255.252
 no shutdown
!
interface Serial2/1
 ip address 10.255.3.1 255.255.255.252
 no shutdown
!
interface GigabitEthernet3/0
 ip address 10.255.4.1 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
'

# Core_Cucuta
write_config "Core_Cucuta" 'enable
config t
hostname Core_Cucuta
!
interface FastEthernet0/0
 ip address 10.255.5.1 255.255.255.252
 no shutdown
!
interface Serial1/0
 ip address 10.255.6.1 255.255.255.252
 no shutdown
!
interface GigabitEthernet3/0
 ip address 10.255.4.2 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
'

# Core_SantaMarta
write_config "Core_SantaMarta" 'enable
config t
hostname Core_SantaMarta
!
interface FastEthernet0/0
 ip address 10.255.7.1 255.255.255.252
 no shutdown
!
interface Serial1/0.200 point-to-point
 ip address 10.255.1.2 255.255.255.252
 frame-relay interface-dlci 200
!
interface Serial1/0.201 point-to-point
 ip address 10.255.8.1 255.255.255.252
 frame-relay interface-dlci 201
!
interface Serial2/0
 ip address 10.255.2.2 255.255.255.252
 no shutdown
!
interface Serial2/1
 ip address 10.255.9.1 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
'

# Core_Barranquilla
write_config "Core_Barranquilla" 'enable
config t
hostname Core_Barranquilla
!
interface FastEthernet0/0
 ip address 10.255.11.1 255.255.255.252
 no shutdown
!
interface Serial1/0.301 point-to-point
 ip address 10.255.10.2 255.255.255.252
 frame-relay interface-dlci 301
!
interface Serial1/0.302 point-to-point
 ip address 10.255.8.2 255.255.255.252
 frame-relay interface-dlci 302
!
interface Serial1/1
 ip address 10.255.6.2 255.255.255.252
 no shutdown
!
interface Serial2/1
 ip address 10.255.3.2 255.255.255.252
 no shutdown
!
interface Serial2/2
 ip address 10.255.9.2 255.255.255.252
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
'

# Dist_Bogota
write_config "Dist_Bogota" 'enable
config t
hostname Dist_Bogota
!
interface FastEthernet0/0
 ip address 10.255.0.2 255.255.255.252
 no shutdown
!
interface GigabitEthernet2/0
 ip address 10.1.0.1 255.255.255.0
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
ip dhcp pool BOGOTA
 network 10.1.0.0 255.255.255.0
 default-router 10.1.0.1
 dns-server 10.1.0.5
 domain-name empresa.local
!
end
'

# Dist_Cucuta
write_config "Dist_Cucuta" 'enable
config t
hostname Dist_Cucuta
!
interface FastEthernet0/0
 ip address 10.255.5.2 255.255.255.252
 no shutdown
!
interface GigabitEthernet2/0
 ip address 10.2.0.1 255.255.255.0
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
'

# Dist_SantaMarta
write_config "Dist_SantaMarta" 'enable
config t
hostname Dist_SantaMarta
!
interface FastEthernet0/0
 ip address 10.255.7.2 255.255.255.252
 no shutdown
!
interface GigabitEthernet2/0
 ip address 10.3.0.1 255.255.255.0
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
'

# Dist_Barranquilla
write_config "Dist_Barranquilla" 'enable
config t
hostname Dist_Barranquilla
!
interface FastEthernet0/0
 ip address 10.255.11.2 255.255.255.252
 no shutdown
!
interface GigabitEthernet2/0
 ip address 10.4.0.1 255.255.255.0
 no shutdown
!
router eigrp 100
 network 10.0.0.0
 no auto-summary
!
end
'

echo ""
echo "========================================"
echo "✅ Configs generadas para 8 routers"
echo "========================================"
echo "Ahora reinicia cada router desde el GUI o via API"
