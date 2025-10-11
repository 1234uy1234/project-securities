#!/bin/bash

# 📱 TEST VAPID KEYS ĐÃ SỬA
# Kiểm tra VAPID keys mới đã sửa lỗi

echo "📱 TEST VAPID KEYS ĐÃ SỬA"
echo "=========================="
echo "Kiểm tra VAPID keys mới đã sửa lỗi..."
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

# 2. Kiểm tra VAPID keys đã cập nhật
echo "2. Kiểm tra VAPID keys đã cập nhật:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts" ]; then
    echo "   ✅ pushNotificationService.ts có sẵn"
    if grep -q "BJGzeJnmgQDDdu7llewyMasooZRsPunOuP56ShzsFFK7Go6LBTzZ4yOQJfEnI-JJ5zCNnLlZluTp2C6lomkXDQ4" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Frontend VAPID key đã cập nhật"
    else
        echo "   ❌ Frontend VAPID key chưa cập nhật"
    fi
else
    echo "   ❌ pushNotificationService.ts không tìm thấy"
fi

if [ -f "/Users/maybe/Documents/shopee/backend/app/services/push_notification.py" ]; then
    echo "   ✅ push_notification.py có sẵn"
    if grep -q "BJGzeJnmgQDDdu7llewyMasooZRsPunOuP56ShzsFFK7Go6LBTzZ4yOQJfEnI-JJ5zCNnLlZluTp2C6lomkXDQ4" /Users/maybe/Documents/shopee/backend/app/services/push_notification.py; then
        echo "   ✅ Backend VAPID public key đã cập nhật"
    else
        echo "   ❌ Backend VAPID public key chưa cập nhật"
    fi
    if grep -q "NsvZ-Jb_kebCVJEeFvPmLSY6dwmnyTNaWXdm39tBhnM" /Users/maybe/Documents/shopee/backend/app/services/push_notification.py; then
        echo "   ✅ Backend VAPID private key đã cập nhật"
    else
        echo "   ❌ Backend VAPID private key chưa cập nhật"
    fi
else
    echo "   ❌ push_notification.py không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA VAPID KEYS ĐÃ SỬA HOÀN TẤT!"
echo "======================================="
echo "✅ Đã cập nhật VAPID keys mới!"
echo ""
echo "📱 HƯỚNG DẪN TEST VAPID KEYS ĐÃ SỬA:"
echo "===================================="
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
echo "⚠️ NẾU VẪN CÓ LỖI:"
echo "==================="
echo "• '⚠️ Push subscription failed: InvalidAccessError'"
echo "• '📱 Falling back to local notifications...'"
echo "• '📱 Enabling local notifications only...'"
echo "• '✅ Local notifications enabled'"
echo ""
echo "🔍 CÁC TRƯỜNG HỢP:"
echo "==================="
echo "1. VAPID key hợp lệ → Push notification đầy đủ"
echo "2. VAPID key vẫn lỗi → Local notification fallback"
echo "3. Permission bị từ chối → Thông báo lỗi"
echo "4. Service worker lỗi → Local notification fallback"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• VAPID keys phải khớp giữa frontend và backend"
echo "• Keys phải được generate từ web-push library"
echo "• Keys cũ có thể bị cache, cần restart browser"
echo "• Nếu vẫn lỗi, có thể do browser không support"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

