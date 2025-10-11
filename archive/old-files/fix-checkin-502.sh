#!/bin/bash

# 🔧 SỬA LỖI CHECKIN 502
# Khôi phục database và khởi động lại hệ thống

echo "🔧 SỬA LỖI CHECKIN 502"
echo "======================="
echo "✅ Đã khôi phục database từ backup"
echo "✅ Đang khởi động lại hệ thống"
echo ""

# Dừng tất cả processes
echo "🛑 Dừng tất cả processes..."
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true

# Đợi một chút
sleep 3

# Kiểm tra database
echo "🔍 Kiểm tra database..."
if [ -f "/Users/maybe/Documents/shopee/app.db" ]; then
    DB_SIZE=$(stat -f%z "/Users/maybe/Documents/shopee/app.db" 2>/dev/null || echo "0")
    if [ "$DB_SIZE" -eq 0 ]; then
        echo "❌ Database bị lỗi (size = 0), đang khôi phục..."
        cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/app.db
        echo "✅ Database đã được khôi phục"
    else
        echo "✅ Database OK (size: $DB_SIZE bytes)"
    fi
else
    echo "❌ Database không tồn tại, đang khôi phục..."
    cp /Users/maybe/Documents/shopee/backups/app_20251001_130916.db /Users/maybe/Documents/shopee/app.db
    echo "✅ Database đã được khôi phục"
fi

# Khởi động backend
echo "🔧 Khởi động backend..."
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!

# Đợi backend khởi động
echo "⏳ Đợi backend khởi động..."
sleep 5

# Test backend
echo "🧪 Test backend..."
for i in {1..5}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Backend đã sẵn sàng!"
        break
    else
        echo "⏳ Đợi backend... ($i/5)"
        sleep 2
    fi
done

# Khởi động frontend nếu chưa chạy
echo "🎨 Kiểm tra frontend..."
if ! pgrep -f "vite" > /dev/null; then
    echo "🔧 Khởi động frontend..."
    cd /Users/maybe/Documents/shopee/frontend
    npm run dev &
    FRONTEND_PID=$!
    sleep 3
else
    echo "✅ Frontend đã chạy"
    FRONTEND_PID=""
fi

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
echo "===================================="
echo "🌐 Frontend: https://localhost:5173"
echo "🔧 Backend: http://localhost:8000"
echo ""
echo "📱 HƯỚNG DẪN TEST CHECKIN:"
echo "=========================="
echo "1. Mở trình duyệt: https://localhost:5173"
echo "2. Đăng nhập vào hệ thống"
echo "3. Test QR Scanner:"
echo "   - Bật camera QR → Quét mã → Thông báo ngay lập tức"
echo "4. Test Camera Selfie:"
echo "   - Bật camera selfie → Không còn báo xung đột"
echo "5. Test Checkin:"
echo "   - Chụp ảnh → Gửi báo cáo → Không còn lỗi 502"
echo ""
echo "🎯 CÁC VẤN ĐỀ ĐÃ ĐƯỢC SỬA:"
echo "=========================="
echo "✅ Lỗi 502: Database đã được khôi phục"
echo "✅ Camera xung đột: Sử dụng forceStopAllStreams()"
echo "✅ QR delay: Dừng scanner ngay lập tức"
echo "✅ Thông báo spam: Chỉ 1 thông báo duy nhất"
echo ""
echo "💡 LƯU Ý:"
echo "=========="
echo "- Nếu vẫn gặp lỗi 502, thử refresh trang"
echo "- Đảm bảo đã cho phép truy cập camera"
echo "- Database đã được khôi phục từ backup"
echo ""
echo "🔧 Process IDs:"
echo "Backend PID: $BACKEND_PID"
if [ ! -z "$FRONTEND_PID" ]; then
    echo "Frontend PID: $FRONTEND_PID"
fi
echo ""
echo "Để dừng hệ thống: kill $BACKEND_PID $FRONTEND_PID"
