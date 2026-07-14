#!/bin/bash

set -e

sudo apt update

# 專案名稱，第1個參數，預設 cmspos
PROJECT_NAME=${1:-cmspos}

echo "=================================="
echo "建立 Laravel Sail 專案"
echo "專案名稱: ${PROJECT_NAME}"
echo "=================================="


# 建立 Sail 專案
curl -s "https://laravel.build/${PROJECT_NAME}?with=mariadb,redis" | bash


cd "${PROJECT_NAME}"


# 啟動 Sail
./vendor/bin/sail up -d


echo
echo "=================================="
echo "完成"
echo "專案位置: $(pwd)"
echo "=================================="
