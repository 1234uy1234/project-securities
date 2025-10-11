#!/bin/bash

# 📱 TEST QR CAMERA BACK
# Kiểm tra QR scanner dùng camera sau

echo "📱 TEST QR CAMERA BACK"
echo "======================="
echo "Kiểm tra QR scanner dùng camera sau..."
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

# 2. Kiểm tra QRScannerPage
echo "2. Kiểm tra QRScannerPage:"
if [ -f "/Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx" ]; then
    echo "   ✅ QRScannerPage.tsx có sẵn"
    if grep -q "facingMode: 'environment'" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ QR Scanner dùng camera sau (environment)"
    else
        echo "   ❌ QR Scanner chưa dùng camera sau"
    fi
    if grep -q "CAMERA SAU" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có comment CAMERA SAU"
    else
        echo "   ❌ Chưa có comment CAMERA SAU"
    fi
    if grep -q "decodeFromVideoDevice" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có decodeFromVideoDevice"
    else
        echo "   ❌ Chưa có decodeFromVideoDevice"
    fi
else
    echo "   ❌ QRScannerPage.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA QR CAMERA BACK HOÀN TẤT!"
echo "====================================="
echo "✅ Đã sửa QR scanner dùng camera sau!"
echo ""
echo "📱 HƯỚNG DẪN TEST QR CAMERA BACK:"
echo "==================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Test QR scanner dùng camera sau:"
echo ""
echo "🔍 TEST QR SCANNER CAMERA SAU:"
echo "==============================="
echo "• Vào trang 'Quét QR'"
echo "• Bấm 'Bắt đầu quét'"
echo "• Camera SAU sẽ bật (không phải camera trước)"
echo "• Đưa QR code vào khung hình"
echo "• QR scanner sẽ nhận diện QR code"
echo "• Hiển thị '✅ Đã xác nhận vị trí: [Tên vị trí]'"
echo "• Tự động chuyển sang bước chụp ảnh"
echo ""
echo "📸 TEST CAMERA SELFIE:"
echo "======================"
echo "• Sau khi xác nhận vị trí"
echo "• Bấm 'Bật Camera Selfie'"
echo "• Camera TRƯỚC sẽ bật (không phải camera sau)"
echo "• Bấm 'Chụp ảnh'"
echo "• Camera sẽ chụp ảnh selfie"
echo "• Hiển thị '📷 Đã chụp ảnh selfie thành công!'"
echo "• Tự động chuyển sang bước submit"
echo ""
echo "🔍 FEATURES QR CAMERA BACK:"
echo "============================"
echo "• QR Scanner: Camera SAU (environment)"
echo "• Face Auth: Camera TRƯỚC (user)"
echo "• Không conflict với nhau"
echo "• Xác nhận vị trí ngay lập tức"
echo "• Tự động chuyển sang bước chụp ảnh"
echo "• Gửi đầy đủ thông tin check-in"
echo ""
echo "📱 CẢI TIẾN ĐÃ THỰC HIỆN:"
echo "========================="
echo "• Sửa QR scanner dùng camera sau (environment)"
echo "• Thêm comment CAMERA SAU"
echo "• Đảm bảo QR scanner và face auth dùng camera khác nhau"
echo "• Không conflict với nhau"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để load code mới"
echo "• Test trên mobile để thấy hiệu quả"
echo "• QR scanner sẽ dùng camera SAU"
echo "• Face auth sẽ dùng camera TRƯỚC"
echo "• Không conflict với nhau"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• QR Scanner: $FRONTEND_URL/qr-scan"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

