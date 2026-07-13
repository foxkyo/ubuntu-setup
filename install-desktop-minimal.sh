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
    firefox-locale-zh-hant || true



echo
echo "== 安裝中文字型 =="

apt install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-arphic-ukai \
    fonts-arphic-uming


fc-cache -fv



echo
echo "== 安裝 Fcitx5 中文輸入框架 =="

apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-chinese-addons \
    fcitx-module-quickphrase-editor5



echo
echo "== 設定 Fcitx5 =="


cat >/etc/profile.d/fcitx5.sh <<EOF
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF


chmod 644 /etc/profile.d/fcitx5.sh



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
echo "1. 確認系統語言：繁體中文"
echo "2. 開啟 Fcitx5 設定"
echo "3. 加入中文輸入法"
echo "4. 執行嘸蝦米安裝腳本"
echo
echo "./install-boshiamy.sh"
echo
echo "========================================"
