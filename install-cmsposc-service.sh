cat > install-cmspos-autostart.sh <<'EOF'
#!/usr/bin/env bash

set -e

APP_USER="$(id -un)"
APP_HOME="$HOME"
TAURI_APP="/usr/bin/app"
START_SCRIPT="$APP_HOME/.local/bin/start-cmspos"
AUTOSTART_DIR="$APP_HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/CMSPOS.desktop"

echo
echo "======================================"
echo "   CMSPOS Tauri 自動啟動安裝"
echo "======================================"
echo

echo "使用者：$APP_USER"
echo "Tauri：$TAURI_APP"
echo

# ==================================================
# 檢查 Tauri
# ==================================================

if [ ! -x "$TAURI_APP" ]; then
    echo "❌ 找不到 Tauri 執行檔："
    echo "   $TAURI_APP"
    exit 1
fi

echo "✓ Tauri 執行檔"

# ==================================================
# 檢查 CMSPOS Sail service
# ==================================================

if ! systemctl list-unit-files cmsposc.service >/dev/null 2>&1; then
    echo "❌ 找不到 cmsposc.service"
    echo
    echo "請先完成 Laravel Sail 開機服務設定。"
    exit 1
fi

echo "✓ cmsposc.service"

# ==================================================
# 建立啟動腳本
# ==================================================

echo
echo "🔧 建立 CMSPOS 啟動腳本..."

mkdir -p "$APP_HOME/.local/bin"

cat > "$START_SCRIPT" <<SCRIPT_EOF
#!/usr/bin/env bash

# 等待 Laravel Sail 啟動完成
while ! systemctl is-active --quiet cmsposc.service; do
    sleep 1
done

# 再稍微等待服務穩定
sleep 2

# 啟動 Tauri CMSPOS
exec /usr/bin/app
SCRIPT_EOF

chmod +x "$START_SCRIPT"

echo "✓ $START_SCRIPT"

# ==================================================
# 建立 autostart
# ==================================================

echo
echo "🔧 建立 Ubuntu 自動啟動設定..."

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

echo "✓ $DESKTOP_FILE"

# ==================================================
# 完成
# ==================================================

echo
echo "======================================"
echo "   ✅ CMSPOS 自動啟動設定完成"
echo "======================================"
echo

echo "開機流程："
echo
echo "  Ubuntu 開機"
echo "      ↓"
echo "  Docker"
echo "      ↓"
echo "  cmsposc.service"
echo "      ↓"
echo "  Sail up -d"
echo "      ↓"
echo "  Sail npm run build"
echo "      ↓"
echo "  Ubuntu 登入桌面"
echo "      ↓"
echo "  等待 cmsposc.service"
echo "      ↓"
echo "  /usr/bin/app"
echo "      ↓"
echo "  CMSPOS"
echo

echo "目前設定："
echo
echo "  Tauri：$TAURI_APP"
echo "  啟動腳本：$START_SCRIPT"
echo "  Autostart：$DESKTOP_FILE"
echo

echo "請重新登入 Ubuntu 或重新開機測試。"
echo
EOF

chmod +x install-cmspos-autostart.sh
./install-cmspos-autostart.sh
