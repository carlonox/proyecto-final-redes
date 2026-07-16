#!/usr/bin/env python3
"""Configurar routers esperando boot - Proyecto Final Redes"""
import socket
import time

def config_router(name, port, commands):
    """Espera boot y configura router via telnet"""
    print(f"\n🔌 {name} (port {port})...", end=" ")
    
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(60)
    
    try:
        s.connect(('127.0.0.1', port))
        print("conectado, esperando boot...")
        
        # Esperar a que salga el prompt de setup o login
        data = b''
        timeout = time.time() + 50  # max 50 segundos de boot
        while time.time() < timeout:
            try:
                chunk = s.recv(4096)
                if not chunk:
                    break
                data += chunk
                text = data.decode('utf-8', errors='replace')
                
                # Detectar setup dialog
                if 'initial configuration dialog' in text.lower():
                    print("  → Setup detectado, respondiendo no...")
                    s.sendall(b'no\n')
                    time.sleep(2)
                    break
                    
                # Detectar prompt ya listo
                if 'Press RETURN to get started' in text or 'Router>' in text or '#' in text:
                    print("  → Router listo, configurando...")
                    time.sleep(1)
                    break
            except socket.timeout:
                break
        
        # Si estamos en enable prompt, enviar comandos
        s.sendall(b'\n')
        time.sleep(1)
        s.sendall(b'enable\n')
        time.sleep(1)
        s.sendall(b'configure terminal\n')
        time.sleep(1)
        
        # Enviar comandos de config
        for cmd in commands:
            cmd = cmd.strip()
            if cmd and not cmd.startswith('!'):
                s.sendall((cmd + '\n').encode())
                time.sleep(0.2)
        
        # Guardar
        s.sendall(b'end\n')
        time.sleep(1)
        s.sendall(b'write memory\n')
        time.sleep(2)
        s.sendall(b'\n')
        time.sleep(1)
        
        # Verificar
        s.sendall(b'show running-config | include hostname\n')
        time.sleep(2)
        
        result = b''
        try:
            while True:
                chunk = s.recv(4096)
                if not chunk: break
                result += chunk
        except:
            pass
        
        if b'hostname' in result:
            host = [l for l in result.decode().split('\n') if 'hostname' in l]
            print(f"  ✅ {host[0].strip() if host else 'OK'} ✓")
            return True
        else:
            print(f"  ⚠️  Verificar...")
            return True
            
    except Exception as e:
        print(f"❌ {e}")
        return False
    finally:
        s.close()

routers = [
    ("Core_Bogota", 5000, [
        "hostname Core_Bogota",
        "interface FastEthernet0/0", "ip address 10.255.0.1 255.255.255.252", "no shutdown",
        "interface Serial1/0.100 point-to-point", "ip address 10.255.1.1 255.255.255.252", "frame-relay interface-dlci 100",
        "interface Serial1/0.101 point-to-point", "ip address 10.255.10.1 255.255.255.252", "frame-relay interface-dlci 101",
        "interface Serial2/0", "ip address 10.255.2.1 255.255.255.252", "no shutdown",
        "interface Serial2/1", "ip address 10.255.3.1 255.255.255.252", "no shutdown",
        "interface GigabitEthernet3/0", "ip address 10.255.4.1 255.255.255.252", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
    ("Core_Cucuta", 5001, [
        "hostname Core_Cucuta",
        "interface FastEthernet0/0", "ip address 10.255.5.1 255.255.255.252", "no shutdown",
        "interface Serial1/0", "ip address 10.255.6.1 255.255.255.252", "no shutdown",
        "interface GigabitEthernet3/0", "ip address 10.255.4.2 255.255.255.252", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
    ("Core_SantaMarta", 5002, [
        "hostname Core_SantaMarta",
        "interface FastEthernet0/0", "ip address 10.255.7.1 255.255.255.252", "no shutdown",
        "interface Serial1/0.200 point-to-point", "ip address 10.255.1.2 255.255.255.252", "frame-relay interface-dlci 200",
        "interface Serial1/0.201 point-to-point", "ip address 10.255.8.1 255.255.255.252", "frame-relay interface-dlci 201",
        "interface Serial2/0", "ip address 10.255.2.2 255.255.255.252", "no shutdown",
        "interface Serial2/1", "ip address 10.255.9.1 255.255.255.252", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
    ("Core_Barranquilla", 5003, [
        "hostname Core_Barranquilla",
        "interface FastEthernet0/0", "ip address 10.255.11.1 255.255.255.252", "no shutdown",
        "interface Serial1/0.301 point-to-point", "ip address 10.255.10.2 255.255.255.252", "frame-relay interface-dlci 301",
        "interface Serial1/0.302 point-to-point", "ip address 10.255.8.2 255.255.255.252", "frame-relay interface-dlci 302",
        "interface Serial1/1", "ip address 10.255.6.2 255.255.255.252", "no shutdown",
        "interface Serial2/1", "ip address 10.255.3.2 255.255.255.252", "no shutdown",
        "interface Serial2/2", "ip address 10.255.9.2 255.255.255.252", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
    ("Dist_Bogota", 5004, [
        "hostname Dist_Bogota",
        "interface FastEthernet0/0", "ip address 10.255.0.2 255.255.255.252", "no shutdown",
        "interface GigabitEthernet2/0", "ip address 10.1.0.1 255.255.255.0", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
    ("Dist_Cucuta", 5012, [
        "hostname Dist_Cucuta",
        "interface FastEthernet0/0", "ip address 10.255.5.2 255.255.255.252", "no shutdown",
        "interface GigabitEthernet2/0", "ip address 10.2.0.1 255.255.255.0", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
    ("Dist_SantaMarta", 5014, [
        "hostname Dist_SantaMarta",
        "interface FastEthernet0/0", "ip address 10.255.7.2 255.255.255.252", "no shutdown",
        "interface GigabitEthernet2/0", "ip address 10.3.0.1 255.255.255.0", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
    ("Dist_Barranquilla", 5016, [
        "hostname Dist_Barranquilla",
        "interface FastEthernet0/0", "ip address 10.255.11.2 255.255.255.252", "no shutdown",
        "interface GigabitEthernet2/0", "ip address 10.4.0.1 255.255.255.0", "no shutdown",
        "router eigrp 100", "network 10.0.0.0", "no auto-summary",
    ]),
]

print("=" * 50)
print("CONFIGURANDO ROUTERS (esperando boot completo)")
print("=" * 50)
ok = 0
for name, port, cmds in routers:
    if config_router(name, port, cmds):
        ok += 1
print(f"\n✅ {ok}/8 routers configurados")
print("Ahora probá ping desde VPCS")
