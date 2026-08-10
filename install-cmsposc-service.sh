#!/usr/bin/env bash

set -euo pipefail

# ==================================================
# CMSPOSC Laravel Sail 開機自動啟動安裝程式
#
# 專案位置：
#   ~/cmsposc
#
# 開機後：
#   1. 等待 Docker
#   2. sail up -d
#   3. npm run build
# ==================================================

SERVICE_NAME="cmsposc"
APP_DIR="$HOME/cmsposc"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

CURRENT_USER="$(id -un)"
CURRENT_HOME="$HOME"

echo
echo "======================================"
echo "   CMSPOSC Laravel Sail 開機服務"
echo "======================================"
echo

echo "使用者：$CURRENT_USER"
echo "Home：$CURRENT_HOME"
echo "專案：$APP_DIR"
echo

# ==================================================
# 檢查 Laravel 專案
# ==================================================

if [ ! -d "$APP_DIR" ]; then
    echo "❌ 找不到專案："
    echo "   $APP_DIR"
    echo
    exit 1
fi

if [ ! -f "$APP_DIR/artisan" ]; then
    echo "❌ $APP_DIR 不是 Laravel 專案"
    echo "   找不到 artisan"
    echo
    exit 1
fi

if [ ! -x "$APP_DIR/vendor/bin/sail" ]; then
    echo "❌ 找不到 Laravel Sail："
    echo "   $APP_DIR/vendor/bin/sail"
    echo
    echo "請確認專案已執行 composer install"
    echo
    exit 1
fi

echo "✓ Laravel 專案"
echo "✓ Laravel Sail"
echo

# ==================================================
# 檢查 Docker
# ==================================================

DOCKER_PATH="$(command -v docker || true)"

if [ -z "$DOCKER_PATH" ]; then
    echo "❌ 找不到 Docker"
    exit 1
fi

echo "Docker：$DOCKER_PATH"

if ! systemctl list-unit-files docker.service >/dev/null 2>&1; then
    echo "❌ 找不到 docker.service"
    exit 1
fi

echo "✓ Docker service"
echo

# ==================================================
# 偵測 Node / npm
# ==================================================

NODE_PATH="$(command -v node || true)"
NPM_PATH="$(command -v npm || true)"

# --------------------------------------------------
# 如果目前找不到，嘗試載入 NVM
# --------------------------------------------------

if [ -z "$NODE_PATH" ] || [ -z "$NPM_PATH" ]; then

    if [ -f "$HOME/.nvm/nvm.sh" ]; then

        echo "偵測到 NVM，載入 NVM..."

        # shellcheck disable=SC1090
        source "$HOME/.nvm/nvm.sh"

        NODE_PATH="$(command -v node || true)"
        NPM_PATH="$(command -v npm || true)"

    fi
fi

if [ -z "$NODE_PATH" ]; then
    echo "❌ 找不到 Node.js"
    exit 1
fi

if [ -z "$NPM_PATH" ]; then
    echo "❌ 找不到 npm"
    exit 1
fi

NODE_VERSION="$(node --version)"
NPM_VERSION="$(npm --version)"

echo "Node：$NODE_PATH"
echo "npm ：$NPM_PATH"
echo "Node 版本：$NODE_VERSION"
echo "npm 版本 ：$NPM_VERSION"
echo

# ==================================================
# 建立 NVM 初始化指令
# ==================================================

NVM_INIT=""

if [ -f "$HOME/.nvm/nvm.sh" ]; then
    NVM_INIT="source '$HOME/.nvm/nvm.sh'; "
fi

# ==================================================
# 建立 systemd service
# ==================================================

echo "🔧 建立 systemd service..."
echo

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=CMSPOSC Laravel Sail POS
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=$CURRENT_USER
WorkingDirectory=$APP_DIR

ExecStart=/bin/bash -lc "${NVM_INIT}cd '$APP_DIR' && ./vendor/bin/sail up -d && npm run build"

RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Service 建立完成"
echo "  $SERVICE_FILE"
echo

# ==================================================
# systemd reload
# ==================================================

echo "🔄 重新載入 systemd..."

sudo systemctl daemon-reload

echo "✓ systemd reload 完成"
echo

# ==================================================
# 啟用開機自動啟動
# ==================================================

echo "🚀 設定開機自動啟動..."

sudo systemctl enable "$SERVICE_NAME.service"

echo "✓ 已設定開機自動啟動"
echo

# ==================================================
# 如果已經執行，先停止
# ==================================================

if systemctl is-active --quiet "$SERVICE_NAME.service"; then

    echo "ℹ️ CMSPOSC service 目前正在執行"
    echo "   先停止後重新測試..."
    echo

    sudo systemctl stop "$SERVICE_NAME.service"

fi

# ==================================================
# 立即測試
# ==================================================

echo "======================================"
echo "   第一次啟動測試"
echo "======================================"
echo

echo "執行："
echo
echo "  cd ~/cmsposc"
echo "  ./vendor/bin/sail up -d"
echo "  npm run build"
echo

if sudo systemctl start "$SERVICE_NAME.service"; then

    echo
    echo "======================================"
    echo "   ✅ CMSPOSC 安裝完成"
    echo "======================================"
    echo

else

    echo
    echo "======================================"
    echo "   ❌ CMSPOSC 啟動失敗"
    echo "======================================"
    echo

    echo "查看錯誤："
    echo
    echo "  journalctl -u $SERVICE_NAME -n 100 --no-pager"
    echo

    exit 1

fi

# ==================================================
# 顯示 Docker 狀態
# ==================================================

echo "Docker Containers："
echo

cd "$APP_DIR"

docker compose ps || true

echo

# ==================================================
# 顯示 Service 狀態
# ==================================================

echo "Service 狀態："
echo

systemctl status "$SERVICE_NAME.service" --no-pager

echo
echo "======================================"
echo "   常用指令"
echo "======================================"
echo

echo "查看 Service："
echo "  systemctl status $SERVICE_NAME"

echo

echo "查看 Log："
echo "  journalctl -u $SERVICE_NAME -n 100 --no-pager"

echo

echo "即時查看 Log："
echo "  journalctl -u $SERVICE_NAME -f"

echo

echo "手動啟動："
echo "  sudo systemctl start $SERVICE_NAME"

echo

echo "手動停止 Service："
echo "  sudo systemctl stop $SERVICE_NAME"

echo

echo "取消開機啟動："
echo "  sudo systemctl disable $SERVICE_NAME"

echo

echo "======================================"
echo "   完成"
echo "======================================"
echo
