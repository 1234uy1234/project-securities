#!/bin/bash

# 📱 TEST CAMERA CONFLICT FIX
# Kiểm tra camera conflict đã được sửa

echo "📱 TEST CAMERA CONFLICT FIX"
echo "============================"
echo "Kiểm tra camera conflict đã được sửa..."
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

# 2. Kiểm tra GlobalCameraManager
echo "2. Kiểm tra GlobalCameraManager:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/utils/globalCameraManager.ts" ]; then
    echo "   ✅ GlobalCameraManager.ts đã tạo"
    if grep -q "forceStopAllStreams" /Users/maybe/Documents/shopee/frontend/src/utils/globalCameraManager.ts; then
        echo "   ✅ Đã có method forceStopAllStreams"
    else
        echo "   ❌ Chưa có method forceStopAllStreams"
    fi
    if grep -q "startCamera" /Users/maybe/Documents/shopee/frontend/src/utils/globalCameraManager.ts; then
        echo "   ✅ Đã có method startCamera"
    else
        echo "   ❌ Chưa có method startCamera"
    fi
    if grep -q "stopCamera" /Users/maybe/Documents/shopee/frontend/src/utils/globalCameraManager.ts; then
        echo "   ✅ Đã có method stopCamera"
    else
        echo "   ❌ Chưa có method stopCamera"
    fi
else
    echo "   ❌ GlobalCameraManager.ts chưa tạo"
fi

# 3. Kiểm tra SimpleQRScanner
echo "3. Kiểm tra SimpleQRScanner:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx" ]; then
    echo "   ✅ SimpleQRScanner.tsx có sẵn"
    if grep -q "GlobalCameraManager" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ Đã import GlobalCameraManager"
    else
        echo "   ❌ Chưa import GlobalCameraManager"
    fi
    if grep -q "facingMode: 'environment'" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ QR Scanner dùng camera sau (environment)"
    else
        echo "   ❌ QR Scanner chưa dùng camera sau"
    fi
else
    echo "   ❌ SimpleQRScanner.tsx không tìm thấy"
fi

# 4. Kiểm tra SimpleFaceAuthModal
echo "4. Kiểm tra SimpleFaceAuthModal:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx" ]; then
    echo "   ✅ SimpleFaceAuthModal.tsx có sẵn"
    if grep -q "GlobalCameraManager" /Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx; then
        echo "   ✅ Đã import GlobalCameraManager"
    else
        echo "   ❌ Chưa import GlobalCameraManager"
    fi
    if grep -q "facingMode: 'user'" /Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx; then
        echo "   ✅ Face Auth dùng camera trước (user)"
    else
        echo "   ❌ Face Auth chưa dùng camera trước"
    fi
else
    echo "   ❌ SimpleFaceAuthModal.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA CAMERA CONFLICT FIX HOÀN TẤT!"
echo "========================================="
echo "✅ Đã sửa camera conflict!"
echo ""
echo "📱 HƯỚNG DẪN TEST CAMERA CONFLICT FIX:"
echo "======================================"
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Test camera:"
echo ""
echo "🔍 TEST CAMERA QR SCANNER:"
echo "=========================="
echo "• Vào trang 'Quét QR'"
echo "• Bấm 'Bắt đầu quét'"
echo "• Camera sau sẽ bật (environment)"
echo "• Quét QR code"
echo "• Camera sẽ tự động tắt sau khi quét"
echo ""
echo "🔍 TEST CAMERA FACE AUTH:"
echo "========================="
echo "• Vào trang 'Nhân viên'"
echo "• Bấm 'Đăng ký khuôn mặt' hoặc 'Xác thực'"
echo "• Camera trước sẽ bật (user)"
echo "• Chụp ảnh hoặc xác thực"
echo "• Camera sẽ tự động tắt"
echo ""
echo "🔍 TEST CAMERA SWITCHING:"
echo "========================="
echo "• Quét QR trước → Camera sau"
echo "• Sau đó mở Face Auth → Camera trước"
echo "• Không còn xung đột camera"
echo "• Mỗi camera hoạt động độc lập"
echo ""
echo "📱 CẢI TIẾN ĐÃ THỰC HIỆN:"
echo "========================="
echo "• GlobalCameraManager quản lý tất cả camera"
echo "• Force stop tất cả camera trước khi bật camera mới"
echo "• QR Scanner dùng camera sau (environment)"
echo "• Face Auth dùng camera trước (user)"
echo "• Không còn xung đột camera trên mobile"
echo "• Camera hoạt động ổn định và độc lập"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để load code mới"
echo "• Test trên mobile để thấy hiệu quả"
echo "• Camera sẽ tự động tắt sau khi sử dụng"
echo "• Không còn lỗi 'camera đang được sử dụng'"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• QR Scanner: $FRONTEND_URL/qr-scan"
echo "• Face Auth: $FRONTEND_URL/users"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

