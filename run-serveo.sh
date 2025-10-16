#!/bin/bash

echo "🚀 Khởi động Smart Patrol System với Serveo Tunnel"
echo "=================================================="

# Tắt tất cả processes cũ
echo "🛑 Tắt các processes cũ..."
pkill -f "ngrok\|cloudflared\|uvicorn\|vite\|ssh.*serveo" 2>/dev/null || true
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

# Khởi động Serveo Tunnel
echo "ℹ️  Đang khởi động Serveo Tunnel..."
ssh -R 80:localhost:5173 serveo.net > serveo.log 2>&1 &
SERVEO_PID=$!

# Đợi tunnel khởi động
sleep 8

# Lấy URL từ log
SERVEO_URL=$(grep -o "https://[^[:space:]]*\.serveo\.net" serveo.log | tail -1)
if [ -n "$SERVEO_URL" ]; then
    echo "$SERVEO_URL" > current_url.txt
    echo "✅ Serveo Tunnel đã chạy: $SERVEO_URL"
else
    echo "❌ Không thể lấy Serveo URL"
    echo "ℹ️  Kiểm tra serveo.log để xem URL"
fi

echo "=================================================="
echo "✅ Tất cả services đã sẵn sàng!"
echo "ℹ️  🌍 Public URL: $SERVEO_URL"
echo "ℹ️  📱 Frontend: http://localhost:5173"
echo "ℹ️  🔧 Backend: http://0.0.0.0:8000"
echo "=================================================="
echo "ℹ️  Nhấn Ctrl+C để dừng tất cả services"

# Lưu PIDs để dễ dừng
echo "$BACKEND_PID" > backend.pid
echo "$FRONTEND_PID" > frontend.pid
echo "$SERVEO_PID" > serveo.pid

# Đợi tín hiệu dừng
trap 'echo "🛑 Đang dừng tất cả services..."; kill $BACKEND_PID $FRONTEND_PID $SERVEO_PID 2>/dev/null; exit 0' INT

# Giữ script chạy
wait
