#!/bin/bash

set -e

echo "======================================"
echo "安裝嘸蝦米輸入法 (Boshiamy)"
echo "使用 Fcitx5"
echo "Ubuntu 26.04"
echo "======================================"

if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行"
    echo
    echo "sudo ./install-boshiamy.sh"
    exit 1
fi

if [[ -z "${SUDO_USER:-}" ]]; then
    echo "請使用 sudo 執行，不要直接使用 root 執行。"
    exit 1
fi

USER_NAME="$SUDO_USER"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

echo
echo "使用者：$USER_NAME"
echo "家目錄：$USER_HOME"

echo
echo "== 更新套件列表 =="

apt update


echo
echo "== 安裝 Fcitx5 =="

apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-qt5 \
    fcitx5-table \
    fcitx5-table-boshiamy


echo
echo "== 安裝中文字型 =="

apt install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-arphic-ukai \
    fonts-arphic-uming


echo
echo "== 設定 Fcitx5 環境變數 =="

cat > /etc/profile.d/fcitx5.sh <<'EOF'
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF

chmod 644 /etc/profile.d/fcitx5.sh


echo
echo "== 設定 Fcitx5 自動啟動 =="

mkdir -p "$USER_HOME/.config/autostart"

cat > "$USER_HOME/.config/autostart/org.fcitx.Fcitx5.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx 5
Comment=Fcitx 5 Input Method
Exec=fcitx5 -d
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

chown "$USER_NAME:$USER_NAME" \
    "$USER_HOME/.config/autostart/org.fcitx.Fcitx5.desktop"


echo
echo "== 設定 Fcitx5 預設輸入法 =="

sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.config/fcitx5"


echo
echo "== 檢查嘸蝦米套件 =="

if dpkg -s fcitx5-table-boshiamy >/dev/null 2>&1; then
    echo "✓ fcitx5-table-boshiamy 已安裝"
else
    echo "✗ 嘸蝦米套件安裝失敗"
    exit 1
fi


echo
echo "== 檢查 Fcitx5 =="

if command -v fcitx5 >/dev/null 2>&1; then
    echo "✓ Fcitx5 已安裝"
else
    echo "✗ Fcitx5 安裝失敗"
    exit 1
fi


echo
echo "== 安裝完成 =="

echo
echo "請執行："
echo
echo "  1. 登出 Ubuntu"
echo "  2. 再重新登入"
echo "  3. 執行："
echo
echo "     fcitx5-configtool"
echo
echo "  4. 點選「+」"
echo "  5. 搜尋「Boshiamy」或「嘸蝦米」"
echo "  6. 加入嘸蝦米"
echo
echo "檢查 Fcitx5："
echo
echo "  fcitx5-diagnose"
echo
echo "======================================"
echo "嘸蝦米 + Fcitx5 安裝完成"
echo "======================================"
