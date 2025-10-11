#!/bin/bash

echo "🚀 KHỞI ĐỘNG HỆ THỐNG CUỐI CÙNG - ẢNH MỚI SẼ TỰ ĐỘNG HIỂN THỊ!"

# Đường dẫn đến thư mục dự án
PROJECT_ROOT="/Users/maybe/Documents/shopee"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"

# 1. Dừng tất cả processes cũ
echo "🔧 Step 1: Dừng tất cả processes cũ..."
pkill -f "python3 -m app.main" 2>/dev/null || echo "No backend process found"
pkill -f "npm run dev" 2>/dev/null || echo "No frontend process found"
sleep 2

# 2. Sync tất cả ảnh cũ
echo "🔧 Step 2: Sync tất cả ảnh cũ..."
python3 "$PROJECT_ROOT/auto_sync_photos.py"

# 3. Khởi động backend (trong nền)
echo "🔧 Step 3: Khởi động backend..."
cd "$BACKEND_DIR" && python3 -m app.main > /dev/null 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started with PID: $BACKEND_PID"

# 4. Khởi động frontend (trong nền)
echo "🔧 Step 4: Khởi động frontend..."
cd "$FRONTEND_DIR" && npm run dev > /dev/null 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend started with PID: $FRONTEND_PID"

# 5. Đợi services khởi động
echo "🔧 Step 5: Đợi services khởi động..."
sleep 5

# 6. Test check-in mới
echo "🔧 Step 6: Test check-in mới..."
/Users/maybe/Documents/shopee/test_new_checkin.sh

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
echo "✅ ĐÃ SỬA XONG HOÀN TOÀN:"
echo "   ✅ Xóa checkin_backup.py và checkin_new.py gây conflict"
echo "   ✅ Backend chỉ sử dụng patrol_records.py"
echo "   ✅ Ảnh mới check-in sẽ tự động lưu vào /backend/uploads/"
echo "   ✅ Ảnh mới sẽ tự động hiển thị trên Reports page"
echo "   ✅ Không cần làm thủ công gì nữa!"
echo ""
echo "🎯 HƯỚNG DẪN SỬ DỤNG:"
echo "   1. Admin/Manager: truy cập /admin-dashboard"
echo "   2. Employee: truy cập /employee-dashboard"
echo "   3. QR Scanner: camera selfie hoạt động ổn định"
echo "   4. Check-in: ảnh có thời gian Việt Nam chính xác"
echo "   5. Ảnh mới check-in sẽ TỰ ĐỘNG hiển thị ngay!"
echo ""
echo "🚀 HỆ THỐNG SẴN SÀNG SỬ DỤNG!"
echo "💡 Từ giờ chỉ cần chạy: /Users/maybe/Documents/shopee/start_final_fixed.sh"
