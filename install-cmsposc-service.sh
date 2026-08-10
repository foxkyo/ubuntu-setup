cat > install-cmsposc-service.sh <<'EOF'
#!/usr/bin/env bash

set -e

SERVICE_NAME="cmsposc"
APP_USER="$(id -un)"
APP_HOME="$HOME"
APP_DIR="$APP_HOME/cmsposc"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo
echo "======================================"
echo "   CMSPOSC Laravel Sail 開機服務"
echo "======================================"
echo

echo "使用者：$APP_USER"
echo "專案：$APP_DIR"
echo

# ==================================================
# 檢查 Laravel 專案
# ==================================================

if [ ! -d "$APP_DIR" ]; then
    echo "❌ 找不到專案：$APP_DIR"
    exit 1
fi

if [ ! -x "$APP_DIR/vendor/bin/sail" ]; then
    echo "❌ 找不到 Laravel Sail："
    echo "   $APP_DIR/vendor/bin/sail"
    exit 1
fi

echo "✓ Laravel Sail"

# ==================================================
# 檢查 Docker
# ==================================================

if ! command -v docker >/dev/null 2>&1; then
    echo "❌ 找不到 Docker"
    exit 1
fi

echo "✓ Docker"
echo

# ==================================================
# 建立 systemd service
# ==================================================

echo "🔧 建立 systemd service..."

sudo tee "$SERVICE_FILE" > /dev/null <<SERVICE_EOF
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
Environment=HOME=$APP_HOME

ExecStart=/bin/bash -lc 'cd "$APP_DIR" && ./vendor/bin/sail up -d && ./vendor/bin/sail npm run build'

RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "✓ Service 建立完成"
echo

# ==================================================
# systemd reload
# ==================================================

echo "🔄 重新載入 systemd..."

sudo systemctl daemon-reload

# ==================================================
# 啟用開機自動啟動
# ==================================================

echo "🚀 設定開機自動啟動..."

sudo systemctl enable "$SERVICE_NAME.service"

echo "✓ 已設定開機自動啟動"
echo

# ==================================================
# 啟動測試
# ==================================================

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

    echo "查看錯誤："
    echo
    echo "  journalctl -u $SERVICE_NAME -n 100 --no-pager"
    echo

    exit 1
fi

# ==================================================
# 顯示狀態
# ==================================================

echo "Service 狀態："
echo

systemctl status "$SERVICE_NAME.service" --no-pager

echo
echo "======================================"
echo "   安裝完成"
echo "======================================"
echo

echo "開機時會自動執行："
echo
echo "  cd ~/cmsposc"
echo "  ./vendor/bin/sail up -d"
echo "  ./vendor/bin/sail npm run build"
echo

echo "查看 Log："
echo "  journalctl -u $SERVICE_NAME -n 100 --no-pager"
echo
EOF
