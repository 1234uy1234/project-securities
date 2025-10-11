#!/bin/bash

echo "🎉 KHỞI ĐỘNG HỆ THỐNG MANHTOAN PLASTIC - FINAL"
echo "=============================================="

# Dừng process cũ
echo "🛑 Dừng process cũ..."
pkill -f "npm run dev" 2>/dev/null
pkill -f "uvicorn" 2>/dev/null
pkill -f "nginx" 2>/dev/null
pkill -f "ngrok" 2>/dev/null
sleep 3

# Xóa file .env.local cũ
echo "🧹 Xóa file .env.local cũ..."
rm -f frontend/.env.local

# Khởi động Backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
python3 -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
sleep 3

# Khởi động Frontend
echo "🌐 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
rm -rf node_modules/.vite
npm run dev -- --host 0.0.0.0 --port 5173 &
sleep 3

# Khởi động Nginx
echo "🔄 Khởi động Nginx..."
cd /Users/maybe/Documents/shopee
nginx -c $(pwd)/nginx_combined.conf &
sleep 2

# Khởi động Ngrok
echo "🌍 Khởi động Ngrok..."
ngrok http 10.10.68.200:8080 --log=stdout > ngrok_combined.log 2>&1 &
sleep 5

# Lấy URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data.get('tunnels', []):
        if tunnel.get('proto') == 'https':
            print(tunnel.get('public_url'))
            break
except:
    print('')
")

if [ -n "$NGROK_URL" ]; then
    echo ""
    echo "🎉 HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
    echo "🌐 TRUY CẬP: $NGROK_URL"
    echo "👤 ĐĂNG NHẬP: admin / admin123"
    echo ""
    echo "📊 Các trang chính:"
    echo "  - Dashboard: $NGROK_URL"
    echo "  - Reports: $NGROK_URL/reports (✅ Đã sửa lỗi Mixed Content)"
    echo "  - Tasks: $NGROK_URL/tasks"
    echo "  - QR Scanner: $NGROK_URL/qr-scanner"
    echo ""
    echo "✅ Đã sửa:"
    echo "  - Xóa file .env.local cũ"
    echo "  - Frontend sử dụng ngrok URL"
    echo "  - API hoạt động qua HTTPS"
    echo "  - Ảnh hiển thị đúng"
    echo ""
    echo "🛑 Để dừng: ./stop_system.sh"
else
    echo "❌ Không thể lấy Ngrok URL"
fi
