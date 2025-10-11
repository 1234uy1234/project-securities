#!/bin/bash

echo "🔐 Khởi động ứng dụng với HTTPS FINAL..."

# Dừng tất cả process cũ
echo "🛑 Dừng các process cũ..."
pkill -f "python.*app" 2>/dev/null
pkill -f "npm.*dev" 2>/dev/null
pkill -f "uvicorn" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 3

# Cố định IP tĩnh
CURRENT_IP="10.10.68.200"
echo "📍 IP cố định: $CURRENT_IP"

# Khởi động backend với HTTPS
echo "🔧 Khởi động Backend với HTTPS..."
cd backend
python -m uvicorn app.main:app --host $CURRENT_IP --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt &
BACKEND_PID=$!

# Đợi backend khởi động
echo "⏳ Đợi backend khởi động..."
sleep 5

# Khởi động frontend với HTTPS
echo "🎨 Khởi động Frontend với HTTPS..."
cd ../frontend
VITE_API_BASE_URL=https://$CURRENT_IP:8000 npm run dev -- --host localhost --port 5173 --https &
FRONTEND_PID=$!

# Đợi frontend khởi động
echo "⏳ Đợi frontend khởi động..."
sleep 8

# Test kết nối
echo "🔍 Test kết nối..."
curl -k -I "https://$CURRENT_IP:8000/health" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Backend HTTPS: OK"
else
    echo "❌ Backend HTTPS: FAIL"
fi

curl -k -I "https://localhost:5173" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Frontend HTTPS: OK"
else
    echo "❌ Frontend HTTPS: FAIL"
fi

echo ""
echo "🎯 ỨNG DỤNG ĐÃ KHỞI ĐỘNG VỚI HTTPS:"
echo "   Frontend: https://localhost:5173"
echo "   Backend:  https://$CURRENT_IP:8000"
echo "   API Docs: https://$CURRENT_IP:8000/docs"
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
    kill $FRONTEND_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "npm.*dev" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait
