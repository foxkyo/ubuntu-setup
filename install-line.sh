# 1. 直接建立完整的腳本檔案
cat << 'EOF' > install_line.sh
#!/bin/bash

# 偵測錯誤即停止執行
set -e

echo "=== 1. 清除舊有損壞的 Flathub 設定 ==="
sudo flatpak remote-delete flathub 2>/dev/null || true
flatpak remote-delete flathub --user 2>/dev/null || true

echo "=== 2. 更新系統並安裝 Flatpak ==="
sudo apt update && sudo apt install -y flatpak wget

echo "=== 3. 導入正確的 GPG 金鑰並重新加入 Flathub ==="
sudo wget -O /tmp/flathub.gpg https://flathub.org
sudo flatpak remote-add --if-not-exists flathub https://flathub.org --gpg-import=/tmp/flathub.gpg

echo "=== 4. 更新 Flatpak 軟體源資訊 ==="
flatpak update --appstream -y

echo "=== 5. 安裝 Bottles ==="
echo "正在從 Flathub 下載並安裝 Bottles，這可能需要幾分鐘..."
sudo flatpak install -y flathub com.usebottles.bottles

echo "=== 6. 下載 LINE 官方 Windows 安裝檔 ==="
mkdir -p ~/Downloads
echo "正在下載 LINE 安裝檔至 ~/Downloads/LineInst.exe ..."
wget -O ~/Downloads/LineInst.exe "https://line-scdn.net"

echo ""
echo "========================================================="
echo " 🎉 腳本執行完畢！請手動操作 Bottles 完成最後安裝："
echo "========================================================="
echo "1. 在應用程式選單中，搜尋並啟動『Bottles』。"
echo "2. 點擊 Bottles 的「偏好設定 (Preferences)」->「執行環境 (Runners)」"
echo "   下載並切換至『Kron4ek Wine 10.13』或更新版本（LINE 登入必須）。"
echo "3. 點擊『+』建立新容器（Bottle）："
echo "   - 名稱：Line"
echo "   - 類型：Application"
echo "4. 進入該容器，在 Dependencies (依賴項目) 內安裝以下三個元件："
echo "   - cjkfonts (修復中文字型變方塊)"
echo "   - d3dcompiler_47"
echo "   - vcredist2022"
echo "5. 點擊「執行執行檔 (Run Executable)」，選擇下載資料夾中的 LineInst.exe 安裝即可。"
echo "========================================================="
EOF

# 2. 賦予腳本執行權限
chmod +x install_line.sh

# 3. 自動執行腳本
./install_line.sh
