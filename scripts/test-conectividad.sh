#!/bin/bash
# ===========================================
# test-conectividad.sh
# Pruebas de conectividad - Proyecto Final
# Ejecutar DENTRO del container GNS3
# ===========================================
set -e

RESULTADOS="/tmp/pruebas-conectividad.txt"
echo "============================================" > $RESULTADOS
echo " PRUEBAS DE CONECTIVIDAD - $(date)" >> $RESULTADOS
echo "============================================" >> $RESULTADOS
echo "" >> $RESULTADOS

PASS=0
FAIL=0

test_ping() {
    local desc="$1" target="$2"
    echo -n "  → $desc ($target)... "
    if ping -c 2 -W 3 $target >/dev/null 2>&1; then
        echo "✅ OK" >> $RESULTADOS
        echo "✅ OK"
        PASS=$((PASS+1))
    else
        echo "❌ FALLO" >> $RESULTADOS
        echo "❌ FALLO"
        FAIL=$((FAIL+1))
    fi
}

test_dns() {
    local desc="$1" domain="$2" server="$3"
    echo -n "  → $desc ($domain @ $server)... "
    if nslookup $domain $server >/dev/null 2>&1; then
        echo "✅ OK" >> $RESULTADOS
        echo "✅ OK"
        PASS=$((PASS+1))
    else
        echo "❌ FALLO" >> $RESULTADOS
        echo "❌ FALLO"
        FAIL=$((FAIL+1))
    fi
}

test_curl() {
    local desc="$1" url="$2"
    echo -n "  → $desc ($url)... "
    if curl -s -o /dev/null -w "%{http_code}" $url 2>/dev/null | grep -q "200\|301"; then
        echo "✅ OK" >> $RESULTADOS
        echo "✅ OK"
        PASS=$((PASS+1))
    else
        echo "❌ FALLO" >> $RESULTADOS
        echo "❌ FALLO"
        FAIL=$((FAIL+1))
    fi
}

test_ftp() {
    local desc="$1" server="$2"
    echo -n "  → $desc ($server:21)... "
    if echo "quit" | timeout 5 ftp $server 2>/dev/null | grep -q "Connected"; then
        echo "✅ OK" >> $RESULTADOS
        echo "✅ OK"
        PASS=$((PASS+1))
    else
        echo "❌ FALLO" >> $RESULTADOS
        echo "❌ FALLO"
        FAIL=$((FAIL+1))
    fi
}

# ============================================
echo "" | tee -a $RESULTADOS
echo "1. CONECTIVIDAD GATEWAYS" | tee -a $RESULTADOS
echo "------------------------" | tee -a $RESULTADOS
test_ping "Gateway Bogotá" "10.1.0.1"
test_ping "Gateway Cúcuta" "10.2.0.1"
test_ping "Gateway Santa Marta" "10.3.0.1"
test_ping "Gateway Barranquilla" "10.4.0.1"

echo "" | tee -a $RESULTADOS
echo "2. CONECTIVIDAD ROUTERS CORE" | tee -a $RESULTADOS
echo "---------------------------" | tee -a $RESULTADOS
test_ping "Core_Bogota (Dist)" "10.255.0.1"
test_ping "Core_Cucuta (Dist)" "10.255.5.1"
test_ping "Core_SantaMarta (Dist)" "10.255.7.1"
test_ping "Core_Barranquilla (Dist)" "10.255.11.1"

echo "" | tee -a $RESULTADOS
echo "3. CONECTIVIDAD WAN (EIGRP)" | tee -a $RESULTADOS
echo "--------------------------" | tee -a $RESULTADOS
test_ping "Core_Bogota → Core_Cucuta (MetroEth)" "10.255.4.2"
test_ping "Core_Bogota → Core_SM (Frame-Relay)" "10.255.1.2"
test_ping "Core_Bogota → Core_Bar (HDLC)" "10.255.3.2"
test_ping "Core_SM → Core_Bar (Frame-Relay)" "10.255.8.2"
test_ping "Core_SM → Core_Bogota (HDLC)" "10.255.2.1"
test_ping "Core_Cucuta → Core_Bar (MetroEth)" "10.255.6.2"

echo "" | tee -a $RESULTADOS
echo "4. CONECTIVIDAD ROUTING EXTREMO A EXTREMO" | tee -a $RESULTADOS
echo "----------------------------------------" | tee -a $RESULTADOS
test_ping "Bogota → Cucuta LAN (via EIGRP)" "10.2.0.1"
test_ping "Bogota → Santa Marta LAN (via EIGRP)" "10.3.0.1"
test_ping "Bogota → Barranquilla LAN (via EIGRP)" "10.4.0.1"
test_ping "Cucuta → Bogota LAN (via EIGRP)" "10.1.0.1"
test_ping "SM → Barranquilla LAN (via EIGRP)" "10.4.0.1"

echo "" | tee -a $RESULTADOS
echo "5. CONECTIVIDAD A SERVIDORES" | tee -a $RESULTADOS
echo "---------------------------" | tee -a $RESULTADOS
test_ping "SRV_DNS_Bog" "10.1.0.5"
test_ping "SRV_WEB_Cuc" "10.2.0.5"
test_ping "SRV_LDAP_SM" "10.3.0.5"
test_ping "SRV_LDAP_Bar" "10.4.0.5"

echo "" | tee -a $RESULTADOS
echo "6. PRUEBAS DE SERVICIOS" | tee -a $RESULTADOS
echo "----------------------" | tee -a $RESULTADOS
test_dns "Resolución directa" "empresa.local" "10.1.0.5"
test_dns "Resolución www" "www.empresa.local" "10.1.0.5"
test_dns "Resolución servidor WEB" "srv-web-cuc.empresa.local" "10.1.0.5"
test_dns "Resolución inversa" "10.2.0.5" "10.1.0.5"
test_curl "Servicio WEB" "http://10.2.0.5"
test_ftp "Servicio FTP" "10.2.0.5"

echo "" | tee -a $RESULTADOS
echo "7. VERIFICACIÓN EIGRP" | tee -a $RESULTADOS
echo "---------------------" | tee -a $RESULTADOS

# Verificar vecinos EIGRP en cada core
for router in Core_Bogota Core_Cucuta Core_SantaMarta Core_Barranquilla; do
    echo -n "  → $router vecinos EIGRP... "
    if echo "show ip eigrp neighbors" | timeout 5 telnet $router 2>/dev/null | grep -q "10.255"; then
        echo "✅ OK" >> $RESULTADOS
        echo "✅ OK"
        PASS=$((PASS+1))
    else
        echo "❌ FALLO (no se pudo conectar por telnet)" >> $RESULTADOS
        echo "❌ FALLO"
        FAIL=$((FAIL+1))
    fi
done

# ============================================
echo "" | tee -a $RESULTADOS
echo "============================================" >> $RESULTADOS
echo " RESULTADOS FINALES" >> $RESULTADOS
echo "============================================" >> $RESULTADOS
echo "  Pruebas pasadas: $PASS" >> $RESULTADOS
echo "  Pruebas fallidas: $FAIL" >> $RESULTADOS
echo "  Total: $((PASS+FAIL))" >> $RESULTADOS
echo "============================================" >> $RESULTADOS

echo "" | tee -a $RESULTADOS
echo "============================================"
echo " RESULTADOS: $PASS pasadas, $FAIL fallidas"
echo " Log: $RESULTADOS"
echo "============================================"

exit $FAIL
