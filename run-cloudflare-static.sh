#!/bin/bash

echo "🌐 KHỞI ĐỘNG CLOUDFLARE TUNNEL VỚI URL TĨNH"
echo "============================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm\|ngrok\|serveo\|localtunnel" 2>/dev/null || true
lsof -ti:5173,5174,8000 | xargs kill -9 2>/dev/null || true
sleep 3

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
sleep 3

# Khởi động frontend
echo "🎨 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!
sleep 5

# Khởi động Cloudflare Tunnel với URL tĩnh
echo "🌐 Khởi động Cloudflare Tunnel với URL tĩnh..."
cd /Users/maybe/Documents/shopee
cloudflared tunnel --url http://localhost:5173 &
CLOUDFLARE_PID=$!
sleep 8

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG VỚI CLOUDFLARE TUNNEL!"
echo "================================================"
echo "🔧 Backend: http://0.0.0.0:8000"
echo "🎨 Frontend: http://localhost:5173"
echo "🌍 Cloudflare Tunnel: Đang khởi động..."
echo ""
echo "📱 URL tĩnh sẽ hiển thị trong terminal"
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, Cloudflare=$CLOUDFLARE_PID"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Đang dừng ứng dụng..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    kill $CLOUDFLARE_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "npm.*dev" 2>/dev/null
    pkill -f "cloudflared" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait





