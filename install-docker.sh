#!/bin/bash

sudo apt update

# 安裝 Docker（官方方式）
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker


# 建立 Sail 專案
curl -s "https://laravel.build/cmspos?with=mariadb,redis" | bash

cd cmspos

# 啟動
./vendor/bin/sail up -d#!/bin/bash

sudo apt update

# 安裝 Docker（官方方式）

# 建立 Sail 專案
curl -s "https://laravel.build/cmspos?with=mariadb,redis" | bash

cd cmspos


##########################################
# Sail Command
##########################################

echo "Creating sail command..."

sudo tee /usr/local/bin/sail >/dev/null <<'EOF'
#!/bin/bash

if [ -f "./vendor/bin/sail" ]; then
    exec ./vendor/bin/sail "$@"
fi

DIR="$PWD"

while [ "$DIR" != "/" ]; do
    if [ -f "$DIR/vendor/bin/sail" ]; then
        cd "$DIR"
        exec ./vendor/bin/sail "$@"
    fi
    DIR=$(dirname "$DIR")
done

echo "Laravel Sail project not found."
exit 1
EOF

sudo chmod +x /usr/local/bin/sail


# 啟動
sail up -d
