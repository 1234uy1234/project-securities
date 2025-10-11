#!/bin/bash

# 📱 TEST NÚT PUSH NOTIFICATION
# Kiểm tra nút push notification đã hiển thị chưa

echo "📱 TEST NÚT PUSH NOTIFICATION"
echo "=============================="
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
if [ -f "/Users/maybe/Documents/shopee/frontend/src/App.tsx" ]; then
    echo "   ✅ App.tsx có sẵn"
    if grep -q "PushNotificationSetup" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
        echo "   ✅ Đã import PushNotificationSetup"
    else
        echo "   ❌ Chưa import PushNotificationSetup"
    fi
    if grep -q "<PushNotificationSetup />" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
        echo "   ✅ Đã thêm <PushNotificationSetup />"
    else
        echo "   ❌ Chưa thêm <PushNotificationSetup />"
    fi
else
    echo "   ❌ App.tsx không tìm thấy"
fi

if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx" ]; then
    echo "   ✅ PushNotificationSetup.tsx có sẵn"
    if grep -q "handleEnableNotifications" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã có handleEnableNotifications"
    else
        echo "   ❌ Chưa có handleEnableNotifications"
    fi
    if grep -q "handleTestNotification" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã có handleTestNotification"
    else
        echo "   ❌ Chưa có handleTestNotification"
    fi
else
    echo "   ❌ PushNotificationSetup.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA NÚT PUSH NOTIFICATION HOÀN TẤT!"
echo "============================================"
echo "✅ Đã thêm PushNotificationSetup vào App!"
echo ""
echo "📱 HƯỚNG DẪN TEST NÚT PUSH NOTIFICATION:"
echo "========================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Kiểm tra nút push notification:"
echo ""
echo "🔍 BƯỚC 1: TÌM NÚT PUSH NOTIFICATION"
echo "====================================="
echo "• Nút push notification sẽ hiện sau 3 giây"
echo "• Tìm nút có icon 🔔 (bell)"
echo "• Nút sẽ hiện ở góc màn hình"
echo "• Nếu không thấy, thử refresh trang"
echo ""
echo "🔍 BƯỚC 2: BẤM NÚT PUSH NOTIFICATION"
echo "====================================="
echo "• Bấm nút 'Enable Notifications'"
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
echo "⚠️ NẾU KHÔNG THẤY NÚT:"
echo "======================"
echo "• Thử refresh trang"
echo "• Kiểm tra console logs"
echo "• Đảm bảo đã đăng nhập"
echo "• Đảm bảo đang dùng HTTPS"
echo ""
echo "🔍 DEBUG CONSOLE LOGS:"
echo "======================"
echo "• Mở Developer Tools (F12)"
echo "• Vào tab Console"
echo "• Tìm các log sau:"
echo "  - 'PushNotificationSetup component loaded'"
echo "  - 'Push notifications initialized successfully'"
echo "  - 'Subscription sent to server successfully'"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
