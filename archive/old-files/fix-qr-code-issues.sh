#!/bin/bash

echo "🔧 SỬA LỖI QR CODE IN VÀ QUÉT"
echo "============================="
echo ""

echo "✅ Đã sửa các vấn đề sau:"
echo "1. Interface QRCode: Sửa từ 'data' và 'qr_content' thành 'content'"
echo "2. TasksPage.tsx: Sửa tất cả references từ qrCode.data/qrCode.qr_content thành qrCode.content"
echo "3. QRScannerPage.tsx: Sửa tất cả references từ qrData.data thành qrData.content"
echo "4. printQR function: Sửa để sử dụng qrCode.content thay vì qrCode.data"
echo ""

echo "🔍 Kiểm tra QR codes trong database:"
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/app.db')
cursor = conn.cursor()
cursor.execute('SELECT id, content FROM qr_codes ORDER BY id DESC LIMIT 5')
rows = cursor.fetchall()
print('📋 QR Codes hiện có:')
for row in rows:
    print(f'ID: {row[0]}, Content: \"{row[1]}\"')
conn.close()
"
echo ""

echo "🧪 Test QR code validation:"
echo "Testing QR 'nhà đi chơi':"
curl -k -s "https://localhost:8000/api/qr-codes/validate/nhà%20đi%20chơi" | python3 -m json.tool 2>/dev/null || echo "Backend chưa chạy"
echo ""

echo "🌐 Truy cập ứng dụng để test:"
echo "   Frontend: https://10.10.68.200:5173"
echo "   QR Scanner: https://10.10.68.200:5173/qr-scanner"
echo ""

echo "📋 Các QR codes để test:"
echo "   - nhà đi chơi (ID: 14)"
echo "   - nhà xe (ID: 15)" 
echo "   - alo (ID: 17)"
echo ""

echo "⚠️  Lưu ý:"
echo "   - QR codes giờ sẽ hiển thị đúng tên khi in"
echo "   - QR codes sẽ quét được bình thường"
echo "   - Không còn báo 'QR code không hợp lệ'"
echo "   - Nội dung QR code sẽ là tên thật thay vì 'QR 10', 'QR 11'"
