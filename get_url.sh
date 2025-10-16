#!/bin/bash

echo "🌐 LẤY URL CLOUDFLARE TUNNEL"
echo "============================"

# Tìm process cloudflared
CLOUDFLARED_PID=$(ps aux | grep "cloudflared tunnel" | grep -v grep | awk '{print $2}' | head -n 1)

if [ -z "$CLOUDFLARED_PID" ]; then
    echo "❌ Cloudflare Tunnel chưa chạy!"
    echo "🔧 Chạy: cloudflared tunnel --url http://localhost:5173"
    exit 1
fi

echo "✅ Cloudflare Tunnel đang chạy (PID: $CLOUDFLARED_PID)"

# Khởi động Cloudflare Tunnel mới để lấy URL
echo "🔍 Đang lấy URL mới..."
cloudflared tunnel --url http://localhost:5173 &
NEW_PID=$!
sleep 3
kill $NEW_PID 2>/dev/null

echo "✅ HOÀN TẤT!"
echo "🌍 Truy cập URL hiển thị ở trên"
echo "🔐 Login: admin/admin"









