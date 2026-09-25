# 1. 建立腳本檔案
cat << 'EOF' > install_line.sh
#!/bin/bash

echo "=== 開始安裝 LINE 依賴環境 (Flatpak & Bottles) ==="
# 更新系統並安裝 Flatpak
sudo apt update && sudo apt install -y flatpak

# 新增 Flathub 來源
flatpak remote-add --if-not-exists flathub https://flathub.org

# 安裝 Bottles
echo "正在安裝 Bottles，請稍候..."
flatpak install -y flathub com.usebottles.bottles

echo "=== 下載 LINE 官方安裝檔 ==="
# 下載 LINE Windows 版本安裝包
wget -O ~/Downloads/LineInst.exe https://line-scdn.net

echo "========================================================="
echo " 腳本前置作業已完成！請手動執行以下步驟完成安裝："
echo "========================================================="
echo "1. 開啟應用程式選單，尋找並啟動『Bottles』。"
echo "2. 進入 Bottles 的「偏好設定 (Preferences)」->「執行環境 (Runners)」。"
echo "3. 下載並切換至『Kron4ek Wine 10.13』或更新的版本（LINE 必須要求 Wine 10.13+）。"
echo "4. 點擊『+』建立新容器（Bottle），命名為 Line，類型選擇 Application。"
echo "5. 進入該容器，在 Dependencies (依賴項目) 安裝：cjkfonts、d3dcompiler_47、vcredist2022。"
echo "6. 點擊「執行執行檔 (Run Executable)」，選擇下載資料夾中的 LineInst.exe 進行安裝。"
echo "========================================================="
EOF

# 2. 賦予腳本執行權限
chmod +x install_line.sh

# 3. 執行腳本
./install_line.sh
