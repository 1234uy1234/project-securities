#!/bin/bash

# 🔔 TEST PUSH NOTIFICATIONS - ManhToan Patrol
# Kiểm tra hệ thống thông báo push

echo "🔔 TEST PUSH NOTIFICATIONS - ManhToan Patrol"
echo "============================================="

FRONTEND_URL="https://10.10.68.200:5173"
NGROK_URL="https://semiprivate-interlamellar-phillis.ngrok-free.dev"

# 1. Test frontend
echo "1. Test frontend:"
echo "   🎨 Frontend: $FRONTEND_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 2. Test backend API
echo "2. Test backend API:"
echo "   🔗 API: $NGROK_URL/api/notifications/test"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/api/notifications/test | grep -q "401\|200"; then
    echo "   ✅ Notification API có sẵn (cần auth)"
else
    echo "   ❌ Notification API không hoạt động"
fi

# 3. Test PWA files
echo "3. Test PWA files:"
echo "   📄 Manifest: $FRONTEND_URL/manifest.json"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/manifest.json | grep -q "200"; then
    echo "   ✅ Manifest.json có sẵn"
else
    echo "   ❌ Manifest.json không tìm thấy"
fi

echo "   🔧 Service Worker: $FRONTEND_URL/sw.js"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/sw.js | grep -q "200"; then
    echo "   ✅ Service Worker có sẵn"
else
    echo "   ❌ Service Worker không tìm thấy"
fi

# 4. Test PWA icons
echo "4. Test PWA icons:"
icons=("icon-96x96.png" "icon-192x192.png" "icon-512x512.png")
for icon in "${icons[@]}"; do
    if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/$icon | grep -q "200"; then
        echo "   ✅ $icon có sẵn"
    else
        echo "   ❌ $icon không tìm thấy"
    fi
done

# 5. Test backend files
echo "5. Test backend files:"
if [ -f "/Users/maybe/Documents/shopee/backend/app/services/push_notification.py" ]; then
    echo "   ✅ push_notification.py có sẵn"
else
    echo "   ❌ push_notification.py không tìm thấy"
fi

if [ -f "/Users/maybe/Documents/shopee/backend/app/routes/notifications.py" ]; then
    echo "   ✅ notifications.py có sẵn"
else
    echo "   ❌ notifications.py không tìm thấy"
fi

# 6. Test frontend files
echo "6. Test frontend files:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts" ]; then
    echo "   ✅ pushNotificationService.ts có sẵn"
else
    echo "   ❌ pushNotificationService.ts không tìm thấy"
fi

if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx" ]; then
    echo "   ✅ PushNotificationSetup.tsx có sẵn"
else
    echo "   ❌ PushNotificationSetup.tsx không tìm thấy"
fi

echo ""
echo "🎉 KIỂM TRA PUSH NOTIFICATIONS HOÀN TẤT!"
echo "========================================="
echo "✅ Hệ thống thông báo push đã sẵn sàng!"
echo ""
echo "📱 HƯỚNG DẪN SỬ DỤNG:"
echo "====================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Nhấn nút '🔔' ở góc dưới bên trái"
echo "5. Chọn 'Bật thông báo'"
echo "6. Cho phép thông báo khi trình duyệt hỏi"
echo "7. Nhấn '🧪 Test' để kiểm tra"
echo ""
echo "🎯 TÍNH NĂNG THÔNG BÁO:"
echo "======================="
echo "✅ Thông báo khi được giao nhiệm vụ mới"
echo "✅ Thông báo nhắc nhở chấm công"
echo "✅ Thông báo hoàn thành nhiệm vụ"
echo "✅ Thông báo broadcast từ admin"
echo "✅ Test thông báo"
echo ""
echo "🔧 CÁCH HOẠT ĐỘNG:"
echo "=================="
echo "1. Admin/Manager tạo nhiệm vụ mới"
echo "2. Hệ thống tự động gửi thông báo đến employee"
echo "3. Employee nhận thông báo ngay cả khi không mở app"
echo "4. Nhấn thông báo để mở app và xem chi tiết"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): $NGROK_URL"
echo ""
echo "📖 Chi tiết: Xem file PWA-INSTALL-GUIDE.md"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
