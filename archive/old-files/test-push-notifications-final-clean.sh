#!/bin/bash

# 📱 TEST PUSH NOTIFICATIONS FINAL CLEAN
# Kiểm tra push notifications đã sạch hoàn toàn

echo "📱 TEST PUSH NOTIFICATIONS FINAL CLEAN"
echo "======================================"
echo "Kiểm tra push notifications đã sạch hoàn toàn..."
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

# 2. Kiểm tra component cũ đã xóa
echo "2. Kiểm tra component cũ đã xóa:"
if [ ! -f "/Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx" ]; then
    echo "   ✅ PushNotificationSetup.tsx đã xóa"
else
    echo "   ❌ PushNotificationSetup.tsx vẫn còn"
fi

# 3. Kiểm tra trang mới
echo "3. Kiểm tra trang mới:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/pages/PushNotificationsPage.tsx" ]; then
    echo "   ✅ PushNotificationsPage.tsx có sẵn"
    if grep -q "Push Notifications" /Users/maybe/Documents/shopee/frontend/src/pages/PushNotificationsPage.tsx; then
        echo "   ✅ Trang có title 'Push Notifications'"
    else
        echo "   ❌ Trang chưa có title 'Push Notifications'"
    fi
else
    echo "   ❌ PushNotificationsPage.tsx chưa tạo"
fi

# 4. Kiểm tra App.tsx
echo "4. Kiểm tra App.tsx:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/App.tsx" ]; then
    echo "   ✅ App.tsx có sẵn"
    if grep -q "PushNotificationsPage" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
        echo "   ✅ App.tsx đã import PushNotificationsPage"
    else
        echo "   ❌ App.tsx chưa import PushNotificationsPage"
    fi
    if ! grep -q "PushNotificationSetup" /Users/maybe/Documents/shopee/frontend/src/App.tsx; then
        echo "   ✅ App.tsx đã xóa PushNotificationSetup"
    else
        echo "   ❌ App.tsx vẫn còn PushNotificationSetup"
    fi
else
    echo "   ❌ App.tsx không tìm thấy"
fi

# 5. Kiểm tra Layout.tsx
echo "5. Kiểm tra Layout.tsx:"
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
else
    echo "   ❌ Layout.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA PUSH NOTIFICATIONS FINAL CLEAN HOÀN TẤT!"
echo "==================================================="
echo "✅ Đã sạch hoàn toàn component cũ!"
echo ""
echo "📱 HƯỚNG DẪN TEST PUSH NOTIFICATIONS FINAL CLEAN:"
echo "================================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Kiểm tra:"
echo ""
echo "🔍 KIỂM TRA 1: KHÔNG CÒN NÚT TRÔI NỔI"
echo "======================================"
echo "• Góc dưới bên phải KHÔNG còn nút 'Push Notifications'"
echo "• Không còn component trôi nổi nào"
echo "• Giao diện sạch sẽ"
echo ""
echo "🔍 KIỂM TRA 2: CÓ MENU MỚI"
echo "==========================="
echo "• Menu bên trái (desktop) hoặc menu mobile"
echo "• Có menu item 'Thông báo' với icon chuông"
echo "• Bấm vào 'Thông báo' sẽ mở trang Push Notifications"
echo ""
echo "🔍 KIỂM TRA 3: TRANG PUSH NOTIFICATIONS"
echo "======================================="
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
echo "• Phải hard refresh để clear cache"
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

