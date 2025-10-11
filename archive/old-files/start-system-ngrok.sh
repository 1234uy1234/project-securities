#!/bin/bash

# 🌐 KHỞI ĐỘNG HỆ THỐNG VỚI NGROK
# Cho phép truy cập từ mọi nơi (4G, WiFi khác, v.v.)

echo "🌐 KHỞI ĐỘNG HỆ THỐNG VỚI NGROK"
echo "================================"

# 1. Dừng các process cũ
echo "🛑 Dừng các process cũ..."
pkill -f uvicorn
pkill -f vite
pkill -f "npm run dev"
pkill -f ngrok
sleep 2

# 2. Khởi động backend
echo "🔧 Khởi động backend..."
cd backend
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo "   ✅ Backend PID: $BACKEND_PID"

# 3. Đợi backend khởi động
echo "⏳ Đợi backend khởi động..."
sleep 5

# 4. Test backend
echo "🧪 Test backend..."
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000/docs | grep -q "200"; then
    echo "   ✅ Backend hoạt động: http://127.0.0.1:8000"
else
    echo "   ❌ Backend không hoạt động!"
    exit 1
fi

# 5. Khởi động ngrok
echo "🌐 Khởi động ngrok..."
ngrok http 127.0.0.1:8000 --log=stdout > ngrok.log 2>&1 &
NGROK_PID=$!
echo "   ✅ Ngrok PID: $NGROK_PID"

# 6. Đợi ngrok khởi động
echo "⏳ Đợi ngrok khởi động..."
sleep 8

# 7. Lấy ngrok URL
echo "🔗 Lấy ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['tunnels'][0]['public_url'] if data['tunnels'] else 'No tunnels')")
echo "   ✅ Ngrok URL: $NGROK_URL"

# 8. Cập nhật config frontend
echo "⚙️ Cập nhật config frontend..."
cat > frontend/src/utils/config.ts << EOF
/**
 * Utility functions để lấy cấu hình URL
 */

// NUCLEAR HTTPS - KHÔNG DÙNG BIẾN MÔI TRƯỜNG
const NUCLEAR_HTTPS_URL = '$NGROK_URL'

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
  if imagePath.startsWith('/uploads/')) {
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

echo "   ✅ Config đã cập nhật: $NGROK_URL"

# 9. Test ngrok
echo "🧪 Test ngrok..."
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/docs | grep -q "200"; then
    echo "   ✅ Ngrok hoạt động"
else
    echo "   ❌ Ngrok không hoạt động!"
fi

# 10. Khởi động frontend
echo "🎨 Khởi động frontend..."
cd frontend
npm run dev -- --host 0.0.0.0 --port 3000 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo "   ✅ Frontend PID: $FRONTEND_PID"

# 11. Đợi frontend khởi động
echo "⏳ Đợi frontend khởi động..."
sleep 10

# 12. Test frontend
echo "🧪 Test frontend..."
if curl -k -s -o /dev/null -w "%{http_code}" https://10.10.68.200:3000 | grep -q "200"; then
    echo "   ✅ Frontend hoạt động: https://10.10.68.200:3000"
else
    echo "   ⚠️ Frontend có thể chưa sẵn sàng"
fi

# 13. Tạo file thông tin
cat > system-info-ngrok.txt << EOF
🌐 HỆ THỐNG NGROK ĐÃ KHỞI ĐỘNG
==============================

🔗 Ngrok URL: $NGROK_URL
🔧 Backend: $NGROK_URL
🎨 Frontend: https://10.10.68.200:3000
📸 Ảnh: $NGROK_URL/uploads/
🔗 QR Code: $NGROK_URL/api/qr-codes/{id}/image

📱 TRUY CẬP TỪ MỌI NƠI:
======================
- 4G: https://10.10.68.200:3000
- WiFi khác: https://10.10.68.200:3000
- QR Scanner: https://10.10.68.200:3000/qr-scan
- Reports: https://10.10.68.200:3000/reports
- Admin: https://10.10.68.200:3000/admin-dashboard
- Employee: https://10.10.68.200:3000/employee-dashboard

🌐 NGROK BACKEND:
================
- API: $NGROK_URL/api/
- Ảnh: $NGROK_URL/uploads/
- Docs: $NGROK_URL/docs

🛑 DỪNG HỆ THỐNG:
================
./stop-system.sh

📊 LOGS:
========
- Backend: tail -f backend.log
- Frontend: tail -f frontend.log
- Ngrok: tail -f ngrok.log

⏰ Thời gian khởi động: $(date)
EOF

echo ""
echo "🎉 HỆ THỐNG NGROK ĐÃ KHỞI ĐỘNG!"
echo "==============================="
echo "🔗 Ngrok URL: $NGROK_URL"
echo "🎨 Frontend: https://10.10.68.200:3000"
echo ""
echo "📱 TRUY CẬP TỪ MỌI NƠI:"
echo "======================="
echo "• 4G: https://10.10.68.200:3000"
echo "• WiFi khác: https://10.10.68.200:3000"
echo "• QR Scanner: https://10.10.68.200:3000/qr-scan"
echo "• Reports: https://10.10.68.200:3000/reports"
echo ""
echo "🌐 NGROK BACKEND:"
echo "================="
echo "• API: $NGROK_URL/api/"
echo "• Ảnh: $NGROK_URL/uploads/"
echo "• Docs: $NGROK_URL/docs"
echo ""
echo "📊 Thông tin chi tiết: cat system-info-ngrok.txt"
echo "🛑 Dừng hệ thống: ./stop-system.sh"
