#!/bin/bash

echo "🔥 FIX ULTIMATE - SỬA TẤT CẢ MỌI THỨ"
echo "====================================="

# 1. KILL TẤT CẢ PROCESSES
echo "💀 Kill tất cả processes..."
sudo pkill -f "uvicorn" 2>/dev/null
sudo pkill -f "python.*app" 2>/dev/null
sudo pkill -f "ngrok" 2>/dev/null
sudo pkill -f "node.*frontend" 2>/dev/null
sudo lsof -ti:8000 | xargs sudo kill -9 2>/dev/null
sudo lsof -ti:4040 | xargs sudo kill -9 2>/dev/null
sudo lsof -ti:3000 | xargs sudo kill -9 2>/dev/null
sleep 5

# 2. RESTORE DATABASE
echo "💾 Restore database..."
cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/backend/app.db
chmod 666 /Users/maybe/Documents/shopee/backend/app.db

# 3. FIX BACKEND APP.PY
echo "🔧 Fix backend app.py..."
cat > /Users/maybe/Documents/shopee/backend/app.py << 'EOF'
import uvicorn

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
EOF

# 4. FIX FRONTEND ENDPOINTS - KIỂM TRA VÀ SỬA TẤT CẢ
echo "🔧 Fix frontend endpoints..."

# Kiểm tra và sửa QRScannerPage.tsx
if grep -q "/patrol-records/checkin" /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx; then
    echo "Sửa QRScannerPage.tsx..."
    sed -i '' 's|/patrol-records/checkin|/api/patrol-records/checkin|g' /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx
fi

# Kiểm tra và sửa CheckinPage.tsx
if grep -q "/patrol-records/checkin" /Users/maybe/Documents/shopee/frontend/src/pages/CheckinPage.tsx; then
    echo "Sửa CheckinPage.tsx..."
    sed -i '' 's|/patrol-records/checkin|/api/patrol-records/checkin|g' /Users/maybe/Documents/shopee/frontend/src/pages/CheckinPage.tsx
fi

# 5. KIỂM TRA BACKEND STRUCTURE
echo "🔍 Kiểm tra backend structure..."
if [ ! -f "/Users/maybe/Documents/shopee/backend/app/main.py" ]; then
    echo "❌ Không tìm thấy main.py!"
    find /Users/maybe/Documents/shopee/backend -name "*.py" | head -10
    exit 1
fi

# 6. START BACKEND VỚI NHIỀU CÁCH
echo "🚀 Start backend..."

# Cách 1: Từ thư mục backend
cd /Users/maybe/Documents/shopee/backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID1=$!
sleep 3

# Test backend
if curl -s http://localhost:8000/health | grep -q "healthy"; then
    echo "✅ Backend OK với cách 1!"
else
    echo "❌ Cách 1 fail, thử cách 2..."
    kill $BACKEND_PID1 2>/dev/null
    
    # Cách 2: Từ thư mục gốc
    cd /Users/maybe/Documents/shopee
    python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
    BACKEND_PID2=$!
    sleep 3
    
    if curl -s http://localhost:8000/health | grep -q "healthy"; then
        echo "✅ Backend OK với cách 2!"
    else
        echo "❌ Cả 2 cách đều fail!"
        exit 1
    fi
fi

# 7. START NGROK
echo "🌐 Start ngrok..."
ngrok http 8000 --log=stdout &
sleep 5

# 8. GET NGROK URL
echo "🔗 Get ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "📱 Ngrok URL: $NGROK_URL"

# 9. TEST TẤT CẢ ENDPOINTS
echo "🧪 Test tất cả endpoints..."

echo "Test /health:"
curl -s http://localhost:8000/health

echo -e "\nTest /api/patrol-records/checkin (sẽ báo 403 - bình thường):"
curl -s -X POST http://localhost:8000/api/patrol-records/checkin \
  -H "Content-Type: application/json" \
  -d '{"qr_code":"test","location_id":1,"notes":"test"}'

echo -e "\nTest /docs:"
curl -s http://localhost:8000/docs | head -5

# 10. KIỂM TRA FRONTEND
echo -e "\n🔍 Kiểm tra frontend..."
if [ -d "/Users/maybe/Documents/shopee/frontend" ]; then
    echo "✅ Frontend folder tồn tại"
    if [ -f "/Users/maybe/Documents/shopee/frontend/package.json" ]; then
        echo "✅ package.json tồn tại"
    else
        echo "❌ Không có package.json"
    fi
else
    echo "❌ Không tìm thấy frontend folder"
fi

echo ""
echo "🎉 HOÀN THÀNH ULTIMATE FIX!"
echo "=============================="
echo "📱 Frontend URL: $NGROK_URL"
echo "🔧 Backend: http://localhost:8000"
echo "📊 Backend docs: http://localhost:8000/docs"
echo ""
echo "🎯 BÂY GIỜ HÃY:"
echo "1. Mở $NGROK_URL"
echo "2. Đăng nhập trước (quan trọng!)"
echo "3. Thử checkin"
echo ""
echo "💡 Nếu vẫn lỗi, gửi log lỗi cho tôi!"
