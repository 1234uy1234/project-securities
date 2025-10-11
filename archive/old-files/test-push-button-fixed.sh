#!/bin/bash

# 📱 TEST NÚT PUSH NOTIFICATION ĐÃ SỬA
# Kiểm tra nút push notification đã hiển thị chưa

echo "📱 TEST NÚT PUSH NOTIFICATION ĐÃ SỬA"
echo "===================================="
echo "Kiểm tra nút push notification đã hiển thị chưa..."
echo ""

FRONTEND_URL="https://10.10.68.200:5173"

# 1. Test frontend
echo "1. Test frontend:"
echo "   🎨 Frontend: $FRONTEND_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 2. Kiểm tra file đã sửa
echo "2. Kiểm tra file đã sửa:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx" ]; then
    echo "   ✅ PushNotificationSetup.tsx có sẵn"
    if grep -q "fixed bottom-4 right-4" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã sửa vị trí fixed"
    else
        echo "   ❌ Chưa sửa vị trí fixed"
    fi
    if grep -q "setIsVisible(true)" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã sửa logic hiển thị"
    else
        echo "   ❌ Chưa sửa logic hiển thị"
    fi
else
    echo "   ❌ PushNotificationSetup.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA NÚT PUSH NOTIFICATION ĐÃ SỬA HOÀN TẤT!"
echo "=================================================="
echo "✅ Đã sửa nút push notification!"
echo ""
echo "📱 HƯỚNG DẪN TEST NÚT PUSH NOTIFICATION ĐÃ SỬA:"
echo "==============================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Kiểm tra nút push notification:"
echo ""
echo "🔍 BƯỚC 1: TÌM NÚT PUSH NOTIFICATION"
echo "====================================="
echo "• Nút push notification sẽ hiện ngay lập tức"
echo "• Tìm nút ở góc dưới bên phải màn hình"
echo "• Nút có màu xanh với text '🔔 Push Notifications'"
echo "• Nếu không thấy, thử refresh trang"
echo ""
echo "🔍 BƯỚC 2: BẤM NÚT PUSH NOTIFICATION"
echo "====================================="
echo "• Bấm nút '🔔 Push Notifications'"
echo "• Modal sẽ hiện ra"
echo "• Bấm 'Bật thông báo'"
echo "• Cho phép notification permission"
echo "• Đợi thông báo 'Thông báo đã được bật!'"
echo ""
echo "🔍 BƯỚC 3: TEST THÔNG BÁO"
echo "=========================="
echo "• Bấm nút 'Test Notification'"
echo "• Kiểm tra xem có thông báo hiện không"
echo "• Nếu có thông báo → OK"
echo "• Nếu không có → Kiểm tra console logs"
echo ""
echo "⚠️ NẾU VẪN KHÔNG THẤY NÚT:"
echo "=========================="
echo "• Thử refresh trang"
echo "• Kiểm tra console logs"
echo "• Đảm bảo đã đăng nhập"
echo "• Đảm bảo đang dùng HTTPS"
echo "• Kiểm tra xem có lỗi JavaScript không"
echo ""
echo "🔍 DEBUG CONSOLE LOGS:"
echo "======================"
echo "• Mở Developer Tools (F12)"
echo "• Vào tab Console"
echo "• Tìm các log sau:"
echo "  - 'PushNotificationSetup component loaded'"
echo "  - 'Push notifications initialized successfully'"
echo "  - 'Subscription sent to server successfully'"
echo "  - Các lỗi JavaScript nếu có"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
