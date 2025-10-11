#!/bin/bash

# 🔍 DEBUG PUSH NOTIFICATION
# Kiểm tra từng bước để tìm ra vấn đề

echo "🔍 DEBUG PUSH NOTIFICATION"
echo "==========================="
echo "Kiểm tra từng bước để tìm ra vấn đề..."
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

# 2. Kiểm tra service worker
echo "2. Kiểm tra service worker:"
if [ -f "/Users/maybe/Documents/shopee/frontend/public/sw.js" ]; then
    echo "   ✅ sw.js có sẵn"
    if grep -q "requireInteraction: true" /Users/maybe/Documents/shopee/frontend/public/sw.js; then
        echo "   ✅ Đã có requireInteraction: true"
    else
        echo "   ❌ Chưa có requireInteraction: true"
    fi
    if grep -q "push" /Users/maybe/Documents/shopee/frontend/public/sw.js; then
        echo "   ✅ Đã có push event handler"
    else
        echo "   ❌ Chưa có push event handler"
    fi
else
    echo "   ❌ sw.js không tìm thấy"
fi

# 3. Kiểm tra backend push service
echo "3. Kiểm tra backend push service:"
if [ -f "/Users/maybe/Documents/shopee/backend/app/services/push_notification.py" ]; then
    echo "   ✅ push_notification.py có sẵn"
    if grep -q "webpush" /Users/maybe/Documents/shopee/backend/app/services/push_notification.py; then
        echo "   ✅ Đã import webpush"
    else
        echo "   ❌ Chưa import webpush"
    fi
    if grep -q "REAL PUSH SENT" /Users/maybe/Documents/shopee/backend/app/services/push_notification.py; then
        echo "   ✅ Đã có log REAL PUSH SENT"
    else
        echo "   ❌ Chưa có log REAL PUSH SENT"
    fi
else
    echo "   ❌ push_notification.py không tìm thấy"
fi

# 4. Kiểm tra frontend push service
echo "4. Kiểm tra frontend push service:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts" ]; then
    echo "   ✅ pushNotificationService.ts có sẵn"
    if grep -q "/api/push/subscribe" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã sửa endpoint subscribe"
    else
        echo "   ❌ Chưa sửa endpoint subscribe"
    fi
    if grep -q "Notification.requestPermission" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã có requestPermission"
    else
        echo "   ❌ Chưa có requestPermission"
    fi
else
    echo "   ❌ pushNotificationService.ts không tìm thấy"
fi

# 5. Kiểm tra push setup component
echo "5. Kiểm tra push setup component:"
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
echo "🔍 DEBUG HOÀN TẤT!"
echo "=================="
echo "✅ Đã kiểm tra tất cả components"
echo ""
echo "📱 HƯỚNG DẪN DEBUG TỪNG BƯỚC:"
echo "=============================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Mở Developer Tools (F12)"
echo "4. Vào tab Console"
echo "5. Kiểm tra các bước sau:"
echo ""
echo "🔍 BƯỚC 1: KIỂM TRA PWA"
echo "========================"
echo "• Kiểm tra xem có nút 'Cài đặt App' không"
echo "• Nếu có, bấm cài đặt PWA"
echo "• Nếu không có, thử menu → 'Add to Home Screen'"
echo "• Cài đặt app như app thật"
echo ""
echo "🔍 BƯỚC 2: KIỂM TRA NOTIFICATION PERMISSION"
echo "==========================================="
echo "• Vào Settings → Push Notifications"
echo "• Kiểm tra trạng thái permission"
echo "• Nếu chưa bật, bấm 'Enable Notifications'"
echo "• Cho phép notification permission khi browser hỏi"
echo ""
echo "🔍 BƯỚC 3: KIỂM TRA CONSOLE LOGS"
echo "================================"
echo "• Mở Developer Tools (F12)"
echo "• Vào tab Console"
echo "• Tìm các log sau:"
echo "  - 'Push notifications initialized successfully'"
echo "  - 'Subscription sent to server successfully'"
echo "  - 'Service Worker: Push notification received!'"
echo ""
echo "🔍 BƯỚC 4: TEST THÔNG BÁO THỦ CÔNG"
echo "=================================="
echo "• Bấm nút 'Test Notification'"
echo "• Kiểm tra xem có thông báo hiện không"
echo "• Nếu không có, kiểm tra console logs"
echo ""
echo "🔍 BƯỚC 5: KIỂM TRA SERVICE WORKER"
echo "=================================="
echo "• Vào Developer Tools → Application → Service Workers"
echo "• Kiểm tra xem service worker có active không"
echo "• Nếu không, thử refresh trang"
echo ""
echo "🔍 BƯỚC 6: KIỂM TRA PUSH SUBSCRIPTION"
echo "====================================="
echo "• Vào Developer Tools → Application → Storage"
echo "• Kiểm tra xem có push subscription không"
echo "• Nếu không có, thử bật lại notification"
echo ""
echo "⚠️ CÁC VẤN ĐỀ THƯỜNG GẶP:"
echo "========================"
echo "• Chưa cài đặt PWA → Cài đặt PWA trước"
echo "• Chưa bật notification permission → Bật permission"
echo "• Service worker chưa active → Refresh trang"
echo "• Chưa đăng ký push subscription → Bật notification"
echo "• Browser không hỗ trợ → Dùng Chrome/Firefox"
echo "• Đang dùng HTTP → Cần HTTPS cho push notification"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
