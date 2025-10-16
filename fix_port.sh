#!/bin/bash

echo "🔧 SỬA LỖI PORT - CLOUDFLARE TUNNEL"
echo "===================================="

# Dừng tất cả cloudflared
echo "🛑 Dừng Cloudflare Tunnel cũ..."
pkill -f "cloudflared" 2>/dev/null || true
sleep 2

# Kiểm tra port frontend đang chạy
echo "🔍 Kiểm tra port frontend..."
FRONTEND_PORT=$(lsof -i :5173 -i :5174 | grep LISTEN | head -1 | awk '{print $9}' | cut -d: -f2)

if [ -z "$FRONTEND_PORT" ]; then
    echo "❌ Không tìm thấy frontend đang chạy!"
    echo "🔧 Khởi động frontend..."
    cd /Users/maybe/Documents/shopee/frontend
    npm run dev &
    sleep 5
    FRONTEND_PORT=$(lsof -i :5173 -i :5174 | grep LISTEN | head -1 | awk '{print $9}' | cut -d: -f2)
fi

echo "✅ Frontend đang chạy trên port: $FRONTEND_PORT"

# Khởi động Cloudflare Tunnel với port đúng
echo "🌐 Khởi động Cloudflare Tunnel với port $FRONTEND_PORT..."
cd /Users/maybe/Documents/shopee
cloudflared tunnel --url http://localhost:$FRONTEND_PORT &
CLOUDFLARED_PID=$!
sleep 5

echo ""
echo "✅ HOÀN TẤT!"
echo "============"
echo "🎨 Frontend: http://localhost:$FRONTEND_PORT"
echo "🌍 Cloudflare Tunnel: Đang khởi động..."
echo "📱 URL sẽ hiển thị ở trên"
echo "🔐 Login: admin/admin"
echo ""
echo "🔧 PID: $CLOUDFLARED_PID"









