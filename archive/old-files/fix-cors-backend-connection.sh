#!/bin/bash

echo "🔧 SỬA LỖI CORS VÀ BACKEND CONNECTION"
echo "===================================="
echo ""

echo "🔍 Kiểm tra tình trạng hiện tại:"
echo ""

echo "📋 Backend processes:"
ps aux | grep -E "(uvicorn.*10.10.68.200)" | grep -v grep

echo ""
echo "📋 Frontend processes:"
ps aux | grep -E "(npm.*dev|vite)" | grep -v grep

echo ""
echo "🔧 Khởi động lại hệ thống với cấu hình đúng:"

# Dừng tất cả processes
echo "1. Dừng tất cả processes..."
pkill -f "uvicorn.*main" 2>/dev/null
pkill -f "npm.*dev" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 3

# Khởi động backend với IP đúng
echo "2. Khởi động Backend với IP 10.10.68.200..."
cd /Users/maybe/Documents/shopee/backend
python -m uvicorn app.main:app --host 10.10.68.200 --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt &
BACKEND_PID=$!

# Đợi backend khởi động
sleep 5

# Kiểm tra backend
echo "3. Kiểm tra Backend..."
if curl -k -s -o /dev/null -w "%{http_code}" https://10.10.68.200:8000/api/locations/ | grep -q "405\|401"; then
    echo "   ✅ Backend đang chạy (HTTP 405/401 là bình thường - cần auth)"
else
    echo "   ❌ Backend không phản hồi"
fi

# Khởi động frontend
echo "4. Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
VITE_API_BASE_URL=https://10.10.68.200:8000 npm run dev -- --host 10.10.68.200 --port 5173 --https &
FRONTEND_PID=$!

# Đợi frontend khởi động
sleep 8

echo ""
echo "🔍 Kiểm tra sau khi khởi động lại:"
echo ""

echo "📋 Backend processes:"
ps aux | grep -E "(uvicorn.*10.10.68.200)" | grep -v grep

echo ""
echo "📋 Frontend processes:"
ps aux | grep -E "(npm.*dev|vite)" | grep -v grep

echo ""
echo "🌐 Truy cập ứng dụng:"
echo "   Frontend: https://10.10.68.200:5173"
echo "   Backend API: https://10.10.68.200:8000/api/"
echo ""

echo "📋 Nếu vẫn có lỗi CORS:"
echo "   1. Kiểm tra browser console"
echo "   2. Thử refresh trang (Ctrl+F5)"
echo "   3. Kiểm tra SSL certificate"
echo "   4. Đảm bảo cả frontend và backend đều chạy trên IP 10.10.68.200"
echo ""

echo "✅ Hoàn thành khởi động lại hệ thống!"

