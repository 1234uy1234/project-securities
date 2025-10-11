#!/bin/bash

echo "🚀 Khởi động hệ thống hoàn chỉnh với thời gian và ảnh đã được sửa..."

# Đường dẫn đến thư mục dự án
PROJECT_ROOT="/Users/maybe/Documents/shopee"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"

# 1. Sửa tất cả ảnh cũ
echo "🔧 Step 1: Sửa tất cả ảnh cũ..."
"$PROJECT_ROOT/fix_all_photos.sh"

# 2. Sửa thời gian trong database
echo "🔧 Step 2: Sửa thời gian trong database..."
cd "$BACKEND_DIR" && python3 -c "
from app.database import get_db
from app.models import PatrolRecord
from datetime import timezone, timedelta

db = next(get_db())
records = db.query(PatrolRecord).filter(PatrolRecord.check_in_time.isnot(None)).all()

print(f'🔍 Sửa thời gian cho {len(records)} records...')

for record in records:
    if record.check_in_time.tzinfo is None:
        vietnam_tz = timezone(timedelta(hours=7))
        record.check_in_time = record.check_in_time.replace(tzinfo=vietnam_tz)

db.commit()
print('✅ Đã sửa xong thời gian trong database!')
"

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
echo "✅ ĐÃ SỬA XONG TẤT CẢ:"
echo "   - Ảnh checkin tự động hiển thị"
echo "   - Thời gian hiển thị đúng giờ Việt Nam"
echo "   - Không cần chạy script thủ công nữa!"
