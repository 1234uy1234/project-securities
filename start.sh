#!/bin/bash

echo "🚀 KHỞI ĐỘNG TOÀN BỘ HỆ THỐNG"
echo "=============================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm\|ngrok" 2>/dev/null || true
lsof -ti:5173,5174,8000 | xargs kill -9 2>/dev/null || true
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

# Khởi động ngrok
echo "🌐 Khởi động ngrok..."
cd /Users/maybe/Documents/shopee
ngrok http 127.0.0.1:5173 --host-header=127.0.0.1:5173 &
NGROK_PID=$!
sleep 7

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
    echo "❌ Không thể lấy được ngrok URL. Vui lòng kiểm tra lại ngrok."
    exit 1
fi

echo "🔄 Cập nhật cấu hình với ngrok URL mới: $NGROK_URL"
python3 update_config.py "$NGROK_URL"

# Khởi động lại backend để áp dụng cấu hình mới
echo "🔄 Khởi động lại Backend để áp dụng cấu hình mới..."
kill $BACKEND_PID 2>/dev/null
sleep 2
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 5

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
echo "===================================="
echo "🌍 URL truy cập: $NGROK_URL"
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
    kill $NGROK_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "npm.*dev" 2>/dev/null
    pkill -f "ngrok" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait