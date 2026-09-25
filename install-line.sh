cat << 'EOF' > install_line.sh
#!/bin/bash

set -e

echo "=============================================="
echo " LINE + Bottles 安裝環境"
echo " Ubuntu 26.04"
echo "=============================================="

echo
echo "=== 1. 完全清除舊有 Flathub 設定 ==="

sudo flatpak remote-delete flathub 2>/dev/null || true
flatpak remote-delete flathub --user 2>/dev/null || true

echo
echo "=== 2. 更新系統並安裝必要工具 ==="

sudo apt update
sudo apt install -y flatpak wget curl

echo
echo "=== 3. 加入官方 Flathub ==="

sudo flatpak remote-add --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

echo
echo "=== 4. 更新 Flatpak 軟體源 ==="

sudo flatpak update --appstream -y

echo
echo "=== 5. 安裝 Bottles ==="

echo "正在從 Flathub 下載並安裝 Bottles..."
sudo flatpak install -y flathub com.usebottles.bottles

echo
echo "=== 6. 建立 LINE 安裝檔下載資料夾 ==="

mkdir -p "$HOME/Downloads"

echo
echo "=============================================="
echo " ⚠️ LINE 官方下載網址需要確認"
echo "=============================================="
echo
echo "目前不直接下載 https://line-scdn.net"
echo "因為該網址不是 LINE Windows 安裝程式本身。"
echo
echo "請先確認 LINE 官方 Windows 安裝程式的實際下載網址。"
echo
echo "=============================================="
echo " 🎉 Bottles 安裝完成"
echo "=============================================="
echo
echo "接下來："
echo
echo "1. 開啟應用程式選單 → Bottles"
echo
echo "2. 建立新的 Bottle"
echo "   名稱：Line"
echo "   類型：Application"
echo
echo "3. 建議先選擇較新的 Wine Runner"
echo
echo "4. 將 LINE Windows 安裝程式"
echo "   LineInst.exe"
echo "   放到："
echo "   $HOME/Downloads/"
echo
echo "5. 在 Bottles → Line → Run executable"
echo "   選擇 LineInst.exe"
echo
echo "=============================================="
EOF

chmod +x install_line.sh
./install_line.sh
