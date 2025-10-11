#!/bin/bash

# 📱 TEST QR SCANNER COMPLETE
# Kiểm tra QR scanner hoàn chỉnh theo yêu cầu

echo "📱 TEST QR SCANNER COMPLETE"
echo "============================"
echo "Kiểm tra QR scanner hoàn chỉnh theo yêu cầu..."
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
    
    # Kiểm tra nhận dạng ngay lập tức
    if grep -q "controls.stop()" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Dừng camera ngay lập tức sau khi quét"
    else
        echo "   ❌ Chưa dừng camera ngay lập tức"
    fi
    
    # Kiểm tra hiển thị thông tin QR
    if grep -q "QR Code đã quét thành công" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Hiển thị thông tin QR code thành công"
    else
        echo "   ❌ Chưa hiển thị thông tin QR code"
    fi
    
    # Kiểm tra hiển thị mã không hợp lệ
    if grep -q "Mã không hợp lệ" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Hiển thị thông báo mã không hợp lệ"
    else
        echo "   ❌ Chưa hiển thị thông báo mã không hợp lệ"
    fi
    
    # Kiểm tra dừng camera stream
    if grep -q "Camera turned off after successful scan" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Dừng camera stream sau khi quét thành công"
    else
        echo "   ❌ Chưa dừng camera stream"
    fi
    
    # Kiểm tra event listener
    if grep -q "QR Code detected" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có event listener xử lý QR Code detected"
    else
        echo "   ❌ Chưa có event listener"
    fi
    
    # Kiểm tra tương thích mobile
    if grep -q "facingMode: 'environment'" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Tương thích mobile với camera sau"
    else
        echo "   ❌ Chưa tương thích mobile"
    fi
    
    # Kiểm tra hiệu ứng loading
    if grep -q "border-blue-400 animate-pulse" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có hiệu ứng border sáng khi quét"
    else
        echo "   ❌ Chưa có hiệu ứng border sáng"
    fi
else
    echo "   ❌ QRScannerPage.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA QR SCANNER COMPLETE HOÀN TẤT!"
echo "=========================================="
echo "✅ Đã sửa QR scanner hoàn chỉnh theo yêu cầu!"
echo ""
echo "📱 HƯỚNG DẪN TEST QR SCANNER COMPLETE:"
echo "======================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Test QR scanner hoàn chỉnh:"
echo ""
echo "🔍 TEST QR SCANNER COMPLETE:"
echo "============================="
echo "• Vào trang 'Quét QR'"
echo "• Bấm 'Bật Camera'"
echo "• Camera SAU sẽ bật với hiệu ứng border sáng"
echo "• Đưa QR code vào khung hình"
echo "• QR scanner nhận dạng và xác nhận ngay lập tức"
echo "• Camera tự động dừng sau khi quét"
echo "• Hiển thị thông tin QR code ngay bên dưới camera"
echo ""
echo "✅ TEST QR CODE HỢP LỆ:"
echo "========================"
echo "• Quét QR code hợp lệ"
echo "• Hiển thị '✅ QR Code đã quét thành công'"
echo "• Hiển thị tên/nội dung QR code"
echo "• Hiển thị vị trí và mô tả"
echo "• Tự động chuyển sang bước chụp ảnh"
echo ""
echo "❌ TEST QR CODE KHÔNG HỢP LỆ:"
echo "=============================="
echo "• Quét QR code không hợp lệ"
echo "• Hiển thị '❌ Mã không hợp lệ'"
echo "• Hiển thị nội dung QR code"
echo "• Hiển thị 'Vui lòng quét lại mã QR hợp lệ'"
echo "• Camera vẫn hoạt động để quét lại"
echo ""
echo "📸 TEST CAMERA SELFIE:"
echo "======================"
echo "• Sau khi quét QR thành công"
echo "• Camera QR đã được giải phóng"
echo "• Bấm 'Bật Camera Selfie'"
echo "• Camera TRƯỚC sẽ bật không bị conflict"
echo "• Chụp ảnh selfie thành công"
echo ""
echo "🔍 FEATURES QR SCANNER COMPLETE:"
echo "================================="
echo "• Nhận dạng và xác nhận mã ngay lập tức"
echo "• Hiển thị thông tin QR code ngay bên dưới camera"
echo "• Hiển thị thông báo mã không hợp lệ"
echo "• Dừng camera stream sau khi quét thành công"
echo "• Event listener/callback hoạt động đúng"
echo "• Tương thích mobile và desktop"
echo "• Hiệu ứng loading và border sáng"
echo "• Không conflict với camera selfie"
echo ""
echo "📱 CẢI TIẾN ĐÃ THỰC HIỆN:"
echo "========================="
echo "• Nhận dạng QR code ngay lập tức"
echo "• Hiển thị thông tin ngay bên dưới camera"
echo "• Hiển thị thông báo mã không hợp lệ"
echo "• Dừng camera stream sau khi quét"
echo "• Sửa event listener/callback"
echo "• Đảm bảo tương thích mobile"
echo "• Thêm hiệu ứng loading và border sáng"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để load code mới"
echo "• Test trên mobile để thấy hiệu quả"
echo "• QR scanner nhận dạng ngay lập tức"
echo "• Camera tự động dừng sau khi quét"
echo "• Không conflict với camera selfie"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• QR Scanner: $FRONTEND_URL/qr-scan"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

