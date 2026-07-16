#!/usr/bin/env python3
"""Configura router vía telnet esperando prompts reales - FINAL"""
import socket
import time
import re
import sys

HOST = "127.0.0.1"
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 5004  # Default Dist_Bogota

# Comandos de configuración
CMDS = [
    "hostname Dist_Bogota",
    "interface FastEthernet0/0",
    "ip address 10.255.0.2 255.255.255.252",
    "no shutdown",
    "interface GigabitEthernet2/0",
    "ip address 10.1.0.1 255.255.255.0",
    "no shutdown",
    "router eigrp 100",
    "network 10.0.0.0",
    "no auto-summary",
]

def read_until(s, prompts, timeout=60):
    """Lee hasta encontrar uno de los prompts o timeout"""
    data = b""
    start = time.time()
    while time.time() - start < timeout:
        try:
            s.settimeout(2)
            chunk = s.recv(4096)
            if not chunk:
                break
            data += chunk
            text = data.decode("utf-8", errors="replace")
            for prompt in prompts:
                if prompt.lower() in text.lower():
                    return text
        except socket.timeout:
            continue
        except Exception as e:
            break
    return data.decode("utf-8", errors="replace")

print(f"🔌 Conectando a {HOST}:{PORT}...")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(60)
s.connect((HOST, PORT))

# 1. Esperar setup dialog o prompt
print("⏳ Esperando boot del router...")
output = read_until(s, [
    "Would you like to enter the initial configuration dialog?",
    "Press RETURN to get started",
    "Press ENTER to get the prompt",
    "Router>", "Router#", ">", "#"
], timeout=50)

if "Would you like to enter the initial configuration dialog?" in output:
    print("  → Setup detectado, respondiendo 'no'")
    s.sendall(b"no\n")
    time.sleep(2)
    output += read_until(s, ["Press RETURN to get started", "Press ENTER", "Router>", "Router#", ">", "#"])
    
if "Press RETURN to get started" in output or "Press ENTER to get the prompt" in output:
    print("  → Enviando Enter")
    s.sendall(b"\n")
    time.sleep(2)
    output += read_until(s, ["Router>", "Router#", ">", "#"])

print("  → Entrando a enable mode")
s.sendall(b"enable\n")
time.sleep(1.5)
output += read_until(s, ["Router#", "#"])

print("  → Entrando a configure terminal")
s.sendall(b"configure terminal\n")
time.sleep(1.5)
output += read_until(s, ["(config)#", "#"])

# 3. Enviar comandos de config
print("  → Aplicando configuración...")
for i, cmd in enumerate(CMDS, 1):
    print(f"    [{i}/{len(CMDS)}] {cmd}")
    s.sendall((cmd + "\n").encode())
    time.sleep(0.15)

# 4. Guardar
print("  → Guardando configuración")
s.sendall(b"end\n")
time.sleep(1)
s.sendall(b"write memory\n")
time.sleep(2)

# 5. Verificar
s.sendall(b"\nshow ip interface brief\n")
time.sleep(2)
result = b""
try:
    while True:
        s.settimeout(3)
        c = s.recv(4096)
        if not c: break
        result += c
except:
    pass

print()
print("=" * 50)
print("RESULTADO:")
print(result.decode("utf-8", errors="replace"))
print("=" * 50)

if b"up" in result:
    print("✅ Router CONFIGURADO correctamente!")
else:
    print("⚠️  Verificar manualmente")

s.close()
