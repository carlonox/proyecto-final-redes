#!/bin/bash
# Subir startup-configs a los 8 routers via API
# Usa PUT /v2/projects/{pid}/nodes/{nid}/files/i1_startup-config.cfg

PID="6abefd25-14e5-4add-aea8-130ae0a0fdee"
API="http://localhost:3080"
DIR="/tmp/router-configs"
mkdir -p "$DIR"

# ============================================
# CREAR ARCHIVOS DE CONFIG
# ============================================
echo "=== Creando archivos de config ==="

cat > "$DIR/Core_Bogota.cfg" << 'EOF'
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

cat > "$DIR/Core_Cucuta.cfg" << 'EOF'
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

cat > "$DIR/Core_SantaMarta.cfg" << 'EOF'
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

cat > "$DIR/Core_Barranquilla.cfg" << 'EOF'
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

cat > "$DIR/Dist_Bogota.cfg" << 'EOF'
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

cat > "$DIR/Dist_Cucuta.cfg" << 'EOF'
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

cat > "$DIR/Dist_SantaMarta.cfg" << 'EOF'
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

cat > "$DIR/Dist_Barranquilla.cfg" << 'EOF'
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

echo "✅ Archivos creados"
echo ""

# ============================================
# OBTENER NODE IDs Y SUBIR CONFIGS
# ============================================
echo "=== Subiendo configs via API ==="
echo ""

curl -s "$API/v2/projects/$PID/nodes" | python3 -c "
import json, sys, subprocess, os

d = json.load(sys.stdin)
nodes = {n['name']: n['node_id'] for n in d if n['node_type'] == 'dynamips'}
configs_dir = '$DIR'
api = '$API'
pid = '$PID'

# Mapeo nombre -> archivo
config_files = {
    'Core_Bogota': 'Core_Bogota.cfg',
    'Core_Cucuta': 'Core_Cucuta.cfg',
    'Core_SantaMarta': 'Core_SantaMarta.cfg',
    'Core_Barranquilla': 'Core_Barranquilla.cfg',
    'Dist_Bogota': 'Dist_Bogota.cfg',
    'Dist_Cucuta': 'Dist_Cucuta.cfg',
    'Dist_SantaMarta': 'Dist_SantaMarta.cfg',
    'Dist_Barranquilla': 'Dist_Barranquilla.cfg',
}

for name, cfg_file in config_files.items():
    nid = nodes.get(name)
    if not nid:
        print(f'❌ {name}: node_id no encontrado')
        continue
    
    cfg_path = os.path.join(configs_dir, cfg_file)
    if not os.path.exists(cfg_path):
        print(f'❌ {name}: archivo {cfg_path} no existe')
        continue
    
    # Subir config via API
    url = f'{api}/v2/projects/{pid}/nodes/{nid}/files/i1_startup-config.cfg'
    result = subprocess.run(
        ['curl', '-s', '-X', 'PUT', url,
         '--data-binary', f'@{cfg_path}',
         '-H', 'Content-Type: application/octet-stream'],
        capture_output=True, text=True, timeout=30
    )
    
    if result.returncode == 0 and 'error' not in result.stdout.lower():
        print(f'✅ {name}: config subida')
    else:
        # Ver con 'file' endpoint alternativo
        result2 = subprocess.run(
            ['curl', '-s', '-X', 'PUT',
             f'{api}/v2/projects/{pid}/nodes/{nid}/files/startup-config.cfg',
             '--data-binary', f'@{cfg_path}',
             '-H', 'Content-Type: application/octet-stream'],
            capture_output=True, text=True, timeout=30
        )
        if result2.returncode == 0 and 'error' not in result2.stdout.lower():
            print(f'✅ {name}: config subida (alt)')
        else:
            # Probar con endpoint de configs
            result3 = subprocess.run(
                ['curl', '-s', '-X', 'PUT',
                 f'{api}/v2/projects/{pid}/nodes/{nid}/configs/i1_startup-config.cfg',
                 '--data-binary', f'@{cfg_path}',
                 '-H', 'Content-Type: application/octet-stream'],
                capture_output=True, text=True, timeout=30
            )
            if result3.returncode == 0 and ('error' not in result3.stdout.lower() or result3.stdout.strip() == ''):
                print(f'✅ {name}: config subida (configs/)')
            else:
                print(f'⚠️  {name}: respuesta: {result.stdout[:100] or result2.stdout[:100] or result3.stdout[:100]}')
" 2>&1

echo ""
echo "=== Recargando routers ==="
curl -s "$API/v2/projects/$PID/nodes" | python3 -c "
import json, sys, subprocess
d = json.load(sys.stdin)
api = '$API'
pid = '$PID'
for n in d:
    if n['node_type'] == 'dynamips':
        subprocess.run(['curl', '-s', '-X', 'POST',
            f'{api}/v2/projects/{pid}/nodes/{n[\"node_id\"]}/reload'],
            capture_output=True, timeout=30)
        print(f'🔄 {n[\"name\"]} recargado')
" 2>&1

echo ""
echo "✅ Configs subidas y routers recargando"
echo "Esperá 1 minuto y probá ping desde VPCS"
