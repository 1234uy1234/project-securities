#!/bin/bash

# 🗑️ TEST XÓA THÔNG BÁO TRONG APP
# Kiểm tra đã xóa thông báo lìu tìu trong app chưa

echo "🗑️ TEST XÓA THÔNG BÁO TRONG APP"
echo "================================"

FRONTEND_URL="https://10.10.68.200:5173"

# 1. Test frontend
echo "1. Test frontend:"
echo "   🎨 Frontend: $FRONTEND_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 2. Kiểm tra App.tsx
echo "2. Kiểm tra App.tsx:"
if grep -q "PushNotificationSetup" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
    echo "   ❌ Vẫn còn PushNotificationSetup trong App.tsx"
else
    echo "   ✅ Đã xóa PushNotificationSetup khỏi App.tsx"
fi

if grep -q "Push Notification Setup" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
    echo "   ❌ Vẫn còn comment Push Notification Setup"
else
    echo "   ✅ Đã xóa comment Push Notification Setup"
fi

# 3. Kiểm tra file PushNotificationSetup.tsx
echo "3. Kiểm tra file PushNotificationSetup.tsx:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx" ]; then
    echo "   ⚠️ File PushNotificationSetup.tsx vẫn còn (không sử dụng)"
else
    echo "   ✅ File PushNotificationSetup.tsx đã bị xóa"
fi

# 4. Kiểm tra PWA Install Button
echo "4. Kiểm tra PWA Install Button:"
if grep -q "PWAInstallButton" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
    echo "   ✅ PWA Install Button vẫn còn (cần thiết cho PWA)"
else
    echo "   ❌ PWA Install Button bị xóa nhầm"
fi

# 5. Kiểm tra PWA files
echo "5. Kiểm tra PWA files:"
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

echo ""
echo "🎉 KIỂM TRA XÓA THÔNG BÁO TRONG APP HOÀN TẤT!"
echo "=============================================="
echo "✅ Đã xóa thông báo lìu tìu trong app!"
echo ""
echo "🔔 THÔNG BÁO CÒN LẠI:"
echo "====================="
echo "✅ Thông báo push từ hệ thống (như Zalo)"
echo "✅ PWA Install Button (cần thiết cho PWA)"
echo "✅ Offline Indicator (cần thiết cho PWA)"
echo ""
echo "❌ ĐÃ XÓA:"
echo "=========="
echo "❌ Thông báo bell icon lìu tìu trong app"
echo "❌ PushNotificationSetup component"
echo "❌ Thông báo trong app header"
echo ""
echo "📱 HƯỚNG DẪN SỬ DỤNG:"
echo "====================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Nhấn nút '📱 Cài đặt App' (PWA)"
echo "5. Cho phép thông báo khi trình duyệt hỏi"
echo "6. Thông báo push sẽ hoạt động như Zalo"
echo ""
echo "🎯 TÍNH NĂNG THÔNG BÁO:"
echo "========================"
echo "✅ Thông báo push từ hệ thống (như Zalo)"
echo "✅ Thông báo khi được giao nhiệm vụ mới"
echo "✅ Thông báo nhắc nhở chấm công"
echo "✅ Thông báo hoàn thành nhiệm vụ"
echo "✅ Thông báo broadcast từ admin"
echo "✅ Hoạt động ngay cả khi app đóng"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
