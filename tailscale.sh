#!/usr/bin/env bash
set -e

echo "======================================"
echo "安裝 Tailscale"
echo "======================================"

if command -v tailscale >/dev/null 2>&1; then
    echo "Tailscale 已安裝，略過"
    exit 0
fi

curl -fsSL https://tailscale.com/install.sh | sh

sudo systemctl enable tailscaled
sudo systemctl start tailscaled

echo
echo "======================================"
echo "Tailscale 安裝完成"
echo
echo "請執行："
echo
echo "sudo tailscale up"
echo
echo "若需要 SSH："
echo
echo "sudo tailscale up --ssh"
echo
