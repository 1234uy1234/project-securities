#!/bin/bash

echo "🔧 SỬA LỖI ADMIN DASHBOARD KHÔNG HIỂN THỊ ẢNH VÀ TRẠNG THÁI"
echo "========================================================="
echo ""

echo "✅ Đã sửa các vấn đề sau:"
echo "1. Logic getLocationStatus: Ưu tiên kiểm tra patrol_records trước patrol_task_stops"
echo "2. Thêm thông tin ảnh vào step data từ checkin records"
echo "3. Cập nhật FlowStepProgress để hiển thị ảnh"
echo "4. Sửa logic xử lý task để không bị duplicate"
echo ""

echo "🔍 Kiểm tra dữ liệu hiện tại:"
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/app.db')
cursor = conn.cursor()

print('📋 Patrol Records (checkin data):')
cursor.execute('SELECT id, task_id, location_id, check_in_time, photo_path FROM patrol_records ORDER BY id DESC LIMIT 3')
rows = cursor.fetchall()
for row in rows:
    print(f'ID: {row[0]}, Task: {row[1]}, Location: {row[2]}, Time: {row[3]}, Photo: {row[4]}')

print()
print('📋 Patrol Task Stops (completion status):')
cursor.execute('SELECT id, task_id, location_id, completed, completed_at FROM patrol_task_stops ORDER BY id DESC LIMIT 3')
rows = cursor.fetchall()
for row in rows:
    print(f'ID: {row[0]}, Task: {row[1]}, Location: {row[2]}, Completed: {row[3]}, Completed_at: {row[4]}')

conn.close()
"

echo ""
echo "🧪 Test API endpoints:"
echo "Testing checkin records API:"
curl -k -s "https://localhost:8000/api/records/" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'✅ Records API: {len(data)} records found')
    if data:
        latest = data[0]
        print(f'   Latest: Task {latest.get(\"task_id\")}, Location {latest.get(\"location_id\")}, Photo: {latest.get(\"photo_url\")}')
except:
    print('❌ Records API: Failed or no data')
" 2>/dev/null || echo "❌ Backend chưa chạy"

echo ""
echo "🌐 Truy cập ứng dụng để test:"
echo "   Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
echo "   Reports: https://10.10.68.200:5173/reports"
echo ""

echo "📋 Những gì sẽ thấy trong Admin Dashboard:"
echo "   ✅ FlowStepProgress sẽ hiển thị trạng thái 'Đã chấm công' (màu xanh)"
echo "   ✅ Ảnh checkin sẽ hiển thị dưới mỗi step đã hoàn thành"
echo "   ✅ Thời gian chấm công sẽ hiển thị chính xác"
echo "   ✅ Không còn báo 'Chưa chấm công' khi đã có dữ liệu"
echo ""

echo "⚠️  Lưu ý:"
echo "   - Logic mới ưu tiên dữ liệu từ patrol_records (dữ liệu thực tế)"
echo "   - Fallback về patrol_task_stops nếu không có patrol_records"
echo "   - Ảnh sẽ hiển thị với kích thước nhỏ và có thể click để xem lớn"
echo "   - Cache busting được thêm vào URL ảnh để đảm bảo load mới"
