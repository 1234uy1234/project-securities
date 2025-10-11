#!/bin/bash

echo "🌐 LẤY URL CLOUDFLARE TUNNEL"
echo "============================"

# Dừng cloudflared cũ
pkill -f "cloudflared" 2>/dev/null || true
sleep 2

# Khởi động cloudflared mới và lấy URL
echo "🔍 Đang tạo URL mới..."
cloudflared tunnel --url http://localhost:5173 &
CLOUDFLARED_PID=$!
sleep 5

echo "✅ HOÀN TẤT!"
echo "🌍 URL sẽ hiển thị ở trên"
echo "🔐 Login: admin/admin"
echo "🔧 PID: $CLOUDFLARED_PID"

