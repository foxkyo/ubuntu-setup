#!/usr/bin/env bash
set -e

echo "======================================"
echo "安裝嘸蝦米輸入法 (Boshiamy)"
echo "使用 Fcitx5"
echo "======================================"

# 更新套件
sudo apt update

# 安裝 Fcitx5
sudo apt install -y \
    fcitx5 \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-frontend-gtk4 \
    fcitx5-module-quickphrase-editor \
    im-config

echo
echo "安裝嘸蝦米詞庫..."

# 建立輸入法資料夾
mkdir -p ~/.local/share/fcitx5/table

cd /tmp


# 下載嘸蝦米 Fcitx5 table
wget -O boshiamy.tar.gz \
https://github.com/fcitx/fcitx5-table-extra/releases/latest/download/fcitx5-table-extra.tar.gz


tar xf boshiamy.tar.gz


# 找 boshiamy table
find . -name "*boshiamy*" -exec cp {} ~/.local/share/fcitx5/table/ \;


# 設定 fcitx5
im-config -n fcitx5


echo
echo "======================================"
echo "完成"
echo
echo "請登出再登入"
echo
echo "啟動設定:"
echo "  fcitx5-configtool"
echo
echo "加入:"
echo "  嘸蝦米"
echo
echo "======================================"
