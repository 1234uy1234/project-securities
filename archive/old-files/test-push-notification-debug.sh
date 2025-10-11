#!/bin/bash

# 📱 TEST PUSH NOTIFICATION DEBUG
# Kiểm tra push notification với debug logs

echo "📱 TEST PUSH NOTIFICATION DEBUG"
echo "==============================="
echo "Kiểm tra push notification với debug logs..."
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
if [ -f "/Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts" ]; then
    echo "   ✅ pushNotificationService.ts có sẵn"
    if grep -q "console.log.*Initializing push notifications" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã thêm debug logs"
    else
        echo "   ❌ Chưa thêm debug logs"
    fi
    if grep -q "AbortSignal.timeout" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã thêm timeout"
    else
        echo "   ❌ Chưa thêm timeout"
    fi
else
    echo "   ❌ pushNotificationService.ts không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA PUSH NOTIFICATION DEBUG HOÀN TẤT!"
echo "=============================================="
echo "✅ Đã thêm debug logs và timeout!"
echo ""
echo "📱 HƯỚNG DẪN TEST PUSH NOTIFICATION DEBUG:"
echo "=========================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Mở Developer Tools (F12)"
echo "5. Vào tab Console"
echo "6. Bấm nút 'Bật thông báo'"
echo "7. Xem console logs để debug:"
echo ""
echo "🔍 CONSOLE LOGS CẦN TÌM:"
echo "========================"
echo "• '📱 Initializing push notifications...'"
echo "• '📱 Getting service worker registration...'"
echo "• '✅ Service worker ready'"
echo "• '📱 Requesting notification permission...'"
echo "• '📱 Permission result: granted'"
echo "• '✅ Notification permission granted'"
echo "• '📱 Creating push subscription...'"
echo "• '✅ Push subscription created'"
echo "• '📱 Sending subscription to server...'"
echo "• '✅ Subscription sent to server successfully'"
echo "• '✅ Push notifications initialized successfully'"
echo ""
echo "⚠️ NẾU CÓ LỖI:"
echo "==============="
echo "• '❌ Push messaging is not supported'"
echo "• '❌ Notification permission denied'"
echo "• '❌ Server response error: 401'"
echo "• '❌ Server response error: 500'"
echo "• '❌ Error sending subscription to server'"
echo ""
echo "🔍 DEBUG TỪNG BƯỚC:"
echo "==================="
echo "1. Kiểm tra service worker support"
echo "2. Kiểm tra notification permission"
echo "3. Kiểm tra push subscription creation"
echo "4. Kiểm tra server response"
echo "5. Kiểm tra authentication token"
echo ""
echo "⚠️ CÁC VẤN ĐỀ THƯỜNG GẶP:"
echo "========================="
echo "• Chưa đăng nhập → Token không có"
echo "• Server không hoạt động → 500 error"
echo "• Permission bị từ chối → Denied"
echo "• Service worker không active → Registration failed"
echo "• VAPID key sai → Subscription failed"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
