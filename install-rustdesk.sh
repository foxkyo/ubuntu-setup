#!/usr/bin/env bash
set -e

echo "======================================"
echo "安裝 RustDesk"
echo "======================================"

# 檢查是否已安裝
if command -v rustdesk >/dev/null 2>&1; then
    echo "RustDesk 已安裝，略過"
    exit 0
fi


# 安裝必要工具
sudo apt update
sudo apt install -y wget curl


# 取得最新 RustDesk Debian 套件
echo "下載 RustDesk..."

cd /tmp

wget -O rustdesk.deb \
https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk-x86_64.deb


# 安裝
echo "安裝 RustDesk..."

sudo apt install -y ./rustdesk.deb


# 啟用服務
echo "啟用 RustDesk Service..."

sudo systemctl enable rustdesk.service || true
sudo systemctl start rustdesk.service || true


echo
echo "======================================"
echo "RustDesk 安裝完成"
echo
echo "啟動:"
echo "  rustdesk"
echo
echo "查看服務:"
echo "  systemctl status rustdesk"
echo
echo "======================================"
