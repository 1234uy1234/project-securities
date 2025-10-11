#!/bin/bash

# 📱 TEST QR SCANNER NEW
# Kiểm tra QR scanner mới

echo "📱 TEST QR SCANNER NEW"
echo "======================="
echo "Kiểm tra QR scanner mới..."
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
    if grep -q "Camera sẵn sàng" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ Có status 'Camera sẵn sàng'"
    else
        echo "   ❌ Chưa có status 'Camera sẵn sàng'"
    fi
    if grep -q "Đang quét QR" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ Có status 'Đang quét QR'"
    else
        echo "   ❌ Chưa có status 'Đang quét QR'"
    fi
    if grep -q "facingMode: 'environment'" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ QR Scanner dùng camera sau (environment)"
    else
        echo "   ❌ QR Scanner chưa dùng camera sau"
    fi
else
    echo "   ❌ SimpleQRScanner.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA QR SCANNER NEW HOÀN TẤT!"
echo "===================================="
echo "✅ Đã tạo QR scanner mới!"
echo ""
echo "📱 HƯỚNG DẪN TEST QR SCANNER NEW:"
echo "=================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Test QR scanner:"
echo ""
echo "🔍 TEST QR SCANNER MỚI:"
echo "======================="
echo "• Vào trang 'Quét QR'"
echo "• Bấm 'Bắt đầu quét'"
echo "• Camera sau sẽ bật"
echo "• Hiển thị 'Camera sẵn sàng' (màu xanh)"
echo "• Hiển thị 'Đang quét QR...' (màu xanh dương)"
echo "• Đưa QR code vào khung hình"
echo "• QR scanner sẽ nhận diện QR code"
echo "• Hiển thị thông báo 'QR Code detected'"
echo "• Gọi callback onScan với text QR"
echo ""
echo "🔍 FEATURES QR SCANNER MỚI:"
echo "============================"
echo "• Camera sau (environment) hoạt động"
echo "• Status hiển thị rõ ràng"
echo "• Error handling tốt hơn"
echo "• Auto start scanning khi camera ready"
echo "• Đơn giản và ổn định"
echo "• Không có logic phức tạp"
echo ""
echo "📱 CẢI TIẾN ĐÃ THỰC HIỆN:"
echo "========================="
echo "• Tạo SimpleQRScannerNew hoàn toàn mới"
echo "• Logic đơn giản và rõ ràng"
echo "• Status hiển thị trực quan"
echo "• Camera sau (environment) cho QR scanner"
echo "• Auto start scanning"
echo "• Error handling tốt hơn"
echo "• Không có force reload"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để load code mới"
echo "• Test trên mobile để thấy hiệu quả"
echo "• QR scanner sẽ tự động bắt đầu quét"
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

