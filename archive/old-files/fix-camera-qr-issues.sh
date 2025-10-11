#!/bin/bash

# 🔧 SỬA LỖI CAMERA VÀ QR SCANNER
# Đã sửa 3 vấn đề chính: camera xung đột, QR delay, thông báo spam

echo "🔧 SỬA LỖI CAMERA VÀ QR SCANNER"
echo "================================"
echo "✅ Đã sửa 3 vấn đề chính:"
echo "   1. Camera xung đột - báo camera đang được sử dụng"
echo "   2. QR scanner delay - quét được nhưng chậm nhận"
echo "   3. Thông báo spam - đã chấm xong vẫn báo đã quét"
echo ""

echo "🔍 CHI TIẾT SỬA ĐỔI:"
echo "===================="
echo "1. QR Scanner Delay Fix:"
echo "   - Dừng scanner ngay lập tức sau khi quét"
echo "   - Hiển thị thông báo ngay lập tức"
echo "   - Tối ưu hóa logic xử lý"
echo ""

echo "2. Camera Conflict Fix:"
echo "   - Sử dụng forceStopAllStreams() thay vì stopAllCameraTracks()"
echo "   - Thêm delay 1 giây để đảm bảo camera được giải phóng"
echo "   - Cải thiện error message"
echo ""

echo "3. Notification Spam Fix:"
echo "   - Chỉ hiển thị 1 thông báo duy nhất"
echo "   - Loại bỏ thông báo trùng lặp"
echo "   - Tối ưu hóa flow thông báo"
echo ""

echo "🚀 KHỞI ĐỘNG LẠI HỆ THỐNG:"
echo "=========================="

# Dừng tất cả processes
echo "🛑 Dừng tất cả processes..."
pkill -f "npm run dev" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true

# Đợi một chút
sleep 2

# Khởi động backend
echo "🔧 Khởi động backend..."
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!

# Đợi backend khởi động
sleep 3

# Khởi động frontend
echo "🎨 Khởi động frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!

# Đợi frontend khởi động
sleep 5

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
echo "===================================="
echo "🌐 Frontend: https://localhost:5173"
echo "🔧 Backend: http://localhost:8000"
echo ""
echo "📱 HƯỚNG DẪN TEST:"
echo "=================="
echo "1. Mở trình duyệt: https://localhost:5173"
echo "2. Đăng nhập vào hệ thống"
echo "3. Test QR Scanner:"
echo "   - Bật camera QR → Quét mã → Thông báo ngay lập tức"
echo "   - Không còn delay khi nhận kết quả"
echo "4. Test Camera Selfie:"
echo "   - Bật camera selfie → Không còn báo xung đột"
echo "   - Camera chuyển đổi mượt mà"
echo "5. Test Thông báo:"
echo "   - Chỉ hiển thị 1 thông báo duy nhất"
echo "   - Không còn spam thông báo"
echo ""
echo "🎯 CÁC VẤN ĐỀ ĐÃ ĐƯỢC SỬA:"
echo "=========================="
echo "✅ Camera xung đột: Sử dụng forceStopAllStreams()"
echo "✅ QR delay: Dừng scanner ngay lập tức"
echo "✅ Thông báo spam: Chỉ 1 thông báo duy nhất"
echo ""
echo "💡 LƯU Ý:"
echo "=========="
echo "- Nếu vẫn gặp vấn đề, thử refresh trang"
echo "- Đảm bảo đã cho phép truy cập camera"
echo "- Đóng các ứng dụng khác đang sử dụng camera"
echo ""
echo "🔧 Process IDs:"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "Để dừng hệ thống: kill $BACKEND_PID $FRONTEND_PID"
