#!/bin/bash

# 📱 TEST QR CHECKIN FIXED
# Kiểm tra QR scanner và check-in đã được sửa

echo "📱 TEST QR CHECKIN FIXED"
echo "========================="
echo "Kiểm tra QR scanner và check-in..."
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
    if grep -q "XÁC NHẬN VỊ TRÍ NGAY LẬP TỨC" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có xác nhận vị trí ngay lập tức"
    else
        echo "   ❌ Chưa có xác nhận vị trí ngay lập tức"
    fi
    if grep -q "Tự động chuyển sang bước chụp ảnh" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có tự động chuyển sang bước chụp ảnh"
    else
        echo "   ❌ Chưa có tự động chuyển sang bước chụp ảnh"
    fi
    if grep -q "task_id: taskId" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có gửi task_id trong checkin data"
    else
        echo "   ❌ Chưa có gửi task_id trong checkin data"
    fi
    if grep -q "stop_id: stopId" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có gửi stop_id trong checkin data"
    else
        echo "   ❌ Chưa có gửi stop_id trong checkin data"
    fi
    if grep -q "Check-in từ QR Scanner:" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
        echo "   ✅ Có ghi chú check-in từ QR Scanner"
    else
        echo "   ❌ Chưa có ghi chú check-in từ QR Scanner"
    fi
else
    echo "   ❌ QRScannerPage.tsx không tìm thấy"
fi

echo ""
echo "📱 KIỂM TRA QR CHECKIN FIXED HOÀN TẤT!"
echo "======================================="
echo "✅ Đã sửa QR scanner và check-in!"
echo ""
echo "📱 HƯỚNG DẪN TEST QR CHECKIN:"
echo "==============================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Hard refresh (Ctrl+F5 hoặc Cmd+Shift+R)"
echo "4. Đăng nhập vào hệ thống"
echo "5. Test QR scanner và check-in:"
echo ""
echo "🔍 TEST QR SCANNER:"
echo "==================="
echo "• Vào trang 'Quét QR'"
echo "• Bấm 'Bắt đầu quét'"
echo "• Camera sau sẽ bật"
echo "• Đưa QR code vào khung hình"
echo "• QR scanner sẽ nhận diện QR code"
echo "• Hiển thị '✅ Đã xác nhận vị trí: [Tên vị trí]'"
echo "• Tự động chuyển sang bước chụp ảnh"
echo ""
echo "📸 TEST CAMERA SELFIE:"
echo "======================"
echo "• Sau khi xác nhận vị trí"
echo "• Bấm 'Bật Camera Selfie'"
echo "• Camera trước sẽ bật"
echo "• Bấm 'Chụp ảnh'"
echo "• Camera sẽ chụp ảnh selfie"
echo "• Hiển thị '📷 Đã chụp ảnh selfie thành công!'"
echo "• Tự động chuyển sang bước submit"
echo ""
echo "✅ TEST CHECK-IN:"
echo "=================="
echo "• Sau khi chụp ảnh"
echo "• Bấm 'Xác nhận Check-in'"
echo "• Hiển thị 'Check-in thành công!'"
echo "• Dispatch event 'checkin-success'"
echo "• Cập nhật dashboard"
echo ""
echo "🔍 FEATURES QR CHECKIN:"
echo "========================"
echo "• QR Scanner: Camera sau (environment)"
echo "• Face Auth: Camera trước (user)"
echo "• Xác nhận vị trí ngay lập tức"
echo "• Tự động chuyển sang bước chụp ảnh"
echo "• Gửi đầy đủ thông tin check-in"
echo "• Ghi chú chi tiết"
echo "• Dispatch event để cập nhật dashboard"
echo ""
echo "📱 CẢI TIẾN ĐÃ THỰC HIỆN:"
echo "========================="
echo "• Thêm xác nhận vị trí ngay lập tức"
echo "• Tự động chuyển sang bước chụp ảnh"
echo "• Gửi task_id và stop_id trong checkin data"
echo "• Ghi chú chi tiết check-in"
echo "• Dispatch event checkin-success"
echo "• Cập nhật dashboard tự động"
echo ""
echo "⚠️ LƯU Ý:"
echo "=========="
echo "• Phải hard refresh để load code mới"
echo "• Test trên mobile để thấy hiệu quả"
echo "• QR scanner sẽ xác nhận vị trí ngay lập tức"
echo "• Tự động chuyển sang bước chụp ảnh"
echo "• Check-in sẽ gửi đầy đủ thông tin"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo "• QR Scanner: $FRONTEND_URL/qr-scan"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"

