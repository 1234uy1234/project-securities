#!/bin/bash

echo "🌐 TẠO CLOUDFLARE NAMED TUNNEL - URL CỐ ĐỊNH"
echo "============================================="

# Tạo tunnel với tên cố định
echo "🔧 Tạo Named Tunnel..."
cloudflared tunnel create shopee-app

# Tạo config file
echo "📝 Tạo config file..."
mkdir -p ~/.cloudflared

cat > ~/.cloudflared/config.yml << EOF
tunnel: shopee-app
credentials-file: ~/.cloudflared/shopee-app.json

ingress:
  - hostname: shopee-app.your-domain.trycloudflare.com
    service: http://localhost:5173
  - service: http_status:404
EOF

echo "✅ HOÀN TẤT!"
echo "============"
echo "🌍 URL cố định: https://shopee-app.your-domain.trycloudflare.com"
echo "🔐 Login: admin/admin"
echo ""
echo "🚀 Để chạy tunnel:"
echo "1. Chạy: ./start_named_tunnel.sh"
echo "2. URL sẽ không bao giờ thay đổi!"









