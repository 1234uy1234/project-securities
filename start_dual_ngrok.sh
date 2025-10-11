#!/bin/bash

# 🚀 DUAL NGROK - Frontend + Backend riêng biệt
# Frontend: ngrok tunnel
# Backend: ngrok tunnel riêng cho API

echo "🚀 DUAL NGROK START"
echo "==================="

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

# Khởi động backend HTTPS
echo "🔧 Khởi động backend HTTPS..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --ssl-keyfile localhost+3-key.pem --ssl-certfile localhost+3.pem &
BACKEND_PID=$!

sleep 5

# Khởi động frontend
echo "🎨 Khởi động frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!

sleep 5

# Khởi động ngrok cho frontend
echo "🌐 Khởi động ngrok cho frontend..."
ngrok http 0.0.0.0:5173 --host-header=0.0.0.0:5173 --inspect=false &
FRONTEND_NGROK_PID=$!

sleep 3

# Khởi động ngrok cho backend API (port 4041)
echo "🔧 Khởi động ngrok cho backend API..."
ngrok http 0.0.0.0:8000 --host-header=0.0.0.0:8000 --web-addr=0.0.0.0:4041 --inspect=false &
BACKEND_NGROK_PID=$!

sleep 5

# Lấy ngrok URLs
FRONTEND_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['proto'] == 'https' and '5173' in tunnel['config']['addr']:
            print(tunnel['public_url'])
            break
except:
    print('')
" 2>/dev/null)

BACKEND_URL=$(curl -s http://localhost:4041/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['proto'] == 'https' and '8000' in tunnel['config']['addr']:
            print(tunnel['public_url'])
            break
except:
    print('')
" 2>/dev/null)

echo ""
echo "✅ DUAL NGROK ĐÃ KHỞI ĐỘNG!"
echo "============================"
echo "🔧 Backend HTTPS: https://0.0.0.0:8000"
echo "🎨 Frontend: http://0.0.0.0:5173"
echo "🌍 Frontend Ngrok: $FRONTEND_URL"
echo "🔧 Backend Ngrok: $BACKEND_URL"
echo ""
echo "📱 Truy cập ngay:"
echo "1. Mở: $FRONTEND_URL"
echo "2. Đăng nhập với admin/admin"
echo "3. Tạo nhiệm vụ → Admin dashboard hiển thị"
echo "4. Chấm công → Gửi báo cáo"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID"
echo "🌍 Ngrok PIDs: Frontend=$FRONTEND_NGROK_PID, Backend=$BACKEND_NGROK_PID"
echo "Dừng: kill $BACKEND_PID $FRONTEND_PID $FRONTEND_NGROK_PID $BACKEND_NGROK_PID"
