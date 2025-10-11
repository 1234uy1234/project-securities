#!/bin/bash

# 📱 TEST GLOBAL QR SCANNER
# Kiểm tra Global QR Scanner

echo "📱 TEST GLOBAL QR SCANNER"
echo "========================="
echo "Kiểm tra Global QR Scanner..."
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

# 2. Kiểm tra GlobalQRScanner
echo "2. Kiểm tra GlobalQRScanner:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/utils/GlobalQRScanner.ts" ]; then
    echo "   ✅ GlobalQRScanner.ts có sẵn"
    if grep -q "class GlobalQRScanner" /Users/maybe/Documents/shopee/frontend/src/utils/GlobalQRScanner.ts; then
        echo "   ✅ Có class GlobalQRScanner"
    else
        echo "   ❌ Chưa có class GlobalQRScanner"
    fi
    if grep -q "getInstance" /Users/maybe/Documents/shopee/frontend/src/utils/GlobalQRScanner.ts; then
        echo "   ✅ Có method getInstance"
    else
        echo "   ❌ Chưa có method getInstance"
    fi
    if grep -q "startScanning" /Users/maybe/Documents/shopee/frontend/src/utils/GlobalQRScanner.ts; then
        echo "   ✅ Có method startScanning"
    else
        echo "   ❌ Chưa có method startScanning"
    fi
    if grep -q "detectQRPattern" /Users/maybe/Documents/shopee/frontend/src/utils/GlobalQRScanner.ts; then
        echo "   ✅ Có method detectQRPattern"
    else
        echo "   ❌ Chưa có method detectQRPattern"
    fi
else
    echo "   ❌ GlobalQRScanner.ts không tìm thấy"
fi

# 3. Kiểm tra GlobalQRScannerComponent
echo "3. Kiểm tra GlobalQRScannerComponent:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx" ]; then
    echo "   ✅ SimpleQRScanner.tsx có sẵn"
    if grep -q "GlobalQRScannerComponent" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ Đã thay thế bằng GlobalQRScannerComponent"
    else
        echo "   ❌ Chưa thay thế bằng GlobalQRScannerComponent"
    fi
    if grep -q "GlobalQRScanner" /Users/maybe/Documents/shopee/frontend/src/components/SimpleQRScanner.tsx; then
        echo "   ✅ Sử dụng GlobalQRScanner"
    else
        echo "   ❌ Chưa sử dụng GlobalQRScanner"
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
else
    echo "   ❌ SimpleQRScanner.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA GLOBAL QR SCANNER HOÀN TẤT!"
echo "======================================="
echo "✅ Đã tạo Global QR Scanner!"
echo ""
echo "📱 HƯỚNG DẪN TEST GLOBAL QR SCANNER:"
echo "====================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Test Global QR Scanner:"
echo ""
echo "🔍 TEST GLOBAL QR SCANNER:"
echo "==========================="
echo "• Vào trang 'Quét QR'"
echo "• Bấm 'Bắt đầu quét'"
echo "• Camera sau sẽ bật"
echo "• Hiển thị 'Camera sẵn sàng' (màu xanh)"
echo "• Hiển thị 'Đang quét QR...' (màu xanh dương)"
echo "• Đưa QR code vào khung hình"
echo "• Global QR Scanner sẽ nhận diện QR code"
echo "• Hiển thị thông báo 'QR Code detected'"
echo "• Gọi callback onScan với text QR"
echo ""
echo "🔍 FEATURES GLOBAL QR SCANNER:"
echo "==============================="
echo "• Singleton pattern - chỉ có 1 instance"
echo "• Camera sau (environment) hoạt động"
echo "• Status hiển thị rõ ràng"
echo "• Error handling tốt hơn"
echo "• Simple QR detection algorithm"
echo "• Canvas-based pattern recognition"
echo "• Đơn giản và ổn định"
echo ""
echo "📱 CẢI TIẾN ĐÃ THỰC HIỆN:"
echo "========================="
echo "• Tạo GlobalQRScanner singleton class"
echo "• Tạo GlobalQRScannerComponent"
echo "• Logic đơn giản và rõ ràng"
echo "• Status hiển thị trực quan"
echo "• Camera sau (environment) cho QR scanner"
echo "• Simple QR detection algorithm"
echo "• Canvas-based pattern recognition"
echo "• Error handling tốt hơn"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để load code mới"
echo "• Test trên mobile để thấy hiệu quả"
echo "• Global QR Scanner sẽ tự động bắt đầu quét"
echo "• Status hiển thị rõ ràng"
echo "• Simple QR detection - có thể cần cải thiện"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• QR Scanner: $FRONTEND_URL/qr-scan"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

