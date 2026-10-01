#!/bin/bash
set -e

echo "[seed] Waiting for Invoice Ninja to be ready..."
until curl -s http://nginx:80 2>/dev/null | grep -q "Invoice Ninja"; do
    sleep 5
done

echo "[seed] Loading seed data..."
mysql -h mysql -u ninja -pninja ninja < /seed.sql

echo "[seed] Done"
