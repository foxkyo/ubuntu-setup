# 1. 建立 Snap 專用的字型目錄（如果不存在）
mkdir -p ~/snap/firefox/common/.cache/fontconfig

# 2. 複製系統現有的正確字型快取到 Firefox 的家目錄沙盒中
cp -r /var/cache/fontconfig/* ~/snap/firefox/common/.cache/fontconfig/ 2>/dev/null || true

# 3. 調整權限，確保 Firefox 讀得到
chmod -R 755 ~/snap/firefox/common/.cache/fontconfig

# 4. 強制關閉可能在背景卡死的 Firefox
killall -9 firefox 2>/dev/null || true
