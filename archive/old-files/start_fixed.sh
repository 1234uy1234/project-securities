#!/bin/bash

echo "🚀 Khởi động hệ thống với ảnh tự động hiển thị..."

# Đường dẫn đến thư mục dự án
PROJECT_ROOT="/Users/maybe/Documents/shopee"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"

# 1. Sửa tất cả ảnh cũ
echo "🔧 Step 1: Sửa tất cả ảnh cũ..."
"$PROJECT_ROOT/fix_all_photos.sh"

# 2. Khởi động backend (trong nền)
echo "🔧 Step 2: Khởi động backend..."
cd "$BACKEND_DIR" && python3 -m app.main > /dev/null 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started with PID: $BACKEND_PID"

# 3. Khởi động frontend (trong nền)
echo "🔧 Step 3: Khởi động frontend..."
cd "$FRONTEND_DIR" && npm run dev > /dev/null 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend started with PID: $FRONTEND_PID"

echo ""
echo "🎉 HỆ THỐNG ĐÃ KHỞI ĐỘNG HOÀN CHỈNH!"
echo "📊 Backend PID: $BACKEND_PID"
echo "📊 Frontend PID: $FRONTEND_PID"
echo ""
echo "🌐 Truy cập:"
echo "   - Frontend: https://10.10.68.200:5173"
echo "   - Backend: https://10.10.68.200:8000"
echo ""
echo "🛑 Để dừng hệ thống:"
echo "   kill $BACKEND_PID $FRONTEND_PID"
echo ""
echo "✅ ẢNH CHECKIN BÂY GIỜ SẼ TỰ ĐỘNG HIỂN THỊ!"
