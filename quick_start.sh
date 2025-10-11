#!/bin/bash

# 🚀 QUICK START - KHỞI ĐỘNG NHANH HỆ THỐNG
# Khởi động cả frontend, backend và ngrok

echo "🚀 QUICK START HỆ THỐNG"
echo "======================="

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

# Khởi động backend
echo "🔧 Khởi động backend..."
cd /Users/maybe/Documents/shopee
python backend/app.py &
BACKEND_PID=$!

sleep 3

# Khởi động frontend
echo "🎨 Khởi động frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!

sleep 5

# Khởi động ngrok
echo "🌐 Khởi động ngrok..."
ngrok http 0.0.0.0:5173 --host-header=0.0.0.0:5173 --inspect=false &
NGROK_PID=$!

sleep 3

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
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG!"
echo "========================="
echo "🔧 Backend: http://0.0.0.0:8000"
echo "🎨 Frontend: http://0.0.0.0:5173"
echo "🌍 Ngrok: $NGROK_URL"
echo ""
echo "📱 Truy cập ngay:"
echo "1. Mở: $NGROK_URL"
echo "2. Đăng nhập với admin/admin"
echo "3. Tạo nhiệm vụ → Admin dashboard hiển thị"
echo "4. Chấm công → Gửi báo cáo"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, Ngrok=$NGROK_PID"
echo "Dừng: kill $BACKEND_PID $FRONTEND_PID $NGROK_PID"
