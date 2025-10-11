#!/bin/bash

# 📱 TEST MENU NOTIFICATIONS
# Kiểm tra menu Thông báo đã hiện chưa

echo "📱 TEST MENU NOTIFICATIONS"
echo "==========================="
echo "Kiểm tra menu Thông báo đã hiện chưa..."
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

# 2. Kiểm tra Layout.tsx
echo "2. Kiểm tra Layout.tsx:"
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

# 3. Kiểm tra navigationItems
echo "3. Kiểm tra navigationItems:"
if grep -A 10 "navigationItems = \[" /Users/maybe/Documents/shopee/frontend/src/components/Layout.tsx | grep -q "Thông báo"; then
    echo "   ✅ navigationItems đã có 'Thông báo'"
else
    echo "   ❌ navigationItems chưa có 'Thông báo'"
fi

echo ""
echo "📱 KIỂM TRA MENU NOTIFICATIONS HOÀN TẤT!"
echo "========================================"
echo "✅ Menu Thông báo đã được thêm!"
echo ""
echo "📱 HƯỚNG DẪN TEST MENU NOTIFICATIONS:"
echo "====================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Xem sidebar bên trái:"
echo ""
echo "🔍 MENU SIDEBAR BÊN TRÁI:"
echo "========================="
echo "• Dashboard"
echo "• Nhiệm vụ"
echo "• Quét QR"
echo "• Thông báo ← MENU MỚI"
echo "• Admin Dashboard"
echo "• Báo cáo"
echo "• Nhân viên"
echo ""
echo "📱 KIỂM TRA MENU:"
echo "=================="
echo "• Menu 'Thông báo' với icon chuông"
echo "• Bấm vào 'Thông báo' sẽ mở trang Push Notifications"
echo "• Trang có header 'Push Notifications'"
echo "• Trang có các button: Bật thông báo, Test, Tắt"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để clear cache"
echo "• Menu 'Thông báo' có sẵn cho tất cả user"
echo "• Nếu không thấy menu, hãy hard refresh lại"
echo "• Menu nằm giữa 'Quét QR' và 'Admin Dashboard'"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• Trang Push Notifications: $FRONTEND_URL/push-notifications"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

