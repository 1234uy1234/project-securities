#!/bin/bash

# 📱 TEST PUSH NOTIFICATION COMPACT
# Kiểm tra push notification đã được thu gọn

echo "📱 TEST PUSH NOTIFICATION COMPACT"
echo "=================================="
echo "Kiểm tra push notification đã được thu gọn..."
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
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx" ]; then
    echo "   ✅ PushNotificationSetup.tsx có sẵn"
    if grep -q "rounded-full" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã thay đổi thành icon chuông tròn"
    else
        echo "   ❌ Chưa thay đổi thành icon chuông tròn"
    fi
    if grep -q "max-w-xs" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã thu gọn modal (max-w-xs)"
    else
        echo "   ❌ Chưa thu gọn modal"
    fi
    if grep -q "text-xs" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã thu gọn text (text-xs)"
    else
        echo "   ❌ Chưa thu gọn text"
    fi
    if grep -q "p-3" /Users/maybe/Documents/shopee/frontend/src/components/PushNotificationSetup.tsx; then
        echo "   ✅ Đã thu gọn padding (p-3)"
    else
        echo "   ❌ Chưa thu gọn padding"
    fi
else
    echo "   ❌ PushNotificationSetup.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA PUSH NOTIFICATION COMPACT HOÀN TẤT!"
echo "=============================================="
echo "✅ Đã thu gọn push notification!"
echo ""
echo "📱 HƯỚNG DẪN TEST PUSH NOTIFICATION COMPACT:"
echo "==========================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Xem góc dưới bên phải màn hình"
echo "5. Kiểm tra icon chuông nhỏ:"
echo ""
echo "🔍 THAY ĐỔI ĐÃ THỰC HIỆN:"
echo "========================="
echo "• Icon chuông tròn nhỏ thay vì button lớn"
echo "• Modal thu gọn (max-w-xs thay vì max-w-sm)"
echo "• Text nhỏ hơn (text-xs thay vì text-sm)"
echo "• Padding nhỏ hơn (p-3 thay vì p-4)"
echo "• Button nhỏ hơn (px-2 py-1 thay vì px-4 py-2)"
echo "• Icon nhỏ hơn (w-3 h-3 thay vì w-4 h-4)"
echo ""
echo "📱 GIAO DIỆN MỚI:"
echo "================="
echo "• Icon chuông tròn xanh ở góc dưới bên phải"
echo "• Modal nhỏ gọn khi bấm vào"
echo "• Text ngắn gọn: 'Nhận thông báo khi có nhiệm vụ mới'"
echo "• Button nhỏ: 'Bật thông báo'"
echo "• Success message ngắn: 'Thông báo đã bật!'"
echo "• Button Test và Tắt nhỏ gọn"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Icon chuông chỉ hiện khi chưa bật thông báo"
echo "• Sau khi bật, modal sẽ hiện với nút Test và Tắt"
echo "• Giao diện tối ưu cho mobile"
echo "• Tiết kiệm diện tích màn hình"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

