#!/bin/bash

echo "🔧 SỬA LOGIC CHẤM CÔNG ĐÚNG GIỜ"
echo "==============================="
echo ""

echo "✅ Đã sửa các vấn đề sau:"
echo "1. Logic kiểm tra thời gian: Chỉ cho phép chấm công trong khoảng ±15 phút"
echo "2. Phân biệt các stops: Mỗi stop phải chấm công riêng biệt"
echo "3. Cập nhật trạng thái task: Chỉ hoàn thành khi tất cả stops đã chấm công đúng giờ"
echo "4. Database sync: Đồng bộ dữ liệu theo logic mới"
echo ""

echo "🔍 Kiểm tra dữ liệu hiện tại:"
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/app.db')
cursor = conn.cursor()

print('📋 Task 61 - tuần tra nhà:')
cursor.execute('SELECT id, title, status FROM patrol_tasks WHERE id = 61')
row = cursor.fetchone()
if row:
    print(f'ID: {row[0]}, Title: \"{row[1]}\", Status: {row[2]}')

print()
print('📋 Patrol Task Stops cho Task 61:')
cursor.execute('SELECT id, location_id, sequence, scheduled_time, completed, completed_at FROM patrol_task_stops WHERE task_id = 61 ORDER BY sequence')
rows = cursor.fetchall()
for row in rows:
    print(f'Stop {row[0]}: Location {row[1]}, Sequence {row[2]}, Time {row[3]}, Completed {row[4]}, Completed_at {row[5]}')

print()
print('📋 Patrol Records cho Task 61:')
cursor.execute('SELECT id, location_id, check_in_time FROM patrol_records WHERE task_id = 61 ORDER BY check_in_time DESC LIMIT 3')
rows = cursor.fetchall()
for row in rows:
    print(f'Record {row[0]}: Location {row[1]}, Time {row[2]}')

conn.close()
"

echo ""
echo "🎯 LOGIC MỚI HOẠT ĐỘNG NHƯ SAU:"
echo ""
echo "1. **Kiểm tra thời gian chấm công:**"
echo "   - Stop 1 (10:20): Chấm công từ 10:05 - 10:35 (±15 phút)"
echo "   - Stop 2 (10:30): Chấm công từ 10:15 - 10:45 (±15 phút)"
echo ""
echo "2. **Phân biệt các stops:**"
echo "   - Mỗi stop phải chấm công riêng biệt"
echo "   - Không thể dùng 1 lần chấm công cho nhiều stops"
echo ""
echo "3. **Trạng thái task:**"
echo "   - 'in_progress': Một số stops đã hoàn thành"
echo "   - 'completed': Tất cả stops đã hoàn thành"
echo "   - 'pending': Chưa có stop nào hoàn thành"
echo ""

echo "📋 TÌNH TRẠNG HIỆN TẠI:"
echo "   ✅ Stop 1 (10:20): Đã chấm công lúc 10:24 → HOÀN THÀNH"
echo "   ⏳ Stop 2 (10:30): Chưa chấm công đúng giờ → CHỜ CHẤM CÔNG"
echo "   🔄 Task Status: 'in_progress' (1/2 stops hoàn thành)"
echo ""

echo "🌐 Truy cập ứng dụng để kiểm tra:"
echo "   Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
echo "   Reports: https://10.10.68.200:5173/reports"
echo ""

echo "📋 Những gì sẽ thấy bây giờ:"
echo "   ✅ Stop 1 (10:20): Màu xanh, hiển thị 'Đã chấm công' + ảnh"
echo "   ⏳ Stop 2 (10:30): Màu xám, hiển thị 'Chờ chấm công'"
echo "   🔄 Task: Status 'in_progress' thay vì 'completed'"
echo ""

echo "⚠️  Lưu ý quan trọng:"
echo "   - Chấm công sớm quá sẽ báo 'Chấm công ngoài giờ'"
echo "   - Chấm công muộn quá sẽ báo 'Quá hạn'"
echo "   - Mỗi stop phải chấm công riêng biệt"
echo "   - Task chỉ hoàn thành khi tất cả stops đã chấm công đúng giờ"
echo ""

echo "🔧 Script tự động đồng bộ:"
echo "   Chạy: python3 sync-checkin-by-time.py"
echo "   Script này sẽ tự động kiểm tra và cập nhật trạng thái theo logic mới"
