#!/bin/bash

echo "🌍 LẤY CLOUDFLARE TUNNEL URL"
echo "============================="

# Tìm process cloudflared
CLOUDFLARE_PID=$(ps aux | grep "cloudflared tunnel" | grep -v grep | awk '{print $2}' | head -1)

if [ -z "$CLOUDFLARE_PID" ]; then
    echo "❌ Cloudflare Tunnel chưa chạy"
    echo "💡 Chạy: ./start_with_cloudflare.sh"
    exit 1
fi

echo "✅ Cloudflare Tunnel đang chạy (PID: $CLOUDFLARE_PID)"

# Kiểm tra kết nối local
echo ""
echo "🔍 Kiểm tra kết nối local..."
curl -s -o /dev/null -w "Frontend HTTP: %{http_code}\n" http://10.10.68.200:5173
curl -s -o /dev/null -w "Backend HTTP: %{http_code}\n" http://10.10.68.200:8000/health

echo ""
echo "🌍 CLOUDFLARE TUNNEL URL:"
echo "========================="
echo "📱 Để lấy URL, hãy:"
echo "1. Mở terminal mới"
echo "2. Chạy: cloudflared tunnel --url http://10.10.68.200:5173"
echo "3. URL sẽ hiển thị với dạng: https://xxxxx.trycloudflare.com"
echo ""
echo "💡 Hoặc kiểm tra log của process hiện tại:"
echo "   PID: $CLOUDFLARE_PID"
echo ""
echo "🎯 Sau khi có URL:"
echo "1. Mở URL trong trình duyệt"
echo "2. Đăng nhập với admin/admin"
echo "3. Kiểm tra trạng thái nhiệm vụ"
echo ""
echo "✅ Ưu điểm Cloudflare Tunnel:"
echo "   🚫 KHÔNG giới hạn bandwidth"
echo "   🚫 KHÔNG giới hạn thời gian"
echo "   🔒 Bảo mật tốt hơn ngrok"
echo "   ⚡ Hiệu suất cao với CDN"

