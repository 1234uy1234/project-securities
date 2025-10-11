#!/bin/bash

echo "🌅 Khởi động ứng dụng hàng ngày - Tự động cập nhật IP"
echo ""

# Dừng tất cả process cũ
echo "🛑 Dừng các process cũ..."
pkill -f "python app.py" 2>/dev/null
pkill -f "npm run dev" 2>/dev/null
sleep 2

# Cập nhật IP tự động
echo "🔄 Cập nhật IP configuration..."
./auto-update-ip.sh

# Lấy IP mới
NEW_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
echo "📍 IP mới: $NEW_IP"

# Khởi động backend với HTTPS
echo "🔧 Khởi động Backend với HTTPS..."
cd backend
python -m uvicorn app.main:app --host $NEW_IP --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt &
BACKEND_PID=$!

# Đợi backend khởi động
echo "⏳ Đợi backend khởi động..."
sleep 5

# Khởi động frontend
echo "🔧 Khởi động Frontend..."
cd ../frontend
VITE_API_BASE_URL=https://$NEW_IP:8000 npm run dev -- --host 0.0.0.0 --port 5173 --https &
FRONTEND_PID=$!

# Đợi frontend khởi động
sleep 3

echo ""
echo "✅ Ứng dụng đã khởi động thành công!"
echo ""
echo "🌐 Truy cập ứng dụng:"
echo "   https://$NEW_IP:5173"
echo ""
echo "🔑 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📱 Hướng dẫn cho người dùng:"
echo "   1. Mở trình duyệt và vào link trên"
echo "   2. Nếu gặp cảnh báo SSL, bấm 'Nâng cao' → 'Tiếp tục truy cập'"
echo "   3. Đăng nhập với thông tin trên"
echo ""
echo "🛑 Để dừng ứng dụng: Ctrl+C"

# Lưu IP vào file để dễ kiểm tra
echo "$NEW_IP" > current_ip.txt
echo "💾 IP đã được lưu vào current_ip.txt"

# Chờ người dùng dừng
wait
