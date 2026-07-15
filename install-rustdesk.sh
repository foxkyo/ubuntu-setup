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

echo
echo "取得最新 RustDesk 下載網址..."

DEB_URL=$(
    curl -fsSL https://api.github.com/repos/rustdesk/rustdesk/releases/latest \
    | grep '"browser_download_url"' \
    | grep '\.deb"' \
    | grep -Ei 'amd64|x86_64' \
    | cut -d '"' -f4 \
    | head -n1
)

if [ -z "$DEB_URL" ]; then
    echo "❌ 找不到 RustDesk Debian 套件"
    exit 1
fi

echo "下載："
echo "$DEB_URL"

cd /tmp
rm -f rustdesk.deb

wget -O rustdesk.deb "$DEB_URL"

echo
echo "安裝 RustDesk..."

sudo apt install -y ./rustdesk.deb

echo
echo "啟用 RustDesk Service..."

if systemctl list-unit-files | grep -q "^rustdesk.service"; then
    sudo systemctl enable rustdesk.service
    sudo systemctl start rustdesk.service
else
    echo "未找到 rustdesk.service，略過。"
fi

echo
echo "======================================"
echo "RustDesk 安裝完成"
echo
echo "啟動方式："
echo "  rustdesk"
echo
echo "若有 Service："
echo "  systemctl status rustdesk"
echo
echo "======================================"
