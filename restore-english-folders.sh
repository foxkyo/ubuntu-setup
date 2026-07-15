#!/bin/bash

set -e

echo "======================================"
echo "將 Ubuntu 使用者目錄恢復為英文"
echo "======================================"

# 移除目前的使用者目錄設定
rm -f ~/.config/user-dirs.dirs
rm -f ~/.config/user-dirs.locale

# 強制使用英文重新建立
LANG=C xdg-user-dirs-update --force

echo
echo "======================================"
echo "完成"
echo "======================================"
echo
echo "新的使用者目錄："
xdg-user-dir DESKTOP
xdg-user-dir DOWNLOAD
xdg-user-dir TEMPLATES
xdg-user-dir PUBLICSHARE
xdg-user-dir DOCUMENTS
xdg-user-dir MUSIC
xdg-user-dir PICTURES
xdg-user-dir VIDEOS

echo
echo "若檔案管理員仍顯示舊名稱，請重新登入或重新開機。"
