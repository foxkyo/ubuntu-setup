#!/usr/bin/env bash
set -e

echo "======================================"
echo "安裝 Visual Studio Code"
echo "======================================"

# 已安裝則跳過
if command -v code >/dev/null 2>&1; then
    echo "VS Code 已安裝，略過"
    exit 0
fi


echo "[1/4] 安裝必要套件"

sudo apt update

sudo apt install -y \
    wget \
    gpg \
    apt-transport-https


echo "[2/4] 加入 Microsoft Repository"

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null


echo "建立 VS Code 軟體來源"

echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
| sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null


echo "[3/4] 安裝 VS Code"

sudo apt update

sudo apt install -y code


echo "[4/4] 完成"

echo
echo "======================================"
echo "VS Code 安裝完成"
echo
echo "啟動:"
echo "  code"
echo
echo "版本:"
echo "  code --version"
echo "======================================"
