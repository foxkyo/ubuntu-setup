#!/bin/bash

set -e

echo "========================================"
echo " 停用 Ubuntu 開機等待網路完成"
echo "========================================"


if [[ $EUID -ne 0 ]]; then
    echo "請使用 sudo 執行："
    echo "sudo ./disable-network-wait.sh"
    exit 1
fi


echo
echo "== 停用 systemd-networkd-wait-online =="

systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true

systemctl mask systemd-networkd-wait-online.service 2>/dev/null || true



echo
echo "== 停用 NetworkManager-wait-online =="

systemctl disable NetworkManager-wait-online.service 2>/dev/null || true

systemctl mask NetworkManager-wait-online.service 2>/dev/null || true



echo
echo "== Reload systemd =="

systemctl daemon-reload



echo
echo "========================================"
echo " 完成"
echo
echo "目前狀態："
echo

systemctl is-enabled systemd-networkd-wait-online.service 2>/dev/null || true

systemctl is-enabled NetworkManager-wait-online.service 2>/dev/null || true


echo
echo "請重新開機測試："
echo
echo "sudo reboot"
echo
echo "========================================"
