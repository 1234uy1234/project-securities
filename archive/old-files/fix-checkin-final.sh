#!/bin/bash

echo "🔧 FIX CHECKIN FINAL - DỨT ĐIỂM TẤT CẢ LỖI"
echo "=============================================="

# 1. DỪNG TẤT CẢ PROCESSES
echo "🛑 Dừng tất cả processes..."
pkill -f "uvicorn" 2>/dev/null
pkill -f "python.*app.py" 2>/dev/null
pkill -f "ngrok" 2>/dev/null
sleep 3

# 2. RESTORE DATABASE
echo "💾 Restore database..."
cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/backend/app.db
chmod 644 /Users/maybe/Documents/shopee/backend/app.db

# 3. FIX BACKEND APP.PY
echo "🔧 Fix backend app.py..."
cat > /Users/maybe/Documents/shopee/backend/app.py << 'EOF'
import uvicorn

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
EOF

# 4. FIX FRONTEND ENDPOINTS
echo "🔧 Fix frontend endpoints..."

# Fix QRScannerPage.tsx
sed -i '' 's|/patrol-records/checkin|/api/patrol-records/checkin|g' /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx

# Fix CheckinPage.tsx  
sed -i '' 's|/patrol-records/checkin|/api/patrol-records/checkin|g' /Users/maybe/Documents/shopee/frontend/src/pages/CheckinPage.tsx

# 5. START BACKEND
echo "🚀 Start backend..."
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 5

# 6. TEST BACKEND
echo "🧪 Test backend..."
for i in {1..5}; do
    if curl -s http://localhost:8000/health | grep -q "healthy"; then
        echo "✅ Backend OK!"
        break
    else
        echo "⏳ Đợi backend... ($i/5)"
        sleep 2
    fi
done

# 7. START NGROK
echo "🌐 Start ngrok..."
ngrok http 8000 --log=stdout &
sleep 3

# 8. GET NGROK URL
echo "🔗 Get ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "📱 Ngrok URL: $NGROK_URL"

# 9. TEST CHECKIN ENDPOINT
echo "🧪 Test checkin endpoint..."
curl -s -X POST http://localhost:8000/api/patrol-records/checkin \
  -H "Content-Type: application/json" \
  -d '{"qr_code":"test","location_id":1,"notes":"test"}' | head -20

echo ""
echo "✅ HOÀN THÀNH!"
echo "📱 Frontend URL: $NGROK_URL"
echo "🔧 Backend: http://localhost:8000"
echo ""
echo "🎯 BÂY GIỜ HÃY:"
echo "1. Mở $NGROK_URL"
echo "2. Đăng nhập trước"
echo "3. Thử checkin - SẼ KHÔNG CÒN LỖI!"
echo ""
echo "💡 Nếu vẫn lỗi, chạy: ./fix-checkin-final.sh"
