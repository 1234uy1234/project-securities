#!/bin/bash

echo "🚀 KHỞI ĐỘNG HOÀN CHỈNH - 1 LỆNH LÀ XONG!"
echo "=========================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng tất cả processes cũ..."
pkill -f "uvicorn\|npm\|cloudflared" 2>/dev/null || true
lsof -ti:5173,5174,8000 | xargs kill -9 2>/dev/null || true
sleep 3

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 10.10.68.200 --port 8000 &
BACKEND_PID=$!
sleep 3

# Khởi động frontend trên port cố định
echo "🎨 Khởi động Frontend trên port 5173..."
cd /Users/maybe/Documents/shopee/frontend
PORT=5173 npm run dev &
FRONTEND_PID=$!
sleep 5

# Kiểm tra frontend đang chạy port nào
echo "🔍 Kiểm tra port frontend..."
FRONTEND_PORT=$(lsof -i :5173 -i :5174 | grep LISTEN | head -1 | awk '{print $9}' | cut -d: -f2)
echo "✅ Frontend đang chạy trên port: $FRONTEND_PORT"

# Khởi động Cloudflare Tunnel với port đúng
echo "🌐 Khởi động Cloudflare Tunnel với port $FRONTEND_PORT..."
cd /Users/maybe/Documents/shopee
cloudflared tunnel --url http://localhost:$FRONTEND_PORT &
CLOUDFLARED_PID=$!
sleep 5

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG HOÀN CHỈNH!"
echo "===================================="
echo "🔧 Backend: http://10.10.68.200:8000"
echo "🎨 Frontend: http://localhost:$FRONTEND_PORT"
echo "🌍 Cloudflare Tunnel: Đang khởi động..."
echo ""
echo "📱 URL CLOUDFLARE SẼ HIỂN THỊ Ở TRÊN!"
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, Cloudflare=$CLOUDFLARED_PID"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Đang dừng ứng dụng..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    kill $CLOUDFLARED_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "npm.*dev" 2>/dev/null
    pkill -f "cloudflared" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait

