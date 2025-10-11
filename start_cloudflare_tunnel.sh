#!/bin/bash

echo "🌐 KHỞI ĐỘNG CLOUDFLARE TUNNEL"
echo "==============================="

# Dừng ngrok cũ nếu có
echo "🛑 Dừng ngrok cũ..."
pkill -f ngrok 2>/dev/null || true

# Dừng cloudflared cũ nếu có
echo "🛑 Dừng cloudflared cũ..."
pkill -f cloudflared 2>/dev/null || true

sleep 2

# Khởi động Cloudflare Tunnel
echo "🚀 Khởi động Cloudflare Tunnel..."
echo "📍 Kết nối đến: https://10.10.68.200:5173"
echo ""

# Khởi động tunnel và capture output
cloudflared tunnel --url https://10.10.68.200:5173 2>&1 | while IFS= read -r line; do
    echo "$line"
    
    # Tìm URL trong output
    if echo "$line" | grep -q "https://.*\.trycloudflare\.com"; then
        TUNNEL_URL=$(echo "$line" | grep -o "https://[^[:space:]]*\.trycloudflare\.com")
        echo ""
        echo "✅ CLOUDFLARE TUNNEL ĐÃ KHỞI ĐỘNG!"
        echo "=================================="
        echo "🌍 Tunnel URL: $TUNNEL_URL"
        echo "🔧 Local URL: https://10.10.68.200:5173"
        echo ""
        echo "📱 Truy cập ngay:"
        echo "1. Mở: $TUNNEL_URL"
        echo "2. Đăng nhập với admin/admin"
        echo "3. Kiểm tra trạng thái nhiệm vụ"
        echo ""
        echo "💡 Ưu điểm Cloudflare Tunnel:"
        echo "   ✅ KHÔNG giới hạn bandwidth"
        echo "   ✅ KHÔNG giới hạn thời gian"
        echo "   ✅ Bảo mật tốt hơn ngrok"
        echo "   ✅ Hiệu suất cao với CDN"
        echo ""
    fi
done

