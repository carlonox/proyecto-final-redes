# ===========================================
# Dockerfile - GNS3 Server Proyecto Final
# Base: Ubuntu 24.04 con todas las
# dependencias necesarias
# ===========================================
FROM ubuntu:24.04

LABEL maintainer="Proyecto Final Redes 2025967"
LABEL description="GNS3 Server con Dynamips, QEMU, IOU - Proyecto Final Redes"

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Bogota

# ===========================================
# 1. INSTALAR DEPENDENCIAS BASE
# ===========================================
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Agregar PPA de GNS3 para ubridge y dynamips
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:gns3/ppa && \
    apt-get update -qq

RUN apt-get install -y -qq --no-install-recommends \
        # === GNS3 Server ===
        python3 \
        python3-pip \
        python3-setuptools \
        python3-dev \
        python3-venv \
        # === Dynamips ===
        dynamips \
        # === QEMU/KVM ===
        qemu-system-x86 \
        qemu-utils \
        qemu-kvm \
        libvirt-daemon-system \
        # === ubridge ===
        ubridge \
        # === VPCS ===
        vpcs \
        # === Utilidades ===
        curl \
        wget \
        git \
        net-tools \
        iproute2 \
        iputils-ping \
        telnet \
        dnsutils \
        ftp \
        netcat-openbsd \
        traceroute \
        tcpdump \
        vim \
        nano \
        htop \
        iotop \
        # === Virtualización ===
        cpu-checker \
        # === IOU ===
        libc6-i386 \
        # === Herramientas extra ===
        libguestfs-tools \
        genisoimage \
        xz-utils \
        bzip2 \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ===========================================
# 2. INSTALAR GNS3 SERVER
# ===========================================
RUN pip3 install --break-system-packages --no-cache-dir \
        gns3-server==2.2.59

# ===========================================
# 3. CONFIGURAR DIRECTORIOS
# ===========================================
RUN mkdir -p /data/imagenes/IOS && \
    mkdir -p /data/imagenes/IOU && \
    mkdir -p /data/imagenes/QEMU && \
    mkdir -p /data/projects && \
    mkdir -p /data/configs && \
    mkdir -p /data/appliances && \
    mkdir -p /data/symbols && \
    mkdir -p /data/logs && \
    mkdir -p /var/log/gns3 && \
    mkdir -p /home/gns3/.config/GNS3/2.2 && \
    mkdir -p /usr/local/share/gns3

# ===========================================
# 4. CONFIGURAR IOU LICENSE
# ===========================================
RUN echo "[license]\ngns3-server = 3176c959;" > /home/gns3/.iourc

# ===========================================
# 5. CONFIGURAR uBridge PERMISOS
# ===========================================
RUN chmod u+s /usr/bin/ubridge 2>/dev/null || true

# ===========================================
# 6. COPIAR CONFIGURACIONES
# ===========================================
COPY config/gns3_server.conf /home/gns3/.config/GNS3/2.2/gns3_server.conf
COPY config/gns3_controller.conf /home/gns3/.config/GNS3/2.2/gns3_controller.conf

# ===========================================
# 7. SCRIPT DE ENTRYPOINT
# ===========================================
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Puerto de la API
EXPOSE 3080

# Volúmenes
VOLUME ["/data/imagenes", "/data/projects", "/data/configs", "/data/logs"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:3080/v2/version || exit 1

ENTRYPOINT ["/entrypoint.sh"]
