cat > install-cmspos-all.sh <<'EOF'
#!/usr/bin/env bash

set -e

SERVICE_NAME="cmsposc"
APP_USER="$(id -un)"
APP_HOME="$HOME"
APP_DIR="$APP_HOME/cmsposc"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

TAURI_APP="/usr/bin/app"
START_SCRIPT="$APP_HOME/.local/bin/start-cmspos"
AUTOSTART_DIR="$APP_HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/CMSPOS.desktop"

echo
echo "======================================"
echo "   CMSPOS 一鍵安裝"
echo "======================================"
echo

echo "使用者：$APP_USER"
echo "專案：$APP_DIR"
echo "Tauri：$TAURI_APP"
echo

# ==================================================
# 檢查 Laravel Sail
# ==================================================

if [ ! -d "$APP_DIR" ]; then
    echo "❌ 找不到 Laravel 專案："
    echo "   $APP_DIR"
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

# ==================================================
# 檢查 Tauri
# ==================================================

if [ ! -x "$TAURI_APP" ]; then
    echo "❌ 找不到 Tauri："
    echo "   $TAURI_APP"
    exit 1
fi

echo "✓ Tauri"

# ==================================================
# 建立 Laravel Sail systemd service
# ==================================================

echo
echo "======================================"
echo "   建立 Laravel Sail Service"
echo "======================================"
echo

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

echo "✓ cmsposc.service 建立完成"

# ==================================================
# systemd reload + enable
# ==================================================

sudo systemctl daemon-reload

sudo systemctl enable "$SERVICE_NAME.service"

echo "✓ cmsposc.service 已設定開機啟動"

# ==================================================
# 啟動 Laravel Sail
# ==================================================

echo
echo "======================================"
echo "   啟動 Laravel Sail"
echo "======================================"
echo

if sudo systemctl start "$SERVICE_NAME.service"; then
    echo
    echo "✓ Laravel Sail 啟動成功"
else
    echo
    echo "❌ Laravel Sail 啟動失敗"
    echo
    echo "查看錯誤："
    echo
    echo "  journalctl -u $SERVICE_NAME -n 100 --no-pager"
    exit 1
fi

# ==================================================
# 建立 Tauri 啟動腳本
# ==================================================

echo
echo "======================================"
echo "   建立 Tauri 自動啟動"
echo "======================================"
echo

mkdir -p "$APP_HOME/.local/bin"

cat > "$START_SCRIPT" <<SCRIPT_EOF
#!/usr/bin/env bash

# 等待 Laravel Sail service 完成
while ! systemctl is-active --quiet cmsposc.service; do
    sleep 1
done

# 再等待一下，確保 Laravel / Docker 已穩定
sleep 2

# 啟動 Tauri CMSPOS
exec /usr/bin/app
SCRIPT_EOF

chmod +x "$START_SCRIPT"

echo "✓ Tauri 啟動腳本：$START_SCRIPT"

# ==================================================
# 建立 Ubuntu Autostart
# ==================================================

mkdir -p "$AUTOSTART_DIR"

cat > "$DESKTOP_FILE" <<DESKTOP_EOF
[Desktop Entry]
Type=Application
Name=CMSPOS
Comment=CMSPOS Tauri POS
Exec=$START_SCRIPT
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
DESKTOP_EOF

echo "✓ Ubuntu Autostart：$DESKTOP_FILE"

# ==================================================
# 完成
# ==================================================

echo
echo "======================================"
echo "   ✅ CMSPOS 一鍵安裝完成"
echo "======================================"
echo

echo "Laravel Sail："
echo "  systemctl status cmsposc"

echo
echo "Docker："
echo "  cd ~/cmsposc && ./vendor/bin/sail ps"

echo
echo "Tauri："
echo "  $TAURI_APP"

echo
echo "重新開機測試："
echo "  sudo reboot"

echo
echo "開機流程："
echo
echo "  Ubuntu"
echo "    ↓"
echo "  Docker"
echo "    ↓"
echo "  cmsposc.service"
echo "    ↓"
echo "  Sail up -d"
echo "    ↓"
echo "  Sail npm run build"
echo "    ↓"
echo "  Ubuntu 登入"
echo "    ↓"
echo "  CMSPOS Tauri"
echo
EOF

chmod +x install-cmspos-all.sh
./install-cmspos-all.sh
