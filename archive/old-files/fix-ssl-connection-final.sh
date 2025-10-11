#!/bin/bash

echo "🔧 SỬA LỖI SSL VÀ KẾT NỐI HOÀN TOÀN"
echo "===================================="
echo ""

echo "🔍 Vấn đề: ERR_SSL_VERSION_OR_CIPHER_MISMATCH"
echo "🔧 Giải pháp: Sử dụng HTTP cho frontend, HTTPS cho backend"
echo ""

# Dừng tất cả processes
echo "1. Dừng tất cả processes..."
pkill -f "npm.*dev" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 3

# Khởi động backend với HTTPS
echo "2. Khởi động Backend với HTTPS..."
cd /Users/maybe/Documents/shopee/backend
python -m uvicorn app.main:app --host 10.10.68.200 --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt &
sleep 5

# Kiểm tra backend
echo "3. Kiểm tra Backend..."
if curl -k -s -o /dev/null -w "%{http_code}" https://10.10.68.200:8000/api/locations/ | grep -q "401\|403"; then
    echo "   ✅ Backend đang chạy với HTTPS"
else
    echo "   ❌ Backend không phản hồi"
fi

# Khởi động frontend với HTTP
echo "4. Khởi động Frontend với HTTP..."
cd /Users/maybe/Documents/shopee/frontend
VITE_API_BASE_URL=https://10.10.68.200:8000 npm run dev -- --host 10.10.68.200 --port 5173 &
sleep 8

# Kiểm tra frontend
echo "5. Kiểm tra Frontend..."
if curl -s -o /dev/null -w "%{http_code}" http://10.10.68.200:5173 | grep -q "200"; then
    echo "   ✅ Frontend đang chạy với HTTP"
else
    echo "   ⚠️  Frontend có thể chưa sẵn sàng hoàn toàn"
fi

echo ""
echo "🔍 Kiểm tra cuối cùng:"
echo ""

echo "📋 Backend processes:"
ps aux | grep -E "(uvicorn.*10.10.68.200)" | grep -v grep

echo ""
echo "📋 Frontend processes:"
ps aux | grep -E "(npm.*dev|vite)" | grep -v grep

echo ""
echo "🌐 Truy cập ứng dụng:"
echo "   Frontend: http://10.10.68.200:5173"
echo "   Backend API: https://10.10.68.200:8000/api/"
echo ""

echo "📋 Hướng dẫn truy cập:"
echo "   1. Mở browser và truy cập http://10.10.68.200:5173"
echo "   2. Không cần accept SSL certificate vì frontend dùng HTTP"
echo "   3. Backend vẫn dùng HTTPS để bảo mật API"
echo "   4. Kiểm tra browser console để xem còn lỗi gì không"
echo ""

echo "⚠️  Lưu ý:"
echo "   - Frontend: HTTP (không có SSL issues)"
echo "   - Backend: HTTPS (bảo mật API)"
echo "   - Đây là giải pháp tạm thời để tránh SSL issues"
echo ""

echo "✅ Hoàn thành sửa lỗi SSL và kết nối!"

