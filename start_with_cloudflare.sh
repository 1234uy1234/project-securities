#!/bin/bash

echo "🌐 KHỞI ĐỘNG HỆ THỐNG VỚI CLOUDFLARE TUNNEL"
echo "============================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "python.*app" 2>/dev/null || true
pkill -f "npm.*dev" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
pkill -f "ngrok" 2>/dev/null || true
pkill -f "cloudflared" 2>/dev/null || true

sleep 3

# Khôi phục database nếu cần
if [ ! -f "/Users/maybe/Documents/shopee/app.db" ] || [ $(stat -f%z "/Users/maybe/Documents/shopee/app.db" 2>/dev/null || echo "0") -eq 0 ]; then
    echo "🔧 Khôi phục database..."
    cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/app.db
fi

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 10.10.68.200 --port 8000 &
BACKEND_PID=$!

sleep 3

# Khởi động frontend
echo "🎨 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev -- --host 10.10.68.200 --port 5173 &
FRONTEND_PID=$!

sleep 5

# Khởi động Cloudflare Tunnel
echo "🌐 Khởi động Cloudflare Tunnel..."
cd /Users/maybe/Documents/shopee
cloudflared tunnel --url http://10.10.68.200:5173 &
CLOUDFLARE_PID=$!

sleep 5

# Test kết nối
echo "🔍 Test kết nối..."
curl -s -o /dev/null -w "%{http_code}" http://10.10.68.200:8000/health >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Backend: OK"
else
    echo "❌ Backend: FAIL"
fi

curl -s -o /dev/null -w "%{http_code}" http://10.10.68.200:5173 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: FAIL"
fi

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG VỚI CLOUDFLARE TUNNEL!"
echo "==============================================="
echo "🔧 Backend: http://10.10.68.200:8000"
echo "🎨 Frontend: http://10.10.68.200:5173"
echo "🌍 Cloudflare Tunnel: Đang khởi động..."
echo ""
echo "📱 Để lấy Cloudflare URL:"
echo "1. Mở terminal mới"
echo "2. Chạy: ps aux | grep cloudflared"
echo "3. URL sẽ hiển thị trong log của cloudflared"
echo ""
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "💡 Ưu điểm Cloudflare Tunnel:"
echo "   ✅ KHÔNG giới hạn bandwidth"
echo "   ✅ KHÔNG giới hạn thời gian"
echo "   ✅ Bảo mật tốt hơn ngrok"
echo "   ✅ Hiệu suất cao với CDN"
echo ""
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, Cloudflare=$CLOUDFLARE_PID"
echo "Dừng: kill $BACKEND_PID $FRONTEND_PID $CLOUDFLARE_PID"









