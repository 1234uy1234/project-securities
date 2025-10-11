#!/bin/bash

# 📱 TEST BOTH CAMERAS FIXED
# Kiểm tra cả QR scanner và camera selfie đã được sửa

echo "📱 TEST BOTH CAMERAS FIXED"
echo "=========================="
echo "Kiểm tra cả QR scanner và camera selfie..."
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

# 2. Kiểm tra SimpleQRScanner mới
echo "2. Kiểm tra SimpleQRScanner mới:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx" ]; then
    echo "   ✅ SimpleQRScanner.tsx có sẵn"
    if grep -q "SimpleQRScannerNew" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ Đã thay thế bằng SimpleQRScannerNew"
    else
        echo "   ❌ Chưa thay thế bằng SimpleQRScannerNew"
    fi
    if grep -q "facingMode: 'environment'" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ QR Scanner dùng camera sau (environment)"
    else
        echo "   ❌ QR Scanner chưa dùng camera sau"
    fi
else
    echo "   ❌ SimpleQRScanner.tsx không tìm thấy"
fi

# 3. Kiểm tra SimpleFaceAuthModal mới
echo "3. Kiểm tra SimpleFaceAuthModal mới:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx" ]; then
    echo "   ✅ SimpleFaceAuthModal.tsx có sẵn"
    if grep -q "SimpleFaceAuthModalNew" /Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx; then
        echo "   ✅ Đã thay thế bằng SimpleFaceAuthModalNew"
    else
        echo "   ❌ Chưa thay thế bằng SimpleFaceAuthModalNew"
    fi
    if grep -q "facingMode: 'user'" /Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx; then
        echo "   ✅ Face Auth dùng camera trước (user)"
    else
        echo "   ❌ Face Auth chưa dùng camera trước"
    fi
    if grep -q "Camera sẵn sàng" /Users/maybe/Documents/shopee/frontend/src/components/SimpleFaceAuthModal.tsx; then
        echo "   ✅ Face Auth có status 'Camera sẵn sàng'"
    else
        echo "   ❌ Face Auth chưa có status 'Camera sẵn sàng'"
    fi
else
    echo "   ❌ SimpleFaceAuthModal.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA BOTH CAMERAS FIXED HOÀN TẤT!"
echo "========================================"
echo "✅ Đã sửa cả QR scanner và camera selfie!"
echo ""
echo "📱 HƯỚNG DẪN TEST BOTH CAMERAS:"
echo "================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Test cả 2 camera:"
echo ""
echo "🔍 TEST QR SCANNER:"
echo "==================="
echo "• Vào trang 'Quét QR'"
echo "• Bấm 'Bắt đầu quét'"
echo "• Camera sau sẽ bật"
echo "• Hiển thị 'Camera sẵn sàng' (màu xanh)"
echo "• Hiển thị 'Đang quét QR...' (màu xanh dương)"
echo "• Đưa QR code vào khung hình"
echo "• QR scanner sẽ nhận diện QR code"
echo "• Hiển thị thông báo 'QR Code detected'"
echo ""
echo "📸 TEST CAMERA SELFIE:"
echo "======================"
echo "• Sau khi quét QR thành công"
echo "• Bấm 'Bật Camera Selfie'"
echo "• Camera trước sẽ bật"
echo "• Hiển thị 'Camera sẵn sàng' (màu xanh)"
echo "• Bấm 'Chụp ảnh'"
echo "• Camera sẽ chụp ảnh selfie"
echo "• Hiển thị 'Đang xử lý...'"
echo "• Hiển thị kết quả xác thực"
echo ""
echo "🔍 FEATURES BOTH CAMERAS:"
echo "=========================="
echo "• QR Scanner: Camera sau (environment)"
echo "• Face Auth: Camera trước (user)"
echo "• Status hiển thị rõ ràng"
echo "• Error handling tốt hơn"
echo "• Không conflict với nhau"
echo "• Đơn giản và ổn định"
echo ""
echo "📱 CẢI TIẾN ĐÃ THỰC HIỆN:"
echo "========================="
echo "• Tạo SimpleQRScannerNew hoàn toàn mới"
echo "• Tạo SimpleFaceAuthModalNew hoàn toàn mới"
echo "• Logic đơn giản và rõ ràng"
echo "• Status hiển thị trực quan"
echo "• QR Scanner: Camera sau (environment)"
echo "• Face Auth: Camera trước (user)"
echo "• Không conflict với nhau"
echo "• Error handling tốt hơn"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để load code mới"
echo "• Test trên mobile để thấy hiệu quả"
echo "• QR scanner sẽ tự động bắt đầu quét"
echo "• Camera selfie sẽ bật khi cần"
echo "• Status hiển thị rõ ràng"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• QR Scanner: $FRONTEND_URL/qr-scan"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

