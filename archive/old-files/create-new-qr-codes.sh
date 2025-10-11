#!/bin/bash

echo "🎯 TẠO QR CODES MỚI VỚI TÊN ĐÚNG"
echo "================================="
echo ""

echo "📋 QR codes hiện có trong database:"
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/app.db')
cursor = conn.cursor()
cursor.execute('SELECT id, content FROM qr_codes ORDER BY id DESC LIMIT 10')
rows = cursor.fetchall()
for row in rows:
    print(f'ID: {row[0]}, Content: \"{row[1]}\"')
conn.close()
"
echo ""

echo "🔧 Tạo QR codes mới với tên đúng:"
echo ""

# Tạo QR code mới với tên đúng
python3 -c "
import sqlite3
import datetime

conn = sqlite3.connect('backend/app.db')
cursor = conn.cursor()

# Danh sách QR codes mới cần tạo
new_qr_codes = [
    'văn phòng',
    'kho hàng', 
    'bãi xe',
    'cổng chính',
    'sân sau'
]

for qr_content in new_qr_codes:
    try:
        # Kiểm tra xem QR code đã tồn tại chưa
        cursor.execute('SELECT id FROM qr_codes WHERE content = ?', (qr_content,))
        existing = cursor.fetchone()
        
        if existing:
            print(f'⚠️  QR code \"{qr_content}\" đã tồn tại (ID: {existing[0]})')
        else:
            # Tạo QR code mới
            cursor.execute('''
                INSERT INTO qr_codes (content, qr_type, location, created_at, created_by, is_active)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (qr_content, 'static', qr_content, datetime.datetime.now(), 'admin', True))
            
            qr_id = cursor.lastrowid
            print(f'✅ Đã tạo QR code mới: \"{qr_content}\" (ID: {qr_id})')
            
    except Exception as e:
        print(f'❌ Lỗi tạo QR code \"{qr_content}\": {e}')

conn.commit()
conn.close()
"

echo ""
echo "📋 QR codes sau khi tạo:"
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/app.db')
cursor = conn.cursor()
cursor.execute('SELECT id, content FROM qr_codes ORDER BY id DESC LIMIT 10')
rows = cursor.fetchall()
for row in rows:
    print(f'ID: {row[0]}, Content: \"{row[1]}\"')
conn.close()
"

echo ""
echo "🌐 Truy cập ứng dụng để in QR codes mới:"
echo "   Frontend: https://10.10.68.200:5173/tasks"
echo "   Tab: QR Codes"
echo ""

echo "✅ Hướng dẫn in QR codes:"
echo "1. Truy cập trang Tasks"
echo "2. Chuyển sang tab 'QR Codes'"
echo "3. Tìm QR codes mới (ID cao nhất)"
echo "4. Bấm 'Xem' để xem QR code"
echo "5. Bấm 'In' để in QR code"
echo "6. QR code in ra sẽ có tên đúng thay vì 'QR 10', 'QR 11'"
