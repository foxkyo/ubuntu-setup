# 1. 徹底移除頑固的 Snap 版 Firefox
sudo snap remove --purge firefox

# 2. 加入 Mozilla Team 的官方 PPA 來源
sudo add-apt-repository ppa:mozillateam/ppa -y

# 3. 設定 APT 優先級，強迫系統以後都下載 PPA 原生版，而不是 Ubuntu 預設的 Snap 版
echo '
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozillateam-ppa

# 4. 更新來源並安裝全新的原生 Firefox 與繁體中文包
sudo apt update
sudo apt install -y firefox firefox-locale-zh-hant
