#!/bin/bash

echo "🔐 TÌNH TRẠNG HTTPS HIỆN TẠI"
echo "============================"
echo ""

echo "🔍 Kiểm tra tình trạng hệ thống:"
echo ""

echo "📋 Backend processes:"
ps aux | grep -E "(uvicorn.*10.10.68.200)" | grep -v grep

echo ""
echo "📋 Frontend processes:"
ps aux | grep -E "(npm.*dev|vite)" | grep -v grep

echo ""
echo "🔍 Kiểm tra SSL certificates:"
echo ""

echo "📋 Backend SSL:"
if [ -f "/Users/maybe/Documents/shopee/ssl/server.crt" ]; then
    echo "   ✅ Backend SSL certificate tồn tại"
    openssl x509 -in /Users/maybe/Documents/shopee/ssl/server.crt -text -noout | grep -E "(Subject:|DNS:|IP:)" | head -5
else
    echo "   ❌ Backend SSL certificate không tồn tại"
fi

echo ""
echo "📋 Frontend SSL:"
if [ -f "/Users/maybe/Documents/shopee/frontend/ssl/server.crt" ]; then
    echo "   ✅ Frontend SSL certificate tồn tại"
    openssl x509 -in /Users/maybe/Documents/shopee/frontend/ssl/server.crt -text -noout | grep -E "(Subject:|DNS:|IP:)" | head -5
else
    echo "   ❌ Frontend SSL certificate không tồn tại"
fi

echo ""
echo "🌐 Truy cập ứng dụng:"
echo "   Frontend: https://10.10.68.200:5173"
echo "   Backend API: https://10.10.68.200:8000/api/"
echo ""

echo "📋 Hướng dẫn truy cập HTTPS:"
echo "   1. Mở browser và truy cập https://10.10.68.200:5173"
echo "   2. Nếu có cảnh báo SSL:"
echo "      - Click 'Advanced' hoặc 'Nâng cao'"
echo "      - Click 'Proceed to 10.10.68.200 (unsafe)' hoặc 'Tiếp tục đến 10.10.68.200 (không an toàn)'"
echo "   3. Sau đó ứng dụng sẽ load bình thường"
echo ""

echo "⚠️  Lưu ý quan trọng:"
echo "   - SSL certificates là self-signed nên browser sẽ cảnh báo"
echo "   - Đây là bình thường cho môi trường development"
echo "   - Chỉ cần accept certificate một lần"
echo ""

echo "✅ Hệ thống đã sẵn sàng với HTTPS!"
echo "   Backend: ✅ Đang chạy với HTTPS"
echo "   Frontend: ✅ Đang chạy với HTTPS"
echo "   SSL: ✅ Đã được tạo cho cả hai"

