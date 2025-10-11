#!/bin/bash

echo "🚀 Khởi động hệ thống với auto-sync ảnh..."

# Đồng bộ ảnh trước khi khởi động
echo "🔄 Đồng bộ ảnh hiện có..."
/Users/maybe/Documents/shopee/sync_photos.sh

# Khởi động backend
echo "🔧 Khởi động backend..."
cd /Users/maybe/Documents/shopee/backend
python3 -m app.main &

# Khởi động frontend
echo "🎨 Khởi động frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &

echo "✅ Hệ thống đã khởi động!"
echo "📱 Frontend: https://10.10.68.200:5173"
echo "🔧 Backend: https://10.10.68.200:8000"
echo ""
echo "💡 Để đồng bộ ảnh sau khi checkin, chạy: /Users/maybe/Documents/shopee/sync_photos.sh"
