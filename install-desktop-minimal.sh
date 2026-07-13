#!/bin/bash

set -e

echo "========================================"
echo " Ubuntu Server → Ubuntu Desktop Minimal"
echo " Ubuntu 26.04 (原生預設・完美中文版)"
echo "========================================"

# 檢查權限
if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行：sudo ./install-desktop-minimal.sh"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo
echo "== 1. 優先設定系統語系與時區 =="
# 這是最重要的基石！先讓系統知道我們要用繁體中文
locale-gen zh_TW.UTF-8
update-locale LANG=zh_TW.UTF-8 LANGUAGE=zh_TW:zh
timedatectl set-timezone Asia/Taipei

echo
echo "== 2. 更新系統套件清單 =="
apt update
apt -y upgrade

echo
echo "== 3. 預先安裝正體中文語言包與中文字型 =="
# 在桌面和瀏覽器被裝進來之前，先把字型準備好
apt install -y \
    language-pack-zh-hant \
    language-pack-gnome-zh-hant \
    language-selector-common \
    language-selector-gnome \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-arphic-ukai \
    fonts-arphic-uming

echo
echo "== 4. 刷新系統字型快取 =="
fc-cache -fv

echo
echo "== 5. 安裝桌面環境（此時系統會自動帶入預設的 Firefox） =="
# 我們只管安裝桌面，Firefox 會作為預設元件被自動拉進來
# 因為前面字型跟語系都對了，自動進來的 Firefox 就不會再變豆腐字
apt install -y \
    ubuntu-desktop-minimal \
    ubuntu-session \
    gdm3 \
    snapd \
    gnome-software \
    gnome-software-plugin-snap

systemctl enable --now snapd

if ! snap list snap-store >/dev/null 2>&1; then
    echo "== 安裝 Ubuntu App Center =="
    snap install snap-store
fi

echo
echo "== 6. 補齊其餘中文套件 =="
if command -v check-language-support >/dev/null 2>&1; then
    MISSING=$(check-language-support -l zh-hant)
    if [ -n "$MISSING" ]; then
        apt install -y $MISSING
    fi
fi

echo
echo "== 7. 安裝 Fcitx5 中文輸入框架 =="
apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-chinese-addons \
    fcitx-module-quickphrase-editor5

echo
echo "== 8. 設定 Fcitx5 環境變數 =="
cat >/etc/profile.d/fcitx5.sh <<EOF
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF

chmod 644 /etc/profile.d/fcitx5.sh

echo
echo "== 9. 設定 GDM 與更新系統核心 =="
systemctl enable gdm3
update-initramfs -u

echo "========================================"
echo " Ubuntu Desktop Minimal 安裝完成！"
echo
echo "請直接重新開機："
echo "sudo reboot"
echo
echo "說明："
echo "腳本完全沒有手動去干預或安裝 Firefox，"
echo "完全交由 Ubuntu 預設安裝。重開機後直接打開，中文就會完美顯示！"
echo "========================================"
