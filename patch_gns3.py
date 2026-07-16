import json

# Nombre de tu archivo de topología
GNS3_FILE = "Proyecto-Final-Redes.gns3"

# Configuraciones de cada router extraídas de tu documentación
configs = {
    "Core_Bogota": "hostname Core_Bogota\ninterface FastEthernet0/0\n ip address 10.255.0.1 255.255.255.252\n no shutdown\ninterface Serial1/0.100 point-to-point\n ip address 10.255.1.1 255.255.255.252\n frame-relay interface-dlci 100\ninterface Serial1/0.101 point-to-point\n ip address 10.255.10.1 255.255.255.252\n frame-relay interface-dlci 101\ninterface Serial2/0\n ip address 10.255.2.1 255.255.255.252\n no shutdown\ninterface Serial2/1\n ip address 10.255.3.1 255.255.255.252\n no shutdown\ninterface GigabitEthernet3/0\n ip address 10.255.4.1 255.255.255.252\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
    "Core_Cucuta": "hostname Core_Cucuta\ninterface FastEthernet0/0\n ip address 10.255.5.1 255.255.255.252\n no shutdown\ninterface Serial1/0\n ip address 10.255.6.1 255.255.255.252\n no shutdown\ninterface GigabitEthernet3/0\n ip address 10.255.4.2 255.255.255.252\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
    "Core_SantaMarta": "hostname Core_SantaMarta\ninterface FastEthernet0/0\n ip address 10.255.7.1 255.255.255.252\n no shutdown\ninterface Serial1/0\n encapsulation frame-relay\n no shutdown\ninterface Serial1/0.200 point-to-point\n ip address 10.255.1.2 255.255.255.252\n frame-relay interface-dlci 200\ninterface Serial1/0.201 point-to-point\n ip address 10.255.8.1 255.255.255.252\n frame-relay interface-dlci 201\ninterface Serial2/0\n ip address 10.255.2.2 255.255.255.252\n no shutdown\ninterface Serial2/1\n ip address 10.255.9.1 255.255.255.252\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
    "Core_Barranquilla": "hostname Core_Barranquilla\ninterface FastEthernet0/0\n ip address 10.255.11.1 255.255.255.252\n no shutdown\ninterface Serial1/0\n encapsulation frame-relay\n no shutdown\ninterface Serial1/0.301 point-to-point\n ip address 10.255.10.2 255.255.255.252\n frame-relay interface-dlci 301\ninterface Serial1/0.302 point-to-point\n ip address 10.255.8.2 255.255.255.252\n frame-relay interface-dlci 302\ninterface Serial1/1\n ip address 10.255.6.2 255.255.255.252\n no shutdown\ninterface Serial2/1\n ip address 10.255.3.2 255.255.255.252\n no shutdown\ninterface Serial2/2\n ip address 10.255.9.2 255.255.255.252\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
    "Dist_Bogota": "hostname Dist_Bogota\ninterface FastEthernet0/0\n ip address 10.255.0.2 255.255.255.252\n no shutdown\ninterface GigabitEthernet2/0\n ip address 10.1.0.1 255.255.255.0\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
    "Dist_Cucuta": "hostname Dist_Cucuta\ninterface FastEthernet0/0\n ip address 10.255.5.2 255.255.255.252\n no shutdown\ninterface GigabitEthernet2/0\n ip address 10.2.0.1 255.255.255.0\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
    "Dist_SantaMarta": "hostname Dist_SantaMarta\ninterface FastEthernet0/0\n ip address 10.255.7.2 255.255.255.252\n no shutdown\ninterface GigabitEthernet2/0\n ip address 10.3.0.1 255.255.255.0\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
    "Dist_Barranquilla": "hostname Dist_Barranquilla\ninterface FastEthernet0/0\n ip address 10.255.11.2 255.255.255.252\n no shutdown\ninterface GigabitEthernet2/0\n ip address 10.4.0.1 255.255.255.0\n no shutdown\nrouter eigrp 100\n network 10.0.0.0\n no auto-summary\nend",
}


def patch_topology():
    print(f"Abriendo {GNS3_FILE}...")
    with open(GNS3_FILE, "r", encoding="utf-8") as f:
        topo = json.load(f)

    for node in topo["topology"]["nodes"]:
        name = node.get("name")
        if name in configs:
            print(f"-> Parcheando {name}...")

            # 1. Borrar la referencia al archivo físico si existe
            if "startup_config" in node["properties"]:
                del node["properties"]["startup_config"]

            # 2. Inyectar la configuración directamente en el JSON
            node["properties"]["startup_config_content"] = configs[name]

    with open(GNS3_FILE, "w", encoding="utf-8") as f:
        json.dump(topo, f, indent=4)

    print(
        "✅ ¡Topología parcheada con éxito! Todos los routers tienen su startup_config_content."
    )


if __name__ == "__main__":
    patch_topology()
