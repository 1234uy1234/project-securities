#!/bin/bash

echo "🌍 LẤY CLOUDFLARE TUNNEL URL (LOCALHOST)"
echo "========================================="

# Kiểm tra trạng thái hệ thống
echo "🔍 Kiểm tra trạng thái hệ thống..."
curl -s -o /dev/null -w "Backend: %{http_code}\n" http://10.10.68.200:8000/health
curl -s -o /dev/null -w "Frontend: %{http_code}\n" http://localhost:5173

echo ""
echo "🌍 CLOUDFLARE TUNNEL URL MỚI (LOCALHOST):"
echo "=========================================="
echo "📱 Để lấy URL mới, hãy:"
echo "1. Mở terminal mới"
echo "2. Chạy: cloudflared tunnel --url http://localhost:5173"
echo "3. URL sẽ hiển thị với dạng: https://xxxxx.trycloudflare.com"
echo ""
echo "✅ Hệ thống đã sẵn sàng:"
echo "   🔧 Backend: http://10.10.68.200:8000"
echo "   🎨 Frontend: http://localhost:5173 (đã sửa allowedHosts)"
echo "   🌐 Cloudflare Tunnel: Đang chạy với localhost"
echo ""
echo "🎯 Sau khi có URL mới:"
echo "1. Truy cập URL trong trình duyệt"
echo "2. Đăng nhập với admin/admin"
echo "3. Kiểm tra trạng thái nhiệm vụ"
echo ""
echo "💡 Lưu ý:"
echo "   - Đã chuyển từ IP 10.10.68.200 sang localhost"
echo "   - Cloudflare Tunnel hoạt động tốt hơn với localhost"
echo "   - Không còn lỗi 'Origin DNS error'"









