#!/bin/bash

echo "🚀 Khởi động Smart Patrol System với LocalTunnel"
echo "=================================================="

# Tắt tất cả processes cũ
echo "🛑 Tắt các processes cũ..."
pkill -f "ngrok\|cloudflared\|uvicorn\|vite\|ssh.*serveo\|localtunnel" 2>/dev/null || true
sleep 2

# Khởi động Backend
echo "ℹ️  Đang khởi động Backend..."
cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload > ../backend.log 2>&1 &
BACKEND_PID=$!
echo "✅ Backend đã chạy trên http://0.0.0.0:8000 (PID: $BACKEND_PID)"

# Khởi động Frontend
echo "ℹ️  Đang khởi động Frontend..."
cd ../frontend && npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend đã chạy trên http://localhost:5173 (PID: $FRONTEND_PID)"

# Đợi frontend khởi động
sleep 5

# Khởi động LocalTunnel
echo "ℹ️  Đang khởi động LocalTunnel..."
npx localtunnel --port 5173 > localtunnel.log 2>&1 &
LOCALTUNNEL_PID=$!

# Đợi tunnel khởi động
sleep 8

# Lấy URL từ log
LOCALTUNNEL_URL=$(grep -o "https://[^[:space:]]*\.loca\.lt" localtunnel.log | tail -1)
if [ -n "$LOCALTUNNEL_URL" ]; then
    echo "$LOCALTUNNEL_URL" > current_url.txt
    echo "✅ LocalTunnel đã chạy: $LOCALTUNNEL_URL"
else
    echo "❌ Không thể lấy LocalTunnel URL"
    echo "ℹ️  Kiểm tra localtunnel.log để xem URL"
fi

echo "=================================================="
echo "✅ Tất cả services đã sẵn sàng!"
echo "ℹ️  🌍 Public URL: $LOCALTUNNEL_URL"
echo "ℹ️  📱 Frontend: http://localhost:5173"
echo "ℹ️  🔧 Backend: http://0.0.0.0:8000"
echo "=================================================="
echo "ℹ️  Nhấn Ctrl+C để dừng tất cả services"

# Lưu PIDs để dễ dừng
echo "$BACKEND_PID" > backend.pid
echo "$FRONTEND_PID" > frontend.pid
echo "$LOCALTUNNEL_PID" > localtunnel.pid

# Đợi tín hiệu dừng
trap 'echo "🛑 Đang dừng tất cả services..."; kill $BACKEND_PID $FRONTEND_PID $LOCALTUNNEL_PID 2>/dev/null; exit 0' INT

# Giữ script chạy
wait
