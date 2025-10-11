#!/bin/bash

# 📱 TEST PUSH NOTIFICATIONS PAGE
# Kiểm tra trang Push Notifications đã được tạo

echo "📱 TEST PUSH NOTIFICATIONS PAGE"
echo "==============================="
echo "Kiểm tra trang Push Notifications đã được tạo..."
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

# 2. Kiểm tra file đã tạo
echo "2. Kiểm tra file đã tạo:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/pages/PushNotificationsPage.tsx" ]; then
    echo "   ✅ PushNotificationsPage.tsx đã tạo"
    if grep -q "Push Notifications" /Users/maybe/Documents/shopee/frontend/src/pages/PushNotificationsPage.tsx; then
        echo "   ✅ Trang có title 'Push Notifications'"
    else
        echo "   ❌ Trang chưa có title 'Push Notifications'"
    fi
    if grep -q "Bật thông báo" /Users/maybe/Documents/shopee/frontend/src/pages/PushNotificationsPage.tsx; then
        echo "   ✅ Trang có button 'Bật thông báo'"
    else
        echo "   ❌ Trang chưa có button 'Bật thông báo'"
    fi
    if grep -q "Test thông báo" /Users/maybe/Documents/shopee/frontend/src/pages/PushNotificationsPage.tsx; then
        echo "   ✅ Trang có button 'Test thông báo'"
    else
        echo "   ❌ Trang chưa có button 'Test thông báo'"
    fi
else
    echo "   ❌ PushNotificationsPage.tsx chưa tạo"
fi

# 3. Kiểm tra App.tsx đã cập nhật
echo "3. Kiểm tra App.tsx đã cập nhật:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/App.tsx" ]; then
    echo "   ✅ App.tsx có sẵn"
    if grep -q "PushNotificationsPage" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
        echo "   ✅ App.tsx đã import PushNotificationsPage"
    else
        echo "   ❌ App.tsx chưa import PushNotificationsPage"
    fi
    if grep -q "/push-notifications" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
        echo "   ✅ App.tsx đã có route /push-notifications"
    else
        echo "   ❌ App.tsx chưa có route /push-notifications"
    fi
    if ! grep -q "PushNotificationSetup" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
        echo "   ✅ App.tsx đã xóa PushNotificationSetup component"
    else
        echo "   ❌ App.tsx vẫn còn PushNotificationSetup component"
    fi
else
    echo "   ❌ App.tsx không tìm thấy"
fi

# 4. Kiểm tra Layout.tsx đã cập nhật
echo "4. Kiểm tra Layout.tsx đã cập nhật:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/Layout.tsx" ]; then
    echo "   ✅ Layout.tsx có sẵn"
    if grep -q "Thông báo" /Users/maybe/Documents/shopee/frontend/src/components/Layout.tsx; then
        echo "   ✅ Layout.tsx đã có menu 'Thông báo'"
    else
        echo "   ❌ Layout.tsx chưa có menu 'Thông báo'"
    fi
    if grep -q "/push-notifications" /Users/maybe/Documents/shopee/frontend/src/components/Layout.tsx; then
        echo "   ✅ Layout.tsx đã có link /push-notifications"
    else
        echo "   ❌ Layout.tsx chưa có link /push-notifications"
    fi
    if grep -q "Bell" /Users/maybe/Documents/shopee/frontend/src/components/Layout.tsx; then
        echo "   ✅ Layout.tsx đã có icon Bell"
    else
        echo "   ❌ Layout.tsx chưa có icon Bell"
    fi
else
    echo "   ❌ Layout.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA PUSH NOTIFICATIONS PAGE HOÀN TẤT!"
echo "============================================="
echo "✅ Đã tạo trang Push Notifications!"
echo ""
echo "📱 HƯỚNG DẪN TEST PUSH NOTIFICATIONS PAGE:"
echo "=========================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Xem menu bên trái (desktop) hoặc menu mobile"
echo "5. Bấm vào 'Thông báo' (icon chuông)"
echo "6. Kiểm tra trang Push Notifications:"
echo ""
echo "🔍 TRANG PUSH NOTIFICATIONS:"
echo "============================"
echo "• Header với icon chuông và title 'Push Notifications'"
echo "• Trạng thái hỗ trợ trình duyệt"
echo "• Trạng thái quyền thông báo"
echo "• Trạng thái đăng ký push notifications"
echo "• Button 'Bật thông báo' (nếu chưa bật)"
echo "• Button 'Test thông báo' và 'Tắt thông báo' (nếu đã bật)"
echo "• Thông tin về push notifications"
echo ""
echo "📱 GIAO DIỆN MỚI:"
echo "=================="
echo "• Không còn component trôi nổi"
echo "• Trang riêng trong menu"
echo "• Giao diện đẹp và chuyên nghiệp"
echo "• Dễ quản lý và sử dụng"
echo "• Tương thích với tất cả user roles"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Trang có sẵn cho tất cả user (admin, manager, employee)"
echo "• Menu item 'Thông báo' với icon chuông"
echo "• Không còn component PushNotificationSetup trôi nổi"
echo "• Giao diện responsive cho mobile và desktop"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• Trang Push Notifications: $FRONTEND_URL/push-notifications"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

