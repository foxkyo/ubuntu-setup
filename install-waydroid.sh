#!/bin/bash

set -e

echo "======================================"
echo " Waydroid 安裝程式"
echo " Ubuntu 26.04"
echo "======================================"
echo

# --------------------------------------------------
# 0. 必須使用 sudo
# --------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "錯誤：請使用 sudo 執行"
    echo
    echo "請執行："
    echo "sudo ./install-waydroid.sh"
    exit 1
fi

# --------------------------------------------------
# 1. 檢查 Ubuntu
# --------------------------------------------------

echo "== 1. 檢查作業系統 =="

if [[ ! -f /etc/os-release ]]; then
    echo "錯誤：找不到 /etc/os-release"
    exit 1
fi

source /etc/os-release

echo "OS      : $PRETTY_NAME"
echo "VERSION : $VERSION_ID"
echo

if [[ "$ID" != "ubuntu" ]]; then
    echo "警告：這不是 Ubuntu。"
    echo "目前系統：$PRETTY_NAME"
    echo
    read -rp "仍然繼續嗎？[y/N] " answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# --------------------------------------------------
# 2. 檢查 Wayland
# --------------------------------------------------

echo "== 2. 檢查圖形工作階段 =="

if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
    echo
    echo "警告：目前不是 Wayland Session。"
    echo
    echo "目前：${XDG_SESSION_TYPE:-unknown}"
    echo
    echo "Waydroid 官方要求 Ubuntu 22.04+ 使用 Wayland。"
    echo
    echo "請先登出，在登入畫面選擇 Ubuntu"
    echo "（不要選 Ubuntu on Xorg），再重新執行本腳本。"
    echo
    exit 1
fi

echo "Wayland：OK"
echo

# --------------------------------------------------
# 3. 更新套件索引
# --------------------------------------------------

echo "== 3. 更新套件列表 =="

apt update

echo

# --------------------------------------------------
# 4. 安裝必要套件
# --------------------------------------------------

echo "== 4. 安裝必要套件 =="

apt install -y \
    curl \
    ca-certificates \
    lxc \
    python3 \
    python3-gbinder

echo

# --------------------------------------------------
# 5. 安裝 Waydroid 官方 Repository
# --------------------------------------------------

echo "== 5. 加入 Waydroid 官方 Repository =="

curl -s https://repo.waydro.id | bash

echo

# --------------------------------------------------
# 6. 更新套件列表
# --------------------------------------------------

echo "== 6. 更新套件列表 =="

apt update

echo

# --------------------------------------------------
# 7. 安裝 Waydroid
# --------------------------------------------------

echo "== 7. 安裝 Waydroid =="

apt install -y waydroid

echo

# --------------------------------------------------
# 8. 確認安裝
# --------------------------------------------------

echo "== 8. 確認 Waydroid =="

if ! command -v waydroid >/dev/null 2>&1; then
    echo "錯誤：Waydroid 安裝失敗。"
    exit 1
fi

waydroid --version || true

echo

# --------------------------------------------------
# 9. 初始化 Waydroid
# --------------------------------------------------

echo "== 9. 初始化 Waydroid =="

if [[ ! -d /var/lib/waydroid ]]; then

    echo
    echo "開始初始化 Android 系統..."
    echo

    waydroid init

else

    echo "Waydroid 已經初始化，跳過。"

fi

echo

# --------------------------------------------------
# 10. 啟用 Waydroid Container
# --------------------------------------------------

echo "== 10. 設定 Waydroid Container =="

systemctl enable waydroid-container.service 2>/dev/null || true

echo

# --------------------------------------------------
# 11. 完成
# --------------------------------------------------

echo "======================================"
echo " Waydroid 安裝完成"
echo "======================================"
echo

echo "請重新啟動 Ubuntu："
echo
echo "    reboot"
echo

echo "重新登入 Ubuntu 後，可以從應用程式選單啟動："
echo
echo "    Waydroid"
echo

echo "或手動啟動："
echo
echo "    waydroid session start"
echo
echo "然後："
echo
echo "    waydroid show-full-ui"
echo

echo "======================================"
echo " 注意"
echo "======================================"
echo
echo "目前安裝的是標準 Waydroid Android 系統。"
echo "如果需要 Google Play 商店 / Google Play Services，"
echo "需要另外處理 GApps / Play Store。"
echo
