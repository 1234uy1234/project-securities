#!/bin/bash

echo "🖨️ TẠO QR CODES MỚI ĐỂ IN"
echo "========================"

echo "1. Lấy danh sách QR codes mới..."
sqlite3 backend/app.db "SELECT id, content FROM qr_codes ORDER BY id DESC LIMIT 5;"

echo ""
echo "2. Tạo QR codes để in với nội dung đúng..."

# Tạo QR code cho "nhà đi chơi" (thay thế QR 6 cũ)
echo "Tạo QR code để in: nhà đi chơi"
curl -k -s -X POST "https://10.10.68.200:8000/api/qr-codes/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwNzU1NX0.MHoE-C0vqrGwdefflCRrQ6gkWAYLyMAJfokbGgF7fPE" \
  -H "Content-Type: application/json" \
  -d '{"content": "nhà đi chơi", "qr_type": "static", "location": "Vị trí nhà đi chơi"}' | jq -r '.message'

echo ""
echo "Tạo QR code để in: nhà xe"
curl -k -s -X POST "https://10.10.68.200:8000/api/qr-codes/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwNzU1NX0.MHoE-C0vqrGwdefflCRrQ6gkWAYLyMAJfokbGgF7fPE" \
  -H "Content-Type: application/json" \
  -d '{"content": "nhà xe", "qr_type": "static", "location": "Vị trí nhà xe"}' | jq -r '.message'

echo ""
echo "Tạo QR code để in: abcd"
curl -k -s -X POST "https://10.10.68.200:8000/api/qr-codes/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwNzU1NX0.MHoE-C0vqrGwdefflCRrQ6gkWAYLyMAJfokbGgF7fPE" \
  -H "Content-Type: application/json" \
  -d '{"content": "abcd", "qr_type": "static", "location": "Vị trí abcd"}' | jq -r '.message'

echo ""
echo "3. Kiểm tra QR codes cuối cùng..."
sqlite3 backend/app.db "SELECT id, content FROM qr_codes ORDER BY id DESC LIMIT 3;"

echo ""
echo "4. Hướng dẫn in QR codes:"
echo "   - Truy cập: https://10.10.68.200:5173/tasks"
echo "   - Chuyển sang tab 'QR Codes'"
echo "   - Tìm QR codes mới nhất (ID cao nhất)"
echo "   - Bấm 'Xem' để hiển thị QR code"
echo "   - In QR code đó ra giấy"

echo ""
echo "✅ Hoàn thành! QR codes mới đã sẵn sàng để in."
