#!/bin/bash

set -e

echo "========================================"
echo " Ubuntu Server → Ubuntu Desktop Minimal"
echo "========================================"

if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行：sudo ./install-desktop.sh"
    exit 1
fi

echo
echo "== 更新系統 =="
apt update
apt -y upgrade

echo
echo "== 安裝 Ubuntu Desktop Minimal =="
DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop-minimal

echo
echo "== 安裝軟體中心 =="
apt install -y \
    app-center \
    gnome-software \
    gnome-software-plugin-snap

echo
echo "== 安裝繁體中文語言包 =="
apt install -y \
    language-pack-zh-hant \
    language-pack-gnome-zh-hant \
    language-selector-common \
    language-selector-gnome

echo
echo "== 安裝所有繁體中文支援套件 =="

if command -v check-language-support >/dev/null 2>&1; then
    MISSING="$(check-language-support -l zh-hant)"
    if [ -n "$MISSING" ]; then
        apt install -y $MISSING
    fi
fi

echo
echo "== 安裝中文字型 =="
apt install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra

echo
echo "== 安裝中文輸入法 =="
apt install -y \
    ibus \
    ibus-chewing

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
echo "== 關閉 Wayland（方便遠端控制） =="

if [ -f /etc/gdm3/custom.conf ]; then
    sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf

    grep -q '^WaylandEnable=false' /etc/gdm3/custom.conf || \
        echo "WaylandEnable=false" >> /etc/gdm3/custom.conf
fi

echo
echo "== 更新 initramfs =="
update-initramfs -u

echo
echo "========================================"
echo " 安裝完成！"
echo
echo "請重新開機："
echo
echo "sudo reboot"
echo "========================================"
