#!/bin/bash

# 🚀 SIMPLE NGROK - Một tunnel cho cả frontend và backend
# Frontend: port 5173
# Backend: port 8000 (qua proxy)

echo "🚀 SIMPLE NGROK START"
echo "====================="

# Dừng tất cả processes
echo "🛑 Dừng processes cũ..."
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "ngrok" 2>/dev/null || true
pkill -f "npm.*dev" 2>/dev/null || true

sleep 2

# Khôi phục database nếu cần
if [ ! -f "/Users/maybe/Documents/shopee/app.db" ] || [ $(stat -f%z "/Users/maybe/Documents/shopee/app.db" 2>/dev/null || echo "0") -eq 0 ]; then
    echo "🔧 Khôi phục database..."
    cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/app.db
fi

# Khởi động backend HTTP
echo "🔧 Khởi động backend HTTP..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

sleep 5

# Khởi động frontend với proxy
echo "🎨 Khởi động frontend với proxy..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!

sleep 5

# Khởi động ngrok cho frontend HTTPS với auth token
echo "🌐 Khởi động ngrok cho frontend HTTPS với auth token..."
ngrok config add-authtoken 342Gw9izZ3uJJH4vo0JGOpEfMKB_5UiXcUoSQhw8jRjyyCqt5
ngrok http https://0.0.0.0:5173 --host-header=0.0.0.0:5173 --inspect=false &
NGROK_PID=$!

sleep 5

# Lấy ngrok URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['proto'] == 'https':
            print(tunnel['public_url'])
            break
except:
    print('')
" 2>/dev/null)

echo ""
echo "✅ SIMPLE NGROK ĐÃ KHỞI ĐỘNG!"
echo "============================="
echo "🔧 Backend HTTP: http://0.0.0.0:8000"
echo "🎨 Frontend: http://0.0.0.0:5173 (với proxy)"
echo "🌍 Ngrok URL: $NGROK_URL"
echo ""
echo "📱 Truy cập ngay:"
echo "1. Mở: $NGROK_URL"
echo "2. Đăng nhập với admin/admin"
echo "3. Tạo nhiệm vụ → Admin dashboard hiển thị"
echo "4. Chấm công → Gửi báo cáo"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, Ngrok=$NGROK_PID"
echo "Dừng: kill $BACKEND_PID $FRONTEND_PID $NGROK_PID"
