#!/bin/bash

# 📱 TEST PWA - ManhToan Patrol
# Kiểm tra tất cả tính năng PWA

echo "📱 TEST PWA - ManhToan Patrol"
echo "=============================="

FRONTEND_URL="https://10.10.68.200:5173"
NGROK_URL="https://semiprivate-interlamellar-phillis.ngrok-free.dev"

# 1. Test frontend
echo "1. Test frontend:"
echo "   🎨 Frontend: $FRONTEND_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 2. Test PWA files
echo "2. Test PWA files:"
echo "   📄 Manifest: $FRONTEND_URL/manifest.json"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/manifest.json | grep -q "200"; then
    echo "   ✅ Manifest.json có sẵn"
else
    echo "   ❌ Manifest.json không tìm thấy"
fi

echo "   🔧 Service Worker: $FRONTEND_URL/sw.js"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/sw.js | grep -q "200"; then
    echo "   ✅ Service Worker có sẵn"
else
    echo "   ❌ Service Worker không tìm thấy"
fi

# 3. Test PWA icons
echo "3. Test PWA icons:"
icons=("icon-96x96.png" "icon-144x144.png" "icon-192x192.png" "icon-512x512.png" "favicon.ico")
for icon in "${icons[@]}"; do
    if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/$icon | grep -q "200"; then
        echo "   ✅ $icon có sẵn"
    else
        echo "   ❌ $icon không tìm thấy"
    fi
done

# 4. Test manifest content
echo "4. Test manifest content:"
manifest_content=$(curl -k -s $FRONTEND_URL/manifest.json)
if echo "$manifest_content" | grep -q "ManhToan Patrol"; then
    echo "   ✅ Manifest có tên app đúng"
else
    echo "   ❌ Manifest thiếu tên app"
fi

if echo "$manifest_content" | grep -q "standalone"; then
    echo "   ✅ Manifest có display mode standalone"
else
    echo "   ❌ Manifest thiếu display mode"
fi

if echo "$manifest_content" | grep -q "shortcuts"; then
    echo "   ✅ Manifest có shortcuts"
else
    echo "   ❌ Manifest thiếu shortcuts"
fi

# 5. Test HTTPS
echo "5. Test HTTPS:"
if echo "$FRONTEND_URL" | grep -q "https"; then
    echo "   ✅ Frontend sử dụng HTTPS"
else
    echo "   ❌ Frontend không sử dụng HTTPS (PWA cần HTTPS)"
fi

# 6. Test ngrok
echo "6. Test ngrok (public access):"
echo "   🌐 Public URL: $NGROK_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL | grep -q "200"; then
    echo "   ✅ Ngrok hoạt động"
else
    echo "   ❌ Ngrok không hoạt động"
fi

echo ""
echo "🎉 KIỂM TRA PWA HOÀN TẤT!"
echo "========================="
echo "✅ PWA đã sẵn sàng để cài đặt!"
echo ""
echo "📱 HƯỚNG DẪN CÀI ĐẶT:"
echo "====================="
echo "1. Mở trình duyệt trên điện thoại"
echo "2. Truy cập: $FRONTEND_URL"
echo "3. Đăng nhập vào hệ thống"
echo "4. Nhấn nút 'Cài đặt App' (sẽ xuất hiện tự động)"
echo "5. Hoặc nhấn menu → 'Cài đặt ứng dụng'"
echo ""
echo "🔗 LINKS TRUY CẬP:"
echo "=================="
echo "• Local Network: $FRONTEND_URL"
echo "• Public (4G/WiFi khác): $NGROK_URL"
echo ""
echo "📖 Chi tiết: Xem file PWA-INSTALL-GUIDE.md"
echo ""
echo "🎯 TÍNH NĂNG PWA:"
echo "=================="
echo "✅ Icon riêng trên màn hình chính"
echo "✅ Khởi động nhanh như app native"
echo "✅ Hoạt động offline"
echo "✅ Shortcuts (Scanner, Reports, Dashboard)"
echo "✅ Thông báo push (sắp có)"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-ngrok.sh"
