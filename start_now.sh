#!/bin/bash

echo "🚀 KHỞI ĐỘNG DỰ ÁN - 1 LỆNH LÀ XONG!"
echo "===================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm\|cloudflared" 2>/dev/null || true
sleep 2

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 10.10.68.200 --port 8000 &
BACKEND_PID=$!
sleep 3

# Khởi động frontend
echo "🎨 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!
sleep 5

# Khởi động Cloudflare Tunnel
echo "🌐 Khởi động Cloudflare Tunnel..."
cd /Users/maybe/Documents/shopee
cloudflared tunnel --url http://localhost:5173 &
CLOUDFLARED_PID=$!
sleep 5

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG!"
echo "========================"
echo "🔧 Backend: http://10.10.68.200:8000"
echo "🎨 Frontend: http://localhost:5173"
echo "🌍 Cloudflare Tunnel: Đang khởi động..."
echo ""
echo "📱 Để lấy URL Cloudflare:"
echo "1. Mở terminal mới"
echo "2. Chạy: cloudflared tunnel --url http://localhost:5173"
echo "3. URL sẽ hiển thị với dạng: https://xxxxx.trycloudflare.com"
echo ""
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

