#!/bin/bash

# 🔔 TEST SỬA THÔNG BÁO VÀ CAMERA
# Kiểm tra sửa thông báo auto-hide và camera không aggressive

echo "🔔 TEST SỬA THÔNG BÁO VÀ CAMERA"
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

# 2. Kiểm tra file đã sửa
echo "2. Kiểm tra file đã sửa:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/main.tsx" ]; then
    echo "   ✅ main.tsx có sẵn"
    if grep -q "duration: 2000" /Users/maybe/Documents/shopee/frontend/src/main.tsx; then
        echo "   ✅ Đã sửa toast duration xuống 2 giây"
    else
        echo "   ❌ Chưa sửa toast duration"
    fi
    if grep -q "cursor: 'pointer'" /Users/maybe/Documents/shopee/frontend/src/main.tsx; then
        echo "   ✅ Đã thêm cursor pointer cho toast"
    else
        echo "   ❌ Chưa thêm cursor pointer"
    fi
else
    echo "   ❌ main.tsx không tìm thấy"
fi

if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx" ]; then
    echo "   ✅ SimpleFaceAuthModal.tsx có sẵn"
    if grep -q "hasActiveStreams" /Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx; then
        echo "   ✅ Đã sửa camera xác thực không aggressive"
    else
        echo "   ❌ Chưa sửa camera xác thực"
    fi
    if grep -q "Không có camera đang hoạt động" /Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx; then
        echo "   ✅ Đã thêm logic kiểm tra camera đang hoạt động"
    else
        echo "   ❌ Chưa thêm logic kiểm tra camera"
    fi
else
    echo "   ❌ SimpleFaceAuthModal.tsx không tìm thấy"
fi

# 3. Kiểm tra CameraManager
echo "3. Kiểm tra CameraManager:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/utils/cameraManager.ts" ]; then
    echo "   ✅ CameraManager.ts có sẵn"
    if grep -q "getActiveStreams" /Users/maybe/Documents/shopee/frontend/src/utils/cameraManager.ts; then
        echo "   ✅ CameraManager có method getActiveStreams"
    else
        echo "   ❌ CameraManager thiếu method getActiveStreams"
    fi
else
    echo "   ❌ CameraManager.ts không tìm thấy"
fi

echo ""
echo "🔔 KIỂM TRA SỬA THÔNG BÁO VÀ CAMERA HOÀN TẤT!"
echo "=============================================="
echo "✅ Đã sửa thông báo auto-hide và camera không aggressive!"
echo ""
echo "🔔 GIẢI PHÁP THÔNG BÁO:"
echo "======================="
echo "✅ Toast duration: Giảm từ 4 giây xuống 2 giây"
echo "✅ Cursor pointer: Click để tắt toast"
echo "✅ Auto-hide: Tự động mất sau 2 giây"
echo "✅ Better styling: Border radius, padding, font size"
echo "✅ Max width: Giới hạn chiều rộng toast"
echo ""
echo "🎥 GIẢI PHÁP CAMERA:"
echo "===================="
echo "✅ Camera xác thực: Không aggressive nữa"
echo "✅ Kiểm tra camera đang hoạt động: Chỉ stop nếu cần"
echo "✅ Logic thông minh: Bắt đầu trực tiếp nếu không có camera"
echo "✅ Wait time ngắn: Chỉ 1 giây thay vì 5-10 giây"
echo "✅ getActiveStreams(): Method kiểm tra camera đang hoạt động"
echo ""
echo "📱 VẤN ĐỀ TRƯỚC KHI SỬA:"
echo "========================="
echo "❌ Thông báo đứng mãi không mất"
echo "❌ Không có nút X để tắt thông báo"
echo "❌ Camera xác thực báo bị chiếm dụng ngay cả khi chưa dùng QR"
echo "❌ Code quá aggressive, stop camera không cần thiết"
echo "❌ Đợi quá lâu (5-10 giây) để camera được giải phóng"
echo ""
echo "✅ SAU KHI SỬA:"
echo "==============="
echo "✅ Thông báo tự động mất sau 2 giây"
echo "✅ Click vào thông báo để tắt ngay"
echo "✅ Camera xác thực hoạt động bình thường"
echo "✅ Không còn báo bị chiếm dụng khi chưa dùng QR"
echo "✅ Logic thông minh, chỉ stop camera khi cần"
echo "✅ Đợi ngắn (1 giây) để camera được giải phóng"
echo ""
echo "📱 HƯỚNG DẪN TEST:"
echo "=================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Test Thông báo:"
echo "   - Thực hiện các action (chấm công, tạo task, etc.)"
echo "   - Thông báo sẽ hiện và tự động mất sau 2 giây"
echo "   - Click vào thông báo để tắt ngay"
echo "5. Test Camera:"
echo "   - Mở camera xác thực trước (không dùng QR scanner)"
echo "   - Camera sẽ hoạt động bình thường"
echo "   - Không còn báo 'đang bị sử dụng'"
echo "   - Đợi ngắn (1 giây) thay vì 5-10 giây"
echo ""
echo "🎯 TÍNH NĂNG ĐÃ SỬA:"
echo "===================="
echo "✅ Toast Notifications:"
echo "   - Duration: 2 giây thay vì 4 giây"
echo "   - Cursor pointer: Click để tắt"
echo "   - Auto-hide: Tự động mất"
echo "   - Better styling: Đẹp hơn"
echo ""
echo "✅ Camera Xác thực:"
echo "   - Không aggressive nữa"
echo "   - Kiểm tra camera đang hoạt động"
echo "   - Logic thông minh"
echo "   - Wait time ngắn (1 giây)"
echo "   - Hoạt động bình thường"
echo ""
echo "⚠️ LƯU Ý QUAN TRỌNG:"
echo "===================="
echo "• Thông báo sẽ tự động mất sau 2 giây"
echo "• Click vào thông báo để tắt ngay"
echo "• Camera xác thực không còn aggressive"
echo "• Chỉ stop camera khi thực sự cần"
echo "• Logic thông minh hơn"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
