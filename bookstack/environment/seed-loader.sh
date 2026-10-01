#!/bin/bash
set -e

echo "[seed] Waiting for BookStack to be ready..."
until curl -s http://webapp:8080/ 2>/dev/null | grep -q "Redirecting to"; do
    sleep 5
done

echo "[seed] Loading seed data..."
YESTERDAY=$(date -d 'yesterday' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
sed "s/YYYY-MM-DD/$YESTERDAY/g" /seed.sql \
    | mysql -h db -u admin -padmin bookstack

echo "[seed] Done"
