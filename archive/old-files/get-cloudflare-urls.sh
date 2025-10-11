#!/bin/bash

echo "🔍 Lấy Cloudflare Tunnel URLs..."
echo "================================"

# Lấy URL của backend tunnel
echo "🌐 Backend Tunnel:"
BACKEND_URL=$(ps aux | grep "cloudflared tunnel --url http://localhost:8000" | grep -v grep | head -1)
if [ ! -z "$BACKEND_URL" ]; then
    echo "  ✅ Backend tunnel đang chạy"
    echo "  📍 URL sẽ hiển thị trong terminal khi tunnel khởi động"
else
    echo "  ❌ Backend tunnel không chạy"
fi

echo ""

# Lấy URL của frontend tunnel  
echo "🌐 Frontend Tunnel:"
FRONTEND_URL=$(ps aux | grep "cloudflared tunnel --url https://localhost:5173" | grep -v grep | head -1)
if [ ! -z "$FRONTEND_URL" ]; then
    echo "  ✅ Frontend tunnel đang chạy"
    echo "  📍 URL sẽ hiển thị trong terminal khi tunnel khởi động"
else
    echo "  ❌ Frontend tunnel không chạy"
fi

echo ""
echo "💡 Để xem URLs, hãy kiểm tra terminal nơi chạy cloudflared"
echo "💡 URLs sẽ có dạng: https://xxxxx.trycloudflare.com"
