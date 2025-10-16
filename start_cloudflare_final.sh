#!/bin/bash

echo "🌐 KHỞI ĐỘNG HỆ THỐNG VỚI CLOUDFLARE TUNNEL (FINAL)"
echo "====================================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "python.*app" 2>/dev/null || true
pkill -f "npm.*dev" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
pkill -f "cloudflared" 2>/dev/null || true

sleep 3

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
uvicorn backend.app.main:app --host 10.10.68.200 --port 8000 &
BACKEND_PID=$!

sleep 3

# Khởi động frontend trên localhost
echo "🎨 Khởi động Frontend trên localhost..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!

sleep 5

# Khởi động Cloudflare Tunnel với localhost
echo "🌐 Khởi động Cloudflare Tunnel với localhost..."
cd /Users/maybe/Documents/shopee
cloudflared tunnel --url http://localhost:5173 &
CLOUDFLARE_PID=$!

sleep 5

# Test kết nối
echo "🔍 Test kết nối..."
curl -s -o /dev/null -w "Backend: %{http_code}\n" http://10.10.68.200:8000/health
curl -s -o /dev/null -w "Frontend: %{http_code}\n" http://localhost:5173

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG VỚI CLOUDFLARE TUNNEL!"
echo "================================================"
echo "🔧 Backend: http://10.10.68.200:8000"
echo "🎨 Frontend: http://localhost:5173"
echo "🌍 Cloudflare Tunnel: Đang khởi động với localhost..."
echo ""
echo "📱 Để lấy Cloudflare URL:"
echo "1. Mở terminal mới"
echo "2. Chạy: cloudflared tunnel --url http://localhost:5173"
echo "3. URL sẽ hiển thị với dạng: https://xxxxx.trycloudflare.com"
echo ""
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "✅ Đã sửa lỗi 'Origin DNS error' - sử dụng localhost"
echo "🔧 PIDs: Backend=$BACKEND_PID, Frontend=$FRONTEND_PID, Cloudflare=$CLOUDFLARE_PID"









