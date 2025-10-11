#!/bin/bash

# 🔄 RESTART FRONTEND
# Restart frontend để load code mới

echo "🔄 RESTART FRONTEND"
echo "==================="
echo "Restart frontend để load code mới..."
echo ""

# 1. Kill existing frontend processes
echo "1. Dừng frontend hiện tại:"
pkill -f "vite" || echo "   Không có process vite nào đang chạy"
pkill -f "npm run dev" || echo "   Không có process npm run dev nào đang chạy"
pkill -f "yarn dev" || echo "   Không có process yarn dev nào đang chạy"

# 2. Wait a moment
echo "2. Chờ 2 giây..."
sleep 2

# 3. Start frontend
echo "3. Khởi động frontend mới:"
cd /Users/maybe/Documents/shopee/frontend
npm run dev -- --host 0.0.0.0 --port 5173 &

# 4. Wait for frontend to start
echo "4. Chờ frontend khởi động..."
sleep 5

# 5. Test frontend
echo "5. Test frontend:"
FRONTEND_URL="https://10.10.68.200:5173"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend đã khởi động thành công"
else
    echo "   ❌ Frontend chưa khởi động"
fi

echo ""
echo "🔄 RESTART FRONTEND HOÀN TẤT!"
echo "============================="
echo "✅ Frontend đã được restart!"
echo ""
echo "📱 HƯỚNG DẪN TEST:"
echo "=================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Xem góc dưới bên phải màn hình"
echo "5. Kiểm tra icon chuông nhỏ tròn"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để clear cache"
echo "• Icon chuông tròn nhỏ thay vì button lớn"
echo "• Modal chỉ mở khi bấm vào icon"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"

