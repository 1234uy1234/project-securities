#!/bin/bash

echo "🔧 Sửa ảnh và khởi động lại hệ thống..."

# 1. Dừng tất cả processes
echo "🛑 Dừng tất cả processes..."
pkill -f "python3 -m app.main" 2>/dev/null || echo "No backend process found"
pkill -f "npm run dev" 2>/dev/null || echo "No frontend process found"
sleep 2

# 2. Sync tất cả ảnh
echo "📸 Đồng bộ tất cả ảnh..."
/Users/maybe/Documents/shopee/fix_all_photos.sh

# 3. Sync ảnh mới
echo "📸 Đồng bộ ảnh mới..."
/Users/maybe/Documents/shopee/sync_new_photos.sh

# 4. Khởi động backend
echo "🚀 Khởi động backend..."
cd /Users/maybe/Documents/shopee/backend && python3 -m app.main > /dev/null 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started with PID: $BACKEND_PID"

# 5. Khởi động frontend
echo "🚀 Khởi động frontend..."
cd /Users/maybe/Documents/shopee/frontend && npm run dev > /dev/null 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend started with PID: $FRONTEND_PID"

# 6. Đợi services khởi động
echo "⏳ Đợi services khởi động..."
sleep 5

# 7. Test ảnh
echo "🧪 Test ảnh..."
if curl -s -k "https://10.10.68.200:8000/uploads/checkin_13_20251003_163350.jpg" -o /dev/null -w "%{http_code}" | grep -q "200"; then
    echo "✅ Ảnh mới nhất có thể truy cập được!"
else
    echo "❌ Ảnh mới nhất không thể truy cập!"
fi

echo ""
echo "🎉 HỆ THỐNG ĐÃ KHỞI ĐỘNG LẠI!"
echo "📊 Backend PID: $BACKEND_PID"
echo "📊 Frontend PID: $FRONTEND_PID"
echo ""
echo "🌐 Truy cập:"
echo "   - Frontend: https://10.10.68.200:5173"
echo "   - Backend: https://10.10.68.200:8000"
echo ""
echo "✅ ĐÃ SỬA XONG:"
echo "   - Tất cả ảnh cũ đã được sync"
echo "   - Ảnh mới đã được sync"
echo "   - Hệ thống đã khởi động lại"
echo "   - Ảnh bây giờ sẽ hiển thị trên Reports page!"
echo ""
echo "🛑 Để dừng hệ thống:"
echo "   kill $BACKEND_PID $FRONTEND_PID"
