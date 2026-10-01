#!/bin/bash
set -e

echo "[seed] Waiting for Indico to be ready..."
until (
    exec 3<>/dev/tcp/nginx/8080
    printf 'GET / HTTP/1.1\r\nHost: nginx:8080\r\nConnection: close\r\n\r\n' >&3
    cat <&3
) 2>/dev/null | grep -q "All events"; do
    sleep 5
done

echo "[seed] Loading seed data..."
psql -h postgres -U indico -d indico -f /seed.sql

echo "[seed] Done"
