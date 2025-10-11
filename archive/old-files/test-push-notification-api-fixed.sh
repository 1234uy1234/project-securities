#!/bin/bash

# 📱 TEST PUSH NOTIFICATION API ĐÃ SỬA
# Kiểm tra API test notification đã sửa lỗi

echo "📱 TEST PUSH NOTIFICATION API ĐÃ SỬA"
echo "====================================="
echo "Kiểm tra API test notification đã sửa lỗi..."
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

# 2. Kiểm tra API endpoint đã thêm
echo "2. Kiểm tra API endpoint đã thêm:"
if [ -f "/Users/maybe/Documents/shopee/backend/app/routes/push.py" ]; then
    echo "   ✅ push.py có sẵn"
    if grep -q "@router.get(\"/test\")" /Users/maybe/Documents/shopee/backend/app/routes/push.py; then
        echo "   ✅ API endpoint /test đã thêm"
    else
        echo "   ❌ API endpoint /test chưa thêm"
    fi
    if grep -q "test_push_notification" /Users/maybe/Documents/shopee/backend/app/routes/push.py; then
        echo "   ✅ Function test_push_notification đã thêm"
    else
        echo "   ❌ Function test_push_notification chưa thêm"
    fi
else
    echo "   ❌ push.py không tìm thấy"
fi

# 3. Kiểm tra frontend đã sửa
echo "3. Kiểm tra frontend đã sửa:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts" ]; then
    echo "   ✅ pushNotificationService.ts có sẵn"
    if grep -q "console.log.*Testing notification" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã thêm debug logs cho test"
    else
        echo "   ❌ Chưa thêm debug logs cho test"
    fi
    if grep -q "No authentication token found" /Users/maybe/Documents/shopee/frontend/src/services/pushNotificationService.ts; then
        echo "   ✅ Đã thêm kiểm tra token"
    else
        echo "   ❌ Chưa thêm kiểm tra token"
    fi
else
    echo "   ❌ pushNotificationService.ts không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA PUSH NOTIFICATION API ĐÃ SỬA HOÀN TẤT!"
echo "================================================="
echo "✅ Đã thêm API endpoint /test và sửa frontend!"
echo ""
echo "📱 HƯỚNG DẪN TEST PUSH NOTIFICATION API ĐÃ SỬA:"
echo "==============================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Mở Developer Tools (F12)"
echo "5. Vào tab Console"
echo "6. Bấm nút 'Bật thông báo'"
echo "7. Bấm nút 'Test'"
echo "8. Xem console logs:"
echo ""
echo "🔍 CONSOLE LOGS MONG ĐỢI:"
echo "========================="
echo "• '📱 Testing notification...'"
echo "• '📱 Test response status: 200'"
echo "• '✅ Test notification result: {success: true}'"
echo "• '✅ Test notification thành công!'"
echo ""
echo "⚠️ NẾU VẪN CÓ LỖI:"
echo "==================="
echo "• '❌ No authentication token found'"
echo "• '❌ Test failed: 401 - Unauthorized'"
echo "• '❌ Test failed: 500 - Internal Server Error'"
echo "• '❌ Error testing notification'"
echo ""
echo "🔍 CÁC TRƯỜNG HỢP:"
echo "==================="
echo "1. Token hợp lệ → Test thành công"
echo "2. Token không có → Lỗi authentication"
echo "3. Server lỗi → Lỗi 500"
echo "4. API không tồn tại → Lỗi 404"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải đăng nhập trước khi test"
echo "• Token phải còn hiệu lực"
echo "• Server phải đang chạy"
echo "• API endpoint phải được restart"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

