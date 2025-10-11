#!/bin/bash

echo "🔍 Lấy Cloudflare Tunnel URL..."
echo "==============================="

# Tìm process cloudflared
CLOUDFLARE_PID=$(ps aux | grep "cloudflared tunnel" | grep -v grep | awk '{print $2}' | head -1)

if [ -z "$CLOUDFLARE_PID" ]; then
    echo "❌ Cloudflare Tunnel chưa chạy"
    echo "💡 Chạy: ./start_cloudflare_tunnel.sh"
    exit 1
fi

echo "✅ Cloudflare Tunnel đang chạy (PID: $CLOUDFLARE_PID)"

# Thử lấy URL từ log hoặc output
echo ""
echo "🌍 Để lấy URL, hãy kiểm tra terminal nơi chạy Cloudflare Tunnel"
echo "📱 URL sẽ có dạng: https://xxxxx.trycloudflare.com"
echo ""
echo "💡 Nếu không thấy URL, hãy:"
echo "1. Mở terminal mới"
echo "2. Chạy: ./start_cloudflare_tunnel.sh"
echo "3. URL sẽ hiển thị trong output"

