#!/bin/bash

# 🚀 KHỞI ĐỘNG HỆ THỐNG CHO TRUY CẬP MẠNG
# Cho phép truy cập từ điện thoại, máy khác

echo "🚀 KHỞI ĐỘNG HỆ THỐNG CHO TRUY CẬP MẠNG"
echo "======================================="

# 1. Lấy IP hiện tại
IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
echo "📍 IP hiện tại: $IP"

# 2. Dừng các process cũ
echo "🛑 Dừng các process cũ..."
pkill -f uvicorn
pkill -f vite
pkill -f "npm run dev"
sleep 2

# 3. Cập nhật config frontend
echo "⚙️ Cập nhật config frontend..."
cat > frontend/src/utils/config.ts << EOF
/**
 * Utility functions để lấy cấu hình URL
 */

// NUCLEAR HTTPS - KHÔNG DÙNG BIẾN MÔI TRƯỜNG
const NUCLEAR_HTTPS_URL = 'http://$IP:8000'

export const getBaseUrl = () => {
  return NUCLEAR_HTTPS_URL
}

// Lấy URL cho ảnh uploads
export const getImageUrl = (imagePath: string) => {
  const baseUrl = getBaseUrl()
  
  if (!imagePath) {
    return ''
  }
  
  // Nếu đã có http/https thì dùng luôn
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath
  }
  
  // Nếu bắt đầu với /uploads/ thì chỉ cần thêm baseUrl
  if (imagePath.startsWith('/uploads/')) {
    return \`\${baseUrl}\${imagePath}\`
  }
  
  // Nếu chỉ có tên file thì thêm /uploads/
  return \`\${baseUrl}/uploads/\${imagePath}\`
}

// Lấy URL cho QR code
export const getQRCodeUrl = (qrCodeId: number) => {
  const baseUrl = getBaseUrl()
  return \`\${baseUrl}/api/qr-codes/\${qrCodeId}/image\`
}
EOF

echo "   ✅ Config đã cập nhật: http://$IP:8000"

# 4. Khởi động backend
echo "🔧 Khởi động backend..."
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo "   ✅ Backend PID: $BACKEND_PID"

# 5. Đợi backend khởi động
echo "⏳ Đợi backend khởi động..."
sleep 5

# 6. Test backend
echo "🧪 Test backend..."
if curl -s -o /dev/null -w "%{http_code}" http://$IP:8000/docs | grep -q "200"; then
    echo "   ✅ Backend hoạt động: http://$IP:8000"
else
    echo "   ❌ Backend không hoạt động!"
    exit 1
fi

# 7. Khởi động frontend
echo "🎨 Khởi động frontend..."
cd frontend
npm run dev -- --host 0.0.0.0 --port 3000 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo "   ✅ Frontend PID: $FRONTEND_PID"

# 8. Đợi frontend khởi động
echo "⏳ Đợi frontend khởi động..."
sleep 10

# 9. Test frontend
echo "🧪 Test frontend..."
if curl -s -o /dev/null -w "%{http_code}" http://$IP:3000 | grep -q "200"; then
    echo "   ✅ Frontend hoạt động: http://$IP:3000"
else
    echo "   ⚠️ Frontend có thể chưa sẵn sàng, đợi thêm..."
    sleep 5
    if curl -s -o /dev/null -w "%{http_code}" http://$IP:3000 | grep -q "200"; then
        echo "   ✅ Frontend hoạt động: http://$IP:3000"
    else
        echo "   ❌ Frontend không hoạt động!"
    fi
fi

# 10. Tạo file thông tin
cat > system-info.txt << EOF
🚀 HỆ THỐNG ĐÃ KHỞI ĐỘNG
========================

📍 IP: $IP
🔧 Backend: http://$IP:8000
🎨 Frontend: http://$IP:3000
📸 Ảnh: http://$IP:8000/uploads/
🔗 QR Code: http://$IP:8000/api/qr-codes/{id}/image

📱 TRUY CẬP TỪ THIẾT BỊ KHÁC:
============================
- Điện thoại: http://$IP:3000
- Máy khác: http://$IP:3000
- QR Scanner: http://$IP:3000/qr-scan
- Reports: http://$IP:3000/reports
- Admin: http://$IP:3000/admin-dashboard
- Employee: http://$IP:3000/employee-dashboard

🛑 DỪNG HỆ THỐNG:
================
./stop-system.sh

📊 LOGS:
========
- Backend: tail -f backend.log
- Frontend: tail -f frontend.log

⏰ Thời gian khởi động: $(date)
EOF

echo ""
echo "🎉 HỆ THỐNG ĐÃ KHỞI ĐỘNG!"
echo "========================="
echo "📍 IP: $IP"
echo "🔧 Backend: http://$IP:8000"
echo "🎨 Frontend: http://$IP:3000"
echo ""
echo "📱 TRUY CẬP TỪ THIẾT BỊ KHÁC:"
echo "============================="
echo "• Điện thoại: http://$IP:3000"
echo "• Máy khác: http://$IP:3000"
echo "• QR Scanner: http://$IP:3000/qr-scan"
echo "• Reports: http://$IP:3000/reports"
echo ""
echo "📊 Thông tin chi tiết: cat system-info.txt"
echo "🛑 Dừng hệ thống: ./stop-system.sh"
