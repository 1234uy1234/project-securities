#!/bin/bash

echo "🚀 KHỞI ĐỘNG VỚI LOCALHOST RUN - URL CỐ ĐỊNH"
echo "============================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm" 2>/dev/null || true
lsof -ti:5173,5174,8000 | xargs kill -9 2>/dev/null || true
sleep 3

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

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG!"
echo "========================"
echo "🔧 Backend: http://10.10.68.200:8000"
echo "🎨 Frontend: http://localhost:5173"
echo ""
echo "📱 TRUY CẬP TRỰC TIẾP:"
echo "1. Mở trình duyệt"
echo "2. Truy cập: http://localhost:5173"
echo "3. Hoặc: http://10.10.68.200:5173"
echo ""
echo "🔐 Login: admin/admin"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Đang dừng ứng dụng..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "npm.*dev" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait









