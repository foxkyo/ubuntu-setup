#!/bin/bash

set -e

echo "========================================"
echo " Ubuntu Server → Ubuntu Desktop Minimal"
echo " Ubuntu 26.04"
echo "========================================"


if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行：sudo ./install-desktop-minimal.sh"
    exit 1
fi


export DEBIAN_FRONTEND=noninteractive


echo
echo "== 更新系統 =="

apt update

apt -y upgrade



echo
echo "== 安裝 Ubuntu Desktop Minimal =="

apt install -y \
    ubuntu-desktop-minimal \
    ubuntu-session \
    gdm3



echo
echo "== 安裝軟體管理中心 =="

apt install -y \
    snapd \
    gnome-software \
    gnome-software-plugin-snap


systemctl enable --now snapd


if ! snap list snap-store >/dev/null 2>&1; then

    echo "== 安裝 Ubuntu App Center =="

    snap install snap-store

fi



echo
echo "== 安裝繁體中文語言 =="

apt install -y \
    language-pack-zh-hant \
    language-pack-gnome-zh-hant \
    language-pack-kde-zh-hant \
    language-selector-common \
    language-selector-gnome



echo
echo "== 補齊中文套件 =="

if command -v check-language-support >/dev/null 2>&1; then

    MISSING=$(check-language-support -l zh-hant)

    if [ -n "$MISSING" ]; then
        apt install -y $MISSING
    fi

fi



echo
echo "== 安裝 Firefox 中文 =="

apt install -y \
    firefox-locale-zh-hant



echo
echo "== 安裝中文字型 =="

apt install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-arphic-ukai \
    fonts-arphic-uming \
    fonts-kacst \
    fonts-khmeros-core


fc-cache -fv



echo
echo "== 安裝 Fcitx5 中文輸入框架 =="

apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-module-quickphrase-editor



echo
echo "== 設定 Fcitx5 =="

cat >/etc/environment <<EOF
LANG=zh_TW.UTF-8
LANGUAGE=zh_TW:zh
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF



echo
echo "== 設定語系 =="

locale-gen zh_TW.UTF-8


update-locale \
    LANG=zh_TW.UTF-8 \
    LANGUAGE=zh_TW:zh



echo
echo "== 設定時區 =="

timedatectl set-timezone Asia/Taipei



echo
echo "== 設定 GDM =="

systemctl enable gdm3



echo
echo "== 關閉 Wayland（RustDesk 遠端控制） =="

GDM_CONFIG="/etc/gdm3/custom.conf"


if [ -f "$GDM_CONFIG" ]; then

    sed -i '/^WaylandEnable=/d' "$GDM_CONFIG"

    if grep -q "^\[daemon\]" "$GDM_CONFIG"; then
        sed -i '/^\[daemon\]/a WaylandEnable=false' "$GDM_CONFIG"
    else
        echo -e "\n[daemon]\nWaylandEnable=false" >> "$GDM_CONFIG"
    fi

fi



echo
echo "== 更新 initramfs =="

update-initramfs -u



echo
echo "========================================"
echo " Ubuntu Desktop Minimal 安裝完成"
echo
echo "請重新開機:"
echo
echo "sudo reboot"
echo
echo "登入後:"
echo
echo "1. 確認 Firefox 中文"
echo "2. 開啟 Fcitx5"
echo "3. 執行嘸蝦米安裝腳本"
echo
echo "./install-boshiamy.sh"
echo
echo "========================================"
