#!/bin/bash

echo "🔧 SỬA TẤT CẢ QR CODES CÓ VẤN ĐỀ"
echo "================================"

echo "1. Kiểm tra QR codes hiện tại..."
sqlite3 backend/app.db "SELECT id, content FROM qr_codes ORDER BY id;"

echo ""
echo "2. Xóa QR codes có nội dung sai..."
# Xóa QR codes có nội dung như "QR 5", "QR 6", etc.
sqlite3 backend/app.db "DELETE FROM qr_codes WHERE content LIKE 'QR %' OR content LIKE 'qr%';"

echo ""
echo "3. Tạo lại QR codes với nội dung đúng..."

# Tạo QR code cho các vị trí quan trọng
echo "Tạo QR code: nhà xe"
curl -k -s -X POST "https://10.10.68.200:8000/api/qr-codes/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwNzU1NX0.MHoE-C0vqrGwdefflCRrQ6gkWAYLyMAJfokbGgF7fPE" \
  -H "Content-Type: application/json" \
  -d '{"content": "nhà xe", "qr_type": "static", "location": ""}' | jq -r '.message'

echo "Tạo QR code: abcd"
curl -k -s -X POST "https://10.10.68.200:8000/api/qr-codes/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwNzU1NX0.MHoE-C0vqrGwdefflCRrQ6gkWAYLyMAJfokbGgF7fPE" \
  -H "Content-Type: application/json" \
  -d '{"content": "abcd", "qr_type": "static", "location": ""}' | jq -r '.message'

echo "Tạo QR code: test"
curl -k -s -X POST "https://10.10.68.200:8000/api/qr-codes/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwNzU1NX0.MHoE-C0vqrGwdefflCRrQ6gkWAYLyMAJfokbGgF7fPE" \
  -H "Content-Type: application/json" \
  -d '{"content": "test", "qr_type": "static", "location": ""}' | jq -r '.message'

echo ""
echo "4. Kiểm tra QR codes sau khi sửa..."
sqlite3 backend/app.db "SELECT id, content FROM qr_codes ORDER BY id;"

echo ""
echo "✅ Hoàn thành! QR codes đã được sửa."
echo "🌐 Truy cập frontend để xem QR codes mới: https://10.10.68.200:5173/tasks"
