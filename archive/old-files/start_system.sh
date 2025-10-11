#!/bin/bash

echo "🚀 Khởi động hệ thống MANHTOAN PLASTIC - Hệ thống Tuần tra"
echo "=================================================="

# Dừng các process cũ
echo "🛑 Dừng các process cũ..."
pkill -f "npm run dev" 2>/dev/null
pkill -f "uvicorn" 2>/dev/null
pkill -f "nginx" 2>/dev/null
pkill -f "ngrok" 2>/dev/null
sleep 2

# Tạo thư mục temp cho nginx
echo "📁 Tạo thư mục temp cho nginx..."
mkdir -p /tmp/nginx_client_body /tmp/nginx_proxy /tmp/nginx_fastcgi /tmp/nginx_uwsgi /tmp/nginx_scgi

# Khởi động Backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
python3 -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 3

# Khởi động Frontend
echo "🌐 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev -- --host 0.0.0.0 --port 5173 &
FRONTEND_PID=$!
sleep 3

# Khởi động Nginx Reverse Proxy
echo "🔄 Khởi động Nginx Reverse Proxy..."
cd /Users/maybe/Documents/shopee
nginx -c $(pwd)/nginx_combined.conf &
NGINX_PID=$!
sleep 2

# Khởi động Ngrok Tunnel
echo "🌍 Khởi động Ngrok Tunnel..."
ngrok http 10.10.68.200:8080 --log=stdout > ngrok_combined.log 2>&1 &
NGROK_PID=$!
sleep 5

# Lấy Ngrok URL
echo "🔗 Lấy Ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data.get('tunnels', []):
        if tunnel.get('proto') == 'https':
            print(tunnel.get('public_url'))
            break
except:
    print('')
")

if [ -n "$NGROK_URL" ]; then
    echo "✅ Ngrok URL: $NGROK_URL"
    
    # Cập nhật .env với Ngrok URL
    echo "📝 Cập nhật .env với Ngrok URL..."
    cat > frontend/.env << EOL
# Frontend và Backend cùng qua 1 Ngrok tunnel
NGROK_URL=$NGROK_URL
VITE_API_URL=$NGROK_URL
VITE_API_BASE_URL=$NGROK_URL/api
VITE_FRONTEND_URL=$NGROK_URL
VITE_BACKEND_URL=$NGROK_URL
VITE_WS_URL=$NGROK_URL/ws
EOL
    
    echo "🎉 Hệ thống đã khởi động thành công!"
    echo "🌐 Truy cập: $NGROK_URL"
    echo "👤 Đăng nhập: admin / admin123"
    echo ""
    echo "📊 Các service đang chạy:"
    echo "  - Backend: http://10.10.68.200:8000"
    echo "  - Frontend: http://10.10.68.200:5173"
    echo "  - Nginx: http://10.10.68.200:8080"
    echo "  - Ngrok: $NGROK_URL"
    echo ""
    echo "🛑 Để dừng hệ thống, chạy: ./stop_system.sh"
else
    echo "❌ Không thể lấy Ngrok URL"
    echo "🔧 Kiểm tra ngrok logs: tail -f ngrok_combined.log"
fi

# Lưu PIDs để có thể dừng sau
echo "$BACKEND_PID" > .backend.pid
echo "$FRONTEND_PID" > .frontend.pid
echo "$NGINX_PID" > .nginx.pid
echo "$NGROK_PID" > .ngrok.pid

echo "✅ Script hoàn thành!"
