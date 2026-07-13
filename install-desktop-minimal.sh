#!/bin/bash

set -e

echo "========================================"
echo " Ubuntu Server → Ubuntu Desktop Minimal"
echo " Ubuntu 26.04 (正體中文優化版)"
echo "========================================"

# 檢查權限
if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行：sudo ./install-desktop-minimal.sh"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo
echo "== 1. 先行設定語系與時區 =="
# 先產生語系，避免後續套件安裝時抓不到正確 Locale
locale-gen zh_TW.UTF-8
update-locale LANG=zh_TW.UTF-8 LANGUAGE=zh_TW:zh
timedatectl set-timezone Asia/Taipei

echo
echo "== 2. 更新系統來源 =="
apt update
apt -y upgrade

echo
echo "== 3. 安裝中文字型 =="
# 在安裝瀏覽器與桌面之前，先讓系統擁有中文字型
apt install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-arphic-ukai \
    fonts-arphic-uming

fc-cache -fv

echo
echo "== 4. 安裝 Ubuntu Desktop Minimal =="
apt install -y \
    ubuntu-desktop-minimal \
    ubuntu-session \
    gdm3

echo
echo "== 5. 安裝軟體管理中心與 Firefox =="
apt install -y \
    snapd \
    gnome-software \
    gnome-software-plugin-snap

systemctl enable --now snapd

if ! snap list snap-store >/dev/null 2>&1; then
    echo "== 安裝 Ubuntu App Center =="
    snap install snap-store
fi

# 確保 Firefox 有中文語系支援
apt install -y firefox-locale-zh-hant || true

echo
echo "== 6. 安裝繁體中文語言包 =="
apt install -y \
    language-pack-zh-hant \
    language-pack-gnome-zh-hant \
    language-selector-common \
    language-selector-gnome

echo
echo "== 7. 補齊中文套件 =="
if command -v check-language-support >/dev/null 2>&1; then
    MISSING=$(check-language-support -l zh-hant)
    if [ -n "$MISSING" ]; then
        apt install -y $MISSING
    fi
fi

echo
echo "== 8. 安裝 Fcitx5 中文輸入框架 =="
apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-chinese-addons \
    fcitx-module-quickphrase-editor5

echo
echo "== 9. 設定 Fcitx5 環境變數 =="
cat >/etc/profile.d/fcitx5.sh <<EOF
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF

chmod 644 /etc/profile.d/fcitx5.sh

echo
echo "== 10. 設定 GDM 與系統核心 =="
systemctl enable gdm3
update-initramfs -u

echo
echo "== 11. 清除防呆 Snap 字型快取 =="
# 預先為當前使用者與未來登入的使用者清除可能殘留的 Snap 字型快取
rm -rf ~/.var/app/org.mozilla.firefox/.cache/fontconfig 2>/dev/null || true
rm -rf ~/snap/firefox/common/.cache/fontconfig 2>/dev/null || true

echo "========================================"
echo " Ubuntu Desktop Minimal 安裝完成！"
echo
echo "請直接重新開機以套入全新語系環境："
echo "sudo reboot"
echo
echo "登入桌面後步驟："
echo "1. 確認系統介面已成「繁體中文」"
echo "2. 開啟 Fcitx5 設定"
echo "3. 加入中文輸入法"
echo "4. 執行你的嘸蝦米安裝腳本 (./install-boshiamy.sh)"
echo "========================================"
