# ===========================================
# Makefile - Proyecto Final Redes 2025967
# Comandos útiles para gestionar el proyecto
# ===========================================

.PHONY: help build up down restart status logs shell clean info

help:
	@echo ""
	@echo "=== PROYECTO FINAL REDES 2025967 ==="
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  make build    - Construir imagen Docker"
	@echo "  make up       - Levantar contenedor (docker compose up -d)"
	@echo "  make down     - Detener contenedor"
	@echo "  make restart  - Reiniciar contenedor"
	@echo "  make status   - Ver estado del contenedor"
	@echo "  make logs     - Ver logs en tiempo real"
	@echo "  make shell    - Acceder al shell del contenedor"
	@echo "  make ps       - Ver procesos del contenedor"
	@echo "  make info     - Información del proyecto"
	@echo "  make test     - Probar conectividad de la red"
	@echo ""

build:
	docker compose -f docker/docker-compose.yml build

up:
	docker compose -f docker/docker-compose.yml up -d
	@echo "Esperando que GNS3 inicie..."
	@sleep 5
	@curl -s http://localhost:3080/v2/version | python3 -m json.tool 2>/dev/null || echo "Esperando... intenta 'make status'"

down:
	docker compose -f docker/docker-compose.yml down

restart: down up

status:
	@echo "=== Estado del contenedor ==="
	docker ps --filter name=gns3-proyecto-final --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "=== Healthcheck ==="
	@curl -s http://localhost:3080/v2/version 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "GNS3 no responde aun"

logs:
	docker logs -f gns3-proyecto-final

shell:
	docker exec -it gns3-proyecto-final /bin/bash

ps:
	docker exec gns3-proyecto-final ps aux

info:
	@echo "============================================"
	@echo " INFORMACION DEL PROYECTO"
	@echo "============================================"
	@echo "API GNS3:    http://localhost:3080/v2/version"
	@echo "Proyecto:    /proyecto/Proyecto-Final-Redes.gns3"
	@echo "Imagenes:    /proyecto/imagenes/"
	@echo "  IOS:       $$(ls /proyecto/imagenes/IOS/*.image 2>/dev/null | wc -l) imagenes"
	@echo "  IOU:       $$(ls /proyecto/imagenes/IOU/*.bin 2>/dev/null | wc -l) imagenes"
	@echo "  QEMU:      $$(ls /proyecto/imagenes/QEMU/Servers/*.qcow2 2>/dev/null | wc -l) discos"
	@echo "Total:       $$(du -sh /proyecto/ 2>/dev/null | cut -f1)"

test:
	@echo "=== Test de conectividad ==="
	@echo "1. Verificando API GNS3..."
	@curl -s http://localhost:3080/v2/version 2>/dev/null | python3 -m json.tool 2>/dev/null || { echo "❌ GNS3 no responde"; exit 1; }
	@echo "✅ API funcionando"
	@echo ""
	@echo "2. Verificando templates..."
	@curl -s http://localhost:3080/v2/templates 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'✅ {len(d)} templates disponibles: {[t[\"name\"] for t in d]}')" 2>/dev/null || echo "⚠️ No se pudieron listar templates"
	@echo ""
	@echo "3. Verificando KVM..."
	@docker exec gns3-proyecto-final kvm-ok 2>/dev/null | head -3 || echo "⚠️ kvm-ok no disponible"
	@echo ""
	@echo "=== Test completado ==="
