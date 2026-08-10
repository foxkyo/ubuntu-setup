cat > install-cmsposc-service.sh <<'EOF'
#!/usr/bin/env bash

set -e

SERVICE_NAME="cmsposc"
APP_DIR="$HOME/cmsposc"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
APP_USER="$(id -un)"

echo
echo "======================================"
echo "   CMSPOSC Laravel Sail 開機服務"
echo "======================================"
echo

echo "使用者：$APP_USER"
echo "專案：$APP_DIR"
echo

# --------------------------------------------------
# 檢查專案
# --------------------------------------------------

if [ ! -d "$APP_DIR" ]; then
    echo "❌ 找不到專案：$APP_DIR"
    exit 1
fi

if [ ! -x "$APP_DIR/vendor/bin/sail" ]; then
    echo "❌ 找不到 Sail：$APP_DIR/vendor/bin/sail"
    exit 1
fi

echo "✓ Laravel Sail"
echo

# --------------------------------------------------
# 找 Node / npm
# --------------------------------------------------

NODE_PATH="$(command -v node || true)"
NPM_PATH="$(command -v npm || true)"

# NVM
NVM_INIT=""

if [ -f "$HOME/.nvm/nvm.sh" ]; then
    NVM_INIT="source '$HOME/.nvm/nvm.sh'; "

    NODE_PATH="$(bash -lc "source '$HOME/.nvm/nvm.sh' && command -v node")"
    NPM_PATH="$(bash -lc "source '$HOME/.nvm/nvm.sh' && command -v npm")"

    echo "✓ NVM"
fi

if [ -z "$NODE_PATH" ]; then
    echo "❌ 找不到 Node.js"
    exit 1
fi

if [ -z "$NPM_PATH" ]; then
    echo "❌ 找不到 npm"
    exit 1
fi

echo "Node：$NODE_PATH"
echo "npm ：$NPM_PATH"
echo

# --------------------------------------------------
# Docker
# --------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then
    echo "❌ 找不到 Docker"
    exit 1
fi

echo "✓ Docker"
echo

# --------------------------------------------------
# 建立 systemd service
# --------------------------------------------------

echo "🔧 建立 systemd service..."

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=CMSPOSC Laravel Sail
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot

User=$APP_USER
Group=$(id -gn)

WorkingDirectory=$APP_DIR

Environment=HOME=$HOME

ExecStart=/bin/bash -lc "${NVM_INIT}cd '$APP_DIR' && ./vendor/bin/sail up -d && npm run build"

RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Service 建立完成"
echo

# --------------------------------------------------
# systemd reload
# --------------------------------------------------

sudo systemctl daemon-reload

# --------------------------------------------------
# 開機自動啟動
# --------------------------------------------------

sudo systemctl enable "$SERVICE_NAME.service"

echo "✓ 已設定開機自動啟動"
echo

# --------------------------------------------------
# 立即啟動
# --------------------------------------------------

echo "======================================"
echo "   啟動 CMSPOSC"
echo "======================================"
echo

if sudo systemctl start "$SERVICE_NAME.service"; then

    echo
    echo "======================================"
    echo "   ✅ CMSPOSC 啟動成功"
    echo "======================================"
    echo

else

    echo
    echo "======================================"
    echo "   ❌ CMSPOSC 啟動失敗"
    echo "======================================"
    echo

    echo "執行："
    echo
    echo "  systemctl status $SERVICE_NAME"
    echo
    echo "或："
    echo
    echo "  journalctl -u $SERVICE_NAME -n 100 --no-pager"
    echo

    exit 1
fi

# --------------------------------------------------
# 顯示狀態
# --------------------------------------------------

systemctl status "$SERVICE_NAME.service" --no-pager

echo
echo "======================================"
echo "   安裝完成"
echo "======================================"
echo
