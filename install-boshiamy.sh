#!/bin/bash

set -e

echo "======================================"
echo "安裝嘸蝦米輸入法 (Boshiamy)"
echo "使用 Fcitx5"
echo "Ubuntu 26.04"
echo "======================================"

if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行"
    echo "sudo ./install-boshiamy.sh"
    exit 1
fi


echo
echo "== 更新套件列表 =="

apt update


echo
echo "== 安裝 Fcitx5 相關套件 =="

apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-qt5 \
    fcitx5-chewing \
    fcitx-module-quickphrase-editor5 \
    libime-bin


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
echo "== 設定使用者 autostart =="

USER_HOME=$(eval echo ~${SUDO_USER})

mkdir -p "${USER_HOME}/.config/autostart"


cat > "${USER_HOME}/.config/autostart/fcitx5.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Fcitx5
Exec=fcitx5 -d
Terminal=false
StartupNotify=false
EOF


chown -R ${SUDO_USER}:${SUDO_USER} "${USER_HOME}/.config"


echo
echo "== 初始化 Fcitx5 =="

sudo -u ${SUDO_USER} fcitx5 -d || true


echo
echo "======================================"
echo "Fcitx5 安裝完成"
echo
echo "下一步："
echo "1. 登出再登入"
echo "2. 執行：fcitx5-configtool"
echo "3. 加入嘸蝦米輸入法"
echo
echo "檢查狀態："
echo "fcitx5-diagnose"
echo "======================================"
