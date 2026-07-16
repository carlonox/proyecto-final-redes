#!/usr/bin/env python3
"""Parchea el .gns3 para agregar startup_config_content a los routers Dynamips"""
import json
import sys
import os

GNS3_FILE = "Proyecto-Final-Redes.gns3"

if not os.path.exists(GNS3_FILE):
    print(f"❌ No encuentro {GNS3_FILE} en {os.getcwd()}")
    sys.exit(1)

with open(GNS3_FILE) as f:
    data = json.load(f)

# Configs para cada router
ROUTER_CONFIGS = {
    "Core_Bogota": """hostname Core_Bogota
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
end""",
    "Core_Cucuta": """hostname Core_Cucuta
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
end""",
    "Core_SantaMarta": """hostname Core_SantaMarta
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
end""",
    "Core_Barranquilla": """hostname Core_Barranquilla
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
end""",
    "Dist_Bogota": """hostname Dist_Bogota
interface FastEthernet0/0
 ip address 10.255.0.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.1.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end""",
    "Dist_Cucuta": """hostname Dist_Cucuta
interface FastEthernet0/0
 ip address 10.255.5.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.2.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end""",
    "Dist_SantaMarta": """hostname Dist_SantaMarta
interface FastEthernet0/0
 ip address 10.255.7.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.3.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end""",
    "Dist_Barranquilla": """hostname Dist_Barranquilla
interface FastEthernet0/0
 ip address 10.255.11.2 255.255.255.252
 no shutdown
interface GigabitEthernet2/0
 ip address 10.4.0.1 255.255.255.0
 no shutdown
router eigrp 100
 network 10.0.0.0
 no auto-summary
end""",
}

count = 0
for node in data["topology"]["nodes"]:
    name = node["name"]
    if name in ROUTER_CONFIGS:
        props = node.get("properties", {})
        # Remove wrong field if present
        if "startup_config" in props:
            del props["startup_config"]
        # Agregar content inline
        props["startup_config_content"] = ROUTER_CONFIGS[name]
        count += 1
        print(f"✅ {name}")

if count == 0:
    print("❌ No se encontraron routers Dynamips en el .gns3")
    sys.exit(1)

# Guardar
with open(GNS3_FILE, "w") as f:
    json.dump(data, f, indent=4)

print(f"\n✅ {count}/8 routers parcheados con startup_config_content")
print("Ahora: docker compose down && docker compose up -d && cargá el proyecto")
