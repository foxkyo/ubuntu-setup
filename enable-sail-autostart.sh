#!/bin/bash

set -e

PROJECT_NAME="${1:-cmspos}"

echo "=== Project: $PROJECT_NAME ==="

echo "=== 啟用 Docker 開機自動啟動 ==="
sudo systemctl enable docker.service docker.socket
sudo systemctl start docker

echo "=== 設定容器自動重啟 ==="

CONTAINERS=$(docker ps -aq --filter "name=${PROJECT_NAME}")

if [ -n "$CONTAINERS" ]; then
    docker update --restart unless-stopped $CONTAINERS
    echo "已設定以下容器："
    docker ps -a --filter "name=${PROJECT_NAME}"
else
    echo "找不到名稱包含 '${PROJECT_NAME}' 的容器"
    exit 1
fi

echo
echo "完成！"
echo "Docker 與 ${PROJECT_NAME} 容器已設定為開機自動啟動。"
