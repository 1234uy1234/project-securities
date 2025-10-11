#!/bin/bash

echo "🔐 Khởi động ứng dụng với Nginx HTTPS Reverse Proxy..."

# Dừng tất cả process cũ
echo "🛑 Dừng các process cũ..."
pkill -f "python.*app" 2>/dev/null
pkill -f "npm.*dev" 2>/dev/null
pkill -f "uvicorn" 2>/dev/null
pkill -f "vite" 2>/dev/null
pkill -f "nginx" 2>/dev/null
sleep 3

# Lấy IP hiện tại
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
if [ -z "$CURRENT_IP" ]; then
    echo "❌ Không thể lấy được IP hiện tại!"
    exit 1
fi

echo "📍 IP hiện tại: $CURRENT_IP"

# Cập nhật nginx config với IP hiện tại
echo "🔧 Cập nhật nginx config..."
sed -i.bak "s/localhost/$CURRENT_IP/g" nginx-https.conf

# Build frontend
echo "🏗️  Build frontend..."
cd frontend
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Build frontend thất bại!"
    exit 1
fi
cd ..

# Khởi động backend với HTTPS
echo "🔧 Khởi động Backend với HTTPS..."
cd backend
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt &
BACKEND_PID=$!

# Đợi backend khởi động
echo "⏳ Đợi backend khởi động..."
sleep 5

# Test backend
echo "🔍 Test backend..."
curl -k -I "https://127.0.0.1:8000/health" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Backend HTTPS: OK"
else
    echo "❌ Backend HTTPS: FAIL"
fi

# Khởi động nginx
echo "🌐 Khởi động Nginx reverse proxy..."
/usr/local/opt/nginx/bin/nginx -c /Users/maybe/Documents/shopee/nginx-https.conf &
NGINX_PID=$!

# Đợi nginx khởi động
echo "⏳ Đợi nginx khởi động..."
sleep 3

# Test nginx
echo "🔍 Test nginx..."
curl -k -I "https://$CURRENT_IP/" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Nginx HTTPS: OK"
else
    echo "❌ Nginx HTTPS: FAIL"
fi

curl -k -I "https://$CURRENT_IP/api/health" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ API HTTPS: OK"
else
    echo "❌ API HTTPS: FAIL"
fi

echo ""
echo "🎯 ỨNG DỤNG ĐÃ KHỞI ĐỘNG VỚI NGINX HTTPS:"
echo "   Frontend: https://$CURRENT_IP/"
echo "   Backend:  https://$CURRENT_IP/api/"
echo "   API Docs: https://$CURRENT_IP/api/docs"
echo ""
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📱 Để dừng ứng dụng, nhấn Ctrl+C"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Đang dừng ứng dụng..."
    kill $BACKEND_PID 2>/dev/null
    kill $NGINX_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "nginx" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait
