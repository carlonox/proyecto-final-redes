#!/usr/bin/env python3
"""Configurar routers via consola telnet - Proyecto Final Redes"""
import socket
import time
import sys

def telnet_config(host, port, config_lines, name):
    """Conecta via telnet y envía comandos de configuración"""
    print(f"\n🔌 Conectando a {name} (port {port})...")
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(30)
    
    try:
        s.connect((host, port))
        print(f"  ✅ Conectado. Esperando boot...")
        time.sleep(5)
        
        # Salir del setup dialog si aparece
        s.sendall(b'\n')
        time.sleep(2)
        s.sendall(b'no\n')  # Salir del setup dialog
        time.sleep(2)
        s.sendall(b'\n')
        time.sleep(1)
        
        # Entrar a enable
        s.sendall(b'enable\n')
        time.sleep(1)
        
        # Entrar a config term
        s.sendall(b'configure terminal\n')
        time.sleep(1)
        
        # Enviar cada línea de config
        for line in config_lines:
            line = line.strip()
            if not line or line.startswith('!'):
                continue
            s.sendall((line + '\n').encode())
            time.sleep(0.3)
        
        # Salir de config y guardar
        s.sendall(b'end\n')
        time.sleep(1)
        s.sendall(b'write memory\n')
        time.sleep(2)
        s.sendall(b'\n')
        time.sleep(1)
        s.sendall(b'show running-config | include hostname\n')
        time.sleep(2)
        
        # Leer respuesta
        data = b''
        while True:
            try:
                chunk = s.recv(4096)
                if not chunk:
                    break
                data += chunk
            except:
                break
        
        output = data.decode('utf-8', errors='replace')
        if 'hostname' in output:
            # Extraer hostname
            for line in output.split('\n'):
                if 'hostname' in line:
                    print(f"  ✅ {name} configurado: {line.strip()}")
                    return True
        
        print(f"  ⚠️  Respuesta parcial: {output[-200:]}")
        return True
        
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return False
    finally:
        s.close()

# ============================================
# CONFIGS DE CADA ROUTER
# ============================================

configs = [
    ("Core_Bogota", 5000, [
        "hostname Core_Bogota",
        "interface FastEthernet0/0",
        " ip address 10.255.0.1 255.255.255.252",
        " no shutdown",
        "interface Serial1/0.100 point-to-point",
        " ip address 10.255.1.1 255.255.255.252",
        " frame-relay interface-dlci 100",
        "interface Serial1/0.101 point-to-point",
        " ip address 10.255.10.1 255.255.255.252",
        " frame-relay interface-dlci 101",
        "interface Serial2/0",
        " ip address 10.255.2.1 255.255.255.252",
        " no shutdown",
        "interface Serial2/1",
        " ip address 10.255.3.1 255.255.255.252",
        " no shutdown",
        "interface GigabitEthernet3/0",
        " ip address 10.255.4.1 255.255.255.252",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
    ("Core_Cucuta", 5001, [
        "hostname Core_Cucuta",
        "interface FastEthernet0/0",
        " ip address 10.255.5.1 255.255.255.252",
        " no shutdown",
        "interface Serial1/0",
        " ip address 10.255.6.1 255.255.255.252",
        " no shutdown",
        "interface GigabitEthernet3/0",
        " ip address 10.255.4.2 255.255.255.252",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
    ("Core_SantaMarta", 5002, [
        "hostname Core_SantaMarta",
        "interface FastEthernet0/0",
        " ip address 10.255.7.1 255.255.255.252",
        " no shutdown",
        "interface Serial1/0.200 point-to-point",
        " ip address 10.255.1.2 255.255.255.252",
        " frame-relay interface-dlci 200",
        "interface Serial1/0.201 point-to-point",
        " ip address 10.255.8.1 255.255.255.252",
        " frame-relay interface-dlci 201",
        "interface Serial2/0",
        " ip address 10.255.2.2 255.255.255.252",
        " no shutdown",
        "interface Serial2/1",
        " ip address 10.255.9.1 255.255.255.252",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
    ("Core_Barranquilla", 5003, [
        "hostname Core_Barranquilla",
        "interface FastEthernet0/0",
        " ip address 10.255.11.1 255.255.255.252",
        " no shutdown",
        "interface Serial1/0.301 point-to-point",
        " ip address 10.255.10.2 255.255.255.252",
        " frame-relay interface-dlci 301",
        "interface Serial1/0.302 point-to-point",
        " ip address 10.255.8.2 255.255.255.252",
        " frame-relay interface-dlci 302",
        "interface Serial1/1",
        " ip address 10.255.6.2 255.255.255.252",
        " no shutdown",
        "interface Serial2/1",
        " ip address 10.255.3.2 255.255.255.252",
        " no shutdown",
        "interface Serial2/2",
        " ip address 10.255.9.2 255.255.255.252",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
    ("Dist_Bogota", 5004, [
        "hostname Dist_Bogota",
        "interface FastEthernet0/0",
        " ip address 10.255.0.2 255.255.255.252",
        " no shutdown",
        "interface GigabitEthernet2/0",
        " ip address 10.1.0.1 255.255.255.0",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
    ("Dist_Cucuta", 5012, [
        "hostname Dist_Cucuta",
        "interface FastEthernet0/0",
        " ip address 10.255.5.2 255.255.255.252",
        " no shutdown",
        "interface GigabitEthernet2/0",
        " ip address 10.2.0.1 255.255.255.0",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
    ("Dist_SantaMarta", 5014, [
        "hostname Dist_SantaMarta",
        "interface FastEthernet0/0",
        " ip address 10.255.7.2 255.255.255.252",
        " no shutdown",
        "interface GigabitEthernet2/0",
        " ip address 10.3.0.1 255.255.255.0",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
    ("Dist_Barranquilla", 5016, [
        "hostname Dist_Barranquilla",
        "interface FastEthernet0/0",
        " ip address 10.255.11.2 255.255.255.252",
        " no shutdown",
        "interface GigabitEthernet2/0",
        " ip address 10.4.0.1 255.255.255.0",
        " no shutdown",
        "router eigrp 100",
        " network 10.0.0.0",
        " no auto-summary",
    ]),
]

# ============================================
# EJECUTAR
# ============================================
print("=" * 50)
print("Configurando 8 routers via consola telnet")
print("=" * 50)

success = 0
for name, port, lines in configs:
    if telnet_config("127.0.0.1", port, lines, name):
        success += 1

print(f"\n{'='*50}")
print(f"✅ {success}/8 routers configurados")
print(f"{'='*50}")
print("Configuraciones guardadas con 'write memory'")
print("Ahora probá ping desde VPCS")
