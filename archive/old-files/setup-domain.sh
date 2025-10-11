#!/bin/bash

echo "🌐 Cấu hình domain: truongxuan1234.id.vn"
echo "======================================="

# IP public của bạn
PUBLIC_IP="27.72.116.183"
DOMAIN="truongxuan1234.id.vn"

echo "📍 Thông tin domain:"
echo "  - Domain: $DOMAIN"
echo "  - IP Public: $PUBLIC_IP"
echo "  - IP Local: 10.10.68.200"
echo ""

echo "🔧 Các bước cấu hình:"
echo ""
echo "1️⃣ CẤU HÌNH DNS (trên trang quản lý domain):"
echo "   - A Record: $DOMAIN → $PUBLIC_IP"
echo "   - A Record: www.$DOMAIN → $PUBLIC_IP"
echo "   - CNAME: api.$DOMAIN → $DOMAIN"
echo ""

echo "2️⃣ CẤU HÌNH ROUTER (Port Forwarding):"
echo "   - Port 80 (HTTP) → 10.10.68.200:5173"
echo "   - Port 443 (HTTPS) → 10.10.68.200:5173"
echo "   - Port 8000 (Backend) → 10.10.68.200:8000"
echo ""

echo "3️⃣ CẤU HÌNH BACKEND CORS:"
echo "   - Thêm $DOMAIN vào allowed_origins"
echo ""

echo "4️⃣ KIỂM TRA KẾT NỐI:"
echo "   - Frontend: https://$DOMAIN"
echo "   - Backend: https://$DOMAIN:8000"
echo ""

echo "⚠️  LƯU Ý:"
echo "   - Cần có SSL certificate cho HTTPS"
echo "   - Có thể dùng Let's Encrypt (miễn phí)"
echo "   - Hoặc dùng Cloudflare để có SSL miễn phí"
echo ""

echo "🚀 Sau khi cấu hình xong, chạy:"
echo "   ./start-domain.sh"
