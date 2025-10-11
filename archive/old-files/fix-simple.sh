#!/bin/bash

echo "🔧 FIX ĐƠN GIẢN - 1 LẦN XONG"
echo "============================="

# 1. DỪNG TẤT CẢ
pkill -f "uvicorn" 2>/dev/null
pkill -f "ngrok" 2>/dev/null
sleep 2

# 2. RESTORE DATABASE
cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/backend/app.db

# 3. START BACKEND
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
sleep 3

# 4. START NGROK
ngrok http 8000 &
sleep 3

# 5. GET URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4)

echo ""
echo "✅ XONG!"
echo "📱 Mở: $NGROK_URL"
echo "🔑 Đăng nhập trước"
echo "🎯 Thử checkin"
echo ""
