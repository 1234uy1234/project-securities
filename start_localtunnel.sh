#!/bin/bash

echo "🚀 KHỞI ĐỘNG HỆ THỐNG VỚI LOCALTUNNEL"
echo "====================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm\|vite\|localtunnel" 2>/dev/null || true
lsof -ti:5173,8000 | xargs kill -9 2>/dev/null || true
sleep 3

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 5

# Khởi động frontend
echo "🎨 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!
sleep 5

# Khởi động localtunnel
echo "🌐 Khởi động Localtunnel..."
cd /Users/maybe/Documents/shopee
npx localtunnel --port 5173 --subdomain manhtoan-patrol &
LOCALTUNNEL_PID=$!
sleep 7

# Lấy IP cho mật khẩu
echo "🔑 Lấy IP cho mật khẩu localtunnel..."
TUNNEL_PASSWORD=$(curl -s https://loca.lt/mytunnelpassword)
echo "🔑 Mật khẩu localtunnel: $TUNNEL_PASSWORD"

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
echo "===================================="
echo "🌍 URL truy cập: https://manhtoan-patrol.loca.lt"
echo "🔑 Mật khẩu: $TUNNEL_PASSWORD"
echo ""
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "💡 Để dừng hệ thống, chạy: ./stop.sh"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Đang dừng ứng dụng..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    kill $LOCALTUNNEL_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "npm.*dev" 2>/dev/null
    pkill -f "localtunnel" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait
