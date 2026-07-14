#!/bin/bash

set -e

echo "=================================="
echo "Installing global sail command"
echo "=================================="


sudo tee /usr/local/bin/sail >/dev/null <<'EOF'
#!/bin/bash

# 優先使用目前目錄
if [ -f "./vendor/bin/sail" ]; then
    exec ./vendor/bin/sail "$@"
fi


# 往上層尋找 Laravel Sail 專案
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


echo
echo "=================================="
echo "Sail command installed"
echo "=================================="

sail --version || true
