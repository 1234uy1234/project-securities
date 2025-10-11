#!/bin/bash

# 📱 TEST PUSH NOTIFICATION ĐƠN GIẢN
# Test push notification từ backend

echo "📱 TEST PUSH NOTIFICATION ĐƠN GIẢN"
echo "==================================="

# Test backend push endpoint
echo "1. Test backend push endpoint:"
echo "   🔗 Testing: /api/push/test"

# Test với curl
RESPONSE=$(curl -k -s -X GET "https://10.10.68.200:8000/api/push/test" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "   ✅ Backend endpoint hoạt động"
    echo "   📄 Response: $RESPONSE"
else
    echo "   ❌ Backend endpoint không hoạt động"
fi

echo ""
echo "📱 HƯỚNG DẪN TEST PUSH NOTIFICATION:"
echo "====================================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: https://10.10.68.200:5173"
echo "3. Đăng nhập vào hệ thống"
echo "4. Làm theo các bước sau:"
echo ""
echo "🔍 BƯỚC 1: CÀI ĐẶT PWA"
echo "======================="
echo "• Tìm nút 'Cài đặt App' hoặc 'Install App'"
echo "• Bấm cài đặt PWA"
echo "• Hoặc menu → 'Add to Home Screen'"
echo "• Cài đặt app như app thật"
echo ""
echo "🔍 BƯỚC 2: BẬT PUSH NOTIFICATION"
echo "================================="
echo "• Vào Settings → Push Notifications"
echo "• Bấm 'Enable Notifications'"
echo "• Cho phép notification permission"
echo "• Đợi thông báo 'Thông báo đã được bật!'"
echo ""
echo "🔍 BƯỚC 3: TEST THÔNG BÁO"
echo "=========================="
echo "• Bấm nút 'Test Notification'"
echo "• Kiểm tra xem có thông báo hiện không"
echo "• Nếu có thông báo → OK"
echo "• Nếu không có → Kiểm tra console logs"
echo ""
echo "🔍 BƯỚC 4: TEST TẠO NHIỆM VỤ"
echo "============================="
echo "• Admin tạo nhiệm vụ mới"
echo "• Giao cho employee"
echo "• Employee nhận thông báo"
echo "• Thông báo hiện trên điện thoại"
echo ""
echo "⚠️ NẾU KHÔNG CÓ THÔNG BÁO:"
echo "=========================="
echo "• Kiểm tra xem đã cài đặt PWA chưa"
echo "• Kiểm tra xem đã bật notification permission chưa"
echo "• Kiểm tra console logs để xem lỗi gì"
echo "• Thử refresh trang và làm lại"
echo "• Đảm bảo đang dùng HTTPS"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: https://10.10.68.200:5173"
echo "• Public (4G/WiFi khác): https://semiprivate-interlamellar-phillis.ngrok-free.dev"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
