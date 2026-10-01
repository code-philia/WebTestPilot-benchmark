#!/bin/bash
set -e

echo "[seed] Waiting for PrestaShop to be ready..."
until curl -s http://webapp:80 2>/dev/null | grep -q "Ecommerce software by PrestaShop"; do
    sleep 10
done

echo "[seed] Loading seed data..."
YESTERDAY=$(date -d 'yesterday' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
sed "s/YYYY-MM-DD/$YESTERDAY/g" /seed.sql \
    | mysql -h db -u root -proot prestashop

echo "[seed] Done"
