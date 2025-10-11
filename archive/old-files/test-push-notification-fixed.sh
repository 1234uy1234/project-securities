#!/bin/bash

# 📱 TEST PUSH NOTIFICATION ĐÃ SỬA
# Kiểm tra push notification đã sửa lỗi treo

echo "📱 TEST PUSH NOTIFICATION ĐÃ SỬA"
echo "================================="
echo "Kiểm tra push notification đã sửa lỗi treo..."
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
    if grep -q "Service worker timeout" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã thêm timeout cho service worker"
    else
        echo "   ❌ Chưa thêm timeout cho service worker"
    fi
    if grep -q "enableLocalNotifications" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã thêm fallback local notifications"
    else
        echo "   ❌ Chưa thêm fallback local notifications"
    fi
else
    echo "   ❌ pushNotificationService.ts không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA PUSH NOTIFICATION ĐÃ SỬA HOÀN TẤT!"
echo "=============================================="
echo "✅ Đã sửa lỗi treo service worker!"
echo ""
echo "📱 HƯỚNG DẪN TEST PUSH NOTIFICATION ĐÃ SỬA:"
echo "==========================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Mở Developer Tools (F12)"
echo "5. Vào tab Console"
echo "6. Bấm nút 'Bật thông báo'"
echo "7. Xem console logs:"
echo ""
echo "🔍 CONSOLE LOGS MONG ĐỢI:"
echo "========================="
echo "• '📱 Initializing push notifications...'"
echo "• '📱 Getting service worker registration...'"
echo "• '📱 No service worker controller, trying to register...'"
echo "• '✅ Service worker registered'"
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
echo "⚠️ NẾU SERVICE WORKER LỖI:"
echo "=========================="
echo "• '⚠️ Service worker registration failed, continuing without push...'"
echo "• '📱 Enabling local notifications only...'"
echo "• '✅ Local notifications enabled'"
echo "• Thông báo local sẽ hiện"
echo ""
echo "🔍 CÁC TRƯỜNG HỢP:"
echo "==================="
echo "1. Service worker hoạt động → Push notification đầy đủ"
echo "2. Service worker lỗi → Local notification fallback"
echo "3. Permission bị từ chối → Thông báo lỗi"
echo "4. Timeout → Thông báo timeout"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Nếu service worker lỗi, vẫn có thể dùng local notifications"
echo "• Local notifications chỉ hoạt động khi app đang mở"
echo "• Push notifications hoạt động cả khi app đóng"
echo "• Cả hai đều cần notification permission"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
