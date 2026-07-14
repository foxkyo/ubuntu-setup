#!/bin/bash

sudo apt update

# 安裝 Docker（官方方式）
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker

# 加入目前使用者到 docker 群組
CURRENT_USER=${SUDO_USER:-$USER}

if getent group docker > /dev/null; then
    echo "docker 群組已存在"
else
    echo "docker 群組不存在，建立中..."
    sudo groupadd docker
fi

if id -nG "$CURRENT_USER" | grep -qw docker; then
    echo "使用者 $CURRENT_USER 已經在 docker 群組"
else
    echo "將使用者 $CURRENT_USER 加入 docker 群組..."
    sudo usermod -aG docker "$CURRENT_USER"
    echo "加入完成，重新登入後生效"
fi

echo
echo "======================================"
echo "Docker 群組狀態"
echo "======================================"

echo "目前使用者:"
echo "$CURRENT_USER"

echo
echo "群組列表:"
id -nG "$CURRENT_USER"

echo
if id -nG "$CURRENT_USER" | grep -qw docker; then
    echo "✅ Docker 群組設定完成"
else
    echo "⚠️ 尚未生效，請登出後重新登入"
fi

echo
echo "Docker 測試:"
docker --version

echo
echo "Docker Compose:"
docker compose version
