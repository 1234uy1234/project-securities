#!/bin/bash

echo "🚀 KHỞI ĐỘNG HỆ THỐNG VỚI TOKEN NGROK MỚI"
echo "=========================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm\|ngrok\|cloudflared" 2>/dev/null || true
lsof -ti:5173,5174,8000,4040 | xargs kill -9 2>/dev/null || true
sleep 3

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 3

# Khởi động frontend
echo "🎨 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!
sleep 5

# Khởi động ngrok với token mới
echo "🌐 Khởi động ngrok với token mới..."
cd /Users/maybe/Documents/shopee
ngrok config add-authtoken 342Gw9izZ3uJJH4vo0JGOpEfMKB_5UiXcUoSQhw8jRjyyCqt5
ngrok http 5173 &
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

# Cập nhật cấu hình với URL mới
if [ ! -z "$NGROK_URL" ]; then
    echo "🔄 Cập nhật cấu hình với URL mới..."
    python3 update_config.py "$NGROK_URL"
    
    # Khởi động lại backend để áp dụng cấu hình mới
    echo "🔄 Khởi động lại backend với cấu hình mới..."
    kill $BACKEND_PID 2>/dev/null
    sleep 2
    uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
    BACKEND_PID=$!
    sleep 3
fi

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
echo "===================================="
echo "🔧 Backend: http://0.0.0.0:8000"
echo "🎨 Frontend: http://localhost:5173"
echo "🌍 Ngrok URL: $NGROK_URL"
echo ""
echo "📱 TRUY CẬP ỨNG DỤNG:"
echo "   $NGROK_URL"
echo ""
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, ngrok=$NGROK_PID"
echo ""
echo "💡 Để dừng hệ thống, nhấn Ctrl+C"

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
