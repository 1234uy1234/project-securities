#!/bin/bash

# 🚀 START ALL - Khởi động toàn bộ hệ thống với 1 lệnh
echo "🚀 KHỞI ĐỘNG TOÀN BỘ HỆ THỐNG"
echo "==============================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "ngrok" 2>/dev/null || true
pkill -f "npm.*dev" 2>/dev/null || true

sleep 3

# Khôi phục database nếu cần
if [ ! -f "/Users/maybe/Documents/shopee/app.db" ] || [ $(stat -f%z "/Users/maybe/Documents/shopee/app.db" 2>/dev/null || echo "0") -eq 0 ]; then
    echo "🔧 Khôi phục database..."
    cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/app.db
fi

# Khởi động backend
echo "🔧 Khởi động backend..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

sleep 5

# Kiểm tra backend
if ! curl -s http://localhost:8000 > /dev/null; then
    echo "❌ Backend không khởi động được"
    exit 1
fi
echo "✅ Backend đã chạy"

# Khởi động frontend
echo "🎨 Khởi động frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!

sleep 5

# Kiểm tra frontend
if ! curl -s http://localhost:5173 > /dev/null; then
    echo "❌ Frontend không khởi động được"
    exit 1
fi
echo "✅ Frontend đã chạy"

# Khởi động ngrok
echo "🌐 Khởi động ngrok..."
cd /Users/maybe/Documents/shopee
ngrok http 0.0.0.0:5173 --log=stdout &
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

if [ -z "$NGROK_URL" ]; then
    echo "❌ Không thể lấy ngrok URL"
    exit 1
fi

echo ""
echo "🎉 HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
echo "===================================="
echo "🔧 Backend: http://0.0.0.0:8000"
echo "🎨 Frontend: http://localhost:5173"
echo "🌍 Ngrok URL: $NGROK_URL"
echo ""
echo "📱 TRUY CẬP NGAY:"
echo "1. Mở trình duyệt: $NGROK_URL"
echo "2. Đăng nhập: admin/admin"
echo "3. Sử dụng tất cả chức năng"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, Ngrok=$NGROK_PID"
echo ""
echo "🛑 Để dừng hệ thống: ./stop_all.sh"
