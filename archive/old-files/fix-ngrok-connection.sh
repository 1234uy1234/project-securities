#!/bin/bash

echo "🔥 FIX NGROK CONNECTION - DỨT ĐIỂM"
echo "=================================="

# 1. KILL TẤT CẢ
echo "💀 Kill tất cả processes..."
sudo pkill -f "uvicorn" 2>/dev/null
sudo pkill -f "ngrok" 2>/dev/null
sudo lsof -ti:8000 | xargs sudo kill -9 2>/dev/null
sudo lsof -ti:4040 | xargs sudo kill -9 2>/dev/null
sleep 5

# 2. RESTORE DATABASE
echo "💾 Restore database..."
cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/backend/app.db

# 3. START BACKEND
echo "🚀 Start backend..."
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app.main:app --host 127.0.0.1 --port 8000 --reload &
sleep 5

# 4. TEST BACKEND
echo "🧪 Test backend..."
for i in {1..10}; do
    if curl -s http://127.0.0.1:8000/health | grep -q "healthy"; then
        echo "✅ Backend OK!"
        break
    else
        echo "⏳ Đợi backend... ($i/10)"
        sleep 2
    fi
done

# 5. START NGROK
echo "🌐 Start ngrok..."
ngrok http 127.0.0.1:8000 --log=stdout &
sleep 5

# 6. TEST NGROK
echo "🧪 Test ngrok..."
for i in {1..10}; do
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ ! -z "$NGROK_URL" ]; then
        echo "✅ Ngrok OK: $NGROK_URL"
        break
    else
        echo "⏳ Đợi ngrok... ($i/10)"
        sleep 2
    fi
done

# 7. TEST API
echo "🧪 Test API..."
if [ ! -z "$NGROK_URL" ]; then
    API_RESPONSE=$(curl -s -X POST "$NGROK_URL/api/patrol-records/checkin" \
        -H "Content-Type: application/json" \
        -d '{"qr_code":"test","location_id":1,"notes":"test","latitude":0,"longitude":0,"photo":"data:image/jpeg;base64,placeholder"}' 2>/dev/null)
    
    if echo "$API_RESPONSE" | grep -q "Not authenticated"; then
        echo "✅ API OK (403 là bình thường - cần đăng nhập)"
    elif echo "$API_RESPONSE" | grep -q "DOCTYPE html"; then
        echo "❌ API FAIL - Ngrok không kết nối được"
    else
        echo "✅ API Response: $API_RESPONSE"
    fi
fi

echo ""
echo "🎉 HOÀN THÀNH!"
echo "📱 URL: $NGROK_URL"
echo "🔧 Backend: http://127.0.0.1:8000"
echo ""
echo "🎯 BÂY GIỜ:"
echo "1. Mở $NGROK_URL"
echo "2. Đăng nhập"
echo "3. Thử checkin"
echo ""
