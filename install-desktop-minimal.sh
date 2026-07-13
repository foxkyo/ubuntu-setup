#!/bin/bash

set -e

echo "========================================"
echo " Ubuntu Server → Ubuntu Desktop Minimal"
echo " Ubuntu 26.04 (一次到位・免重裝 Firefox 版)"
echo "========================================"

# 檢查權限
if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行：sudo ./install-desktop-minimal.sh"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo
echo "== 1. 優先設定系統語系與時區 =="
# 在做任何事情之前，先確保系統底層環境變數是 zh_TW
locale-gen zh_TW.UTF-8
update-locale LANG=zh_TW.UTF-8 LANGUAGE=zh_TW:zh
timedatectl set-timezone Asia/Taipei

echo
echo "== 2. 更新系統套件清單 =="
apt update
apt -y upgrade

echo
echo "== 3. 優先安裝正體中文語言包與中文字型 =="
# 【核心修正】在安裝桌面與瀏覽器之前，必須先讓系統具備完整的中文語系與字型
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
echo "== 4. 建立與更新系統字型快取 =="
# 強制讓系統生成正確的字型快取，以便後續安裝的 Snap 軟體可以直接讀取
fc-cache -fv

echo
echo "== 5. 安裝 Ubuntu Desktop Minimal 與預設元件 =="
# 此時環境已完美支援中文，系統預設帶入的 Firefox 將會直接以正常的繁體中文顯示
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

# 確保 Firefox 的中文本地化支援套件一併安裝
apt install -y firefox-locale-zh-hant || true

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
echo "由於字型與語系在安裝桌面之前就已完全就緒，"
echo "重開機登入後直接打開預設的 Firefox 即可正常顯示中文，無需任何額外操作！"
echo "========================================"
