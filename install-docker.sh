#!/bin/bash

set -e

echo "======================================"
echo "開始安裝 Docker"
echo "======================================"

# 目前執行使用者
CURRENT_USER=${SUDO_USER:-$USER}

echo "目前使用者: $CURRENT_USER"

##########################################
# 更新套件
##########################################

echo
echo "更新 apt..."
sudo apt update


##########################################
# 移除舊 Docker 套件
##########################################

echo
echo "移除舊 Docker 套件..."

OLD_PACKAGES=$(dpkg --get-selections \
    docker.io \
    docker-compose \
    docker-compose-v2 \
    docker-doc \
    podman-docker \
    containerd \
    runc 2>/dev/null | awk '{print $1}')

if [ -n "$OLD_PACKAGES" ]; then
    sudo apt remove -y $OLD_PACKAGES
else
    echo "沒有舊 Docker 套件"
fi


##########################################
# 安裝必要套件
##########################################

echo
echo "安裝必要套件..."

sudo apt install -y \
    ca-certificates \
    curl


##########################################
# Docker 官方 Repository
##########################################

echo
echo "設定 Docker 官方 Repository..."

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc


sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF


##########################################
# 安裝 Docker
##########################################

echo
echo "安裝 Docker Engine..."

sudo apt update

sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin


##########################################
# 啟動 Docker
##########################################

echo
echo "啟動 Docker..."

sudo systemctl enable docker
sudo systemctl start docker


##########################################
# Docker 群組設定
##########################################

echo
echo "設定 Docker 群組..."


if getent group docker > /dev/null; then
    echo "docker 群組已存在"
else
    echo "建立 docker 群組"
    sudo groupadd docker
fi


if id -nG "$CURRENT_USER" | grep -qw docker; then
    echo "使用者 $CURRENT_USER 已在 docker 群組"
else
    echo "加入使用者 $CURRENT_USER 到 docker 群組"

    sudo usermod -aG docker "$CURRENT_USER"

    GROUP_ADDED=true
fi


##########################################
# 立即套用 Docker 群組
##########################################

if [ "$GROUP_ADDED" = true ]; then

    echo
    echo "重新載入 docker 群組..."

    echo
    echo "請注意："
    echo "目前 shell 將重新載入 docker 群組"

    exec sudo -u "$CURRENT_USER" sg docker "$SHELL"

fi


##########################################
# 狀態確認
##########################################

echo
echo "======================================"
echo "Docker 群組狀態"
echo "======================================"

echo "使用者:"
echo "$CURRENT_USER"

echo
echo "群組:"
id -nG "$CURRENT_USER"


echo
if id -nG "$CURRENT_USER" | grep -qw docker; then
    echo "✅ Docker 群組設定完成"
else
    echo "⚠ Docker 群組尚未生效"
fi


##########################################
# Docker 測試
##########################################

echo
echo "======================================"
echo "Docker 測試"
echo "======================================"


docker --version

echo

docker compose version


echo

docker ps


echo
echo "======================================"
echo "Docker 安裝完成"
echo "======================================"
