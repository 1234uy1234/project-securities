#!/bin/bash

echo "🚀 Khởi động Smart Patrol System với Cloudflare Tunnel"
echo "=================================================="

# Tắt tất cả processes cũ
echo "🛑 Tắt các processes cũ..."
pkill -f "ngrok\|cloudflared\|uvicorn\|vite" 2>/dev/null || true
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

# Khởi động Cloudflare Tunnel
echo "ℹ️  Đang khởi động Cloudflare Tunnel..."
cloudflared tunnel --url http://localhost:5173 > cloudflare.log 2>&1 &
CLOUDFLARE_PID=$!

# Đợi tunnel khởi động và lấy URL
sleep 8

# Lấy URL từ log
CLOUDFLARE_URL=$(grep -o "https://[^[:space:]]*\.trycloudflare\.com" cloudflare.log | tail -1)
if [ -n "$CLOUDFLARE_URL" ]; then
    echo "$CLOUDFLARE_URL" > current_url.txt
    echo "✅ Cloudflare Tunnel đã chạy: $CLOUDFLARE_URL"
else
    echo "❌ Không thể lấy Cloudflare URL"
fi

echo "=================================================="
echo "✅ Tất cả services đã sẵn sàng!"
echo "ℹ️  🌍 Public URL: $CLOUDFLARE_URL"
echo "ℹ️  📱 Frontend: http://localhost:5173"
echo "ℹ️  🔧 Backend: http://0.0.0.0:8000"
echo "=================================================="
echo "ℹ️  Nhấn Ctrl+C để dừng tất cả services"

# Lưu PIDs để dễ dừng
echo "$BACKEND_PID" > backend.pid
echo "$FRONTEND_PID" > frontend.pid
echo "$CLOUDFLARE_PID" > cloudflare.pid

# Đợi tín hiệu dừng
trap 'echo "🛑 Đang dừng tất cả services..."; kill $BACKEND_PID $FRONTEND_PID $CLOUDFLARE_PID 2>/dev/null; exit 0' INT

# Giữ script chạy
wait
