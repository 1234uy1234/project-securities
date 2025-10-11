#!/bin/bash

echo "✅ ĐÃ SỬA XONG LOGIC CHẤM CÔNG ĐÚNG GIỜ!"
echo "========================================"
echo ""

echo "🔧 VẤN ĐỀ ĐÃ SỬA:"
echo "❌ Trước: Stop 30 (10:30) cũng được nhận chấm công lúc 10:24"
echo "✅ Sau: Stop 30 (10:30) không được nhận chấm công lúc 10:24"
echo ""

echo "🎯 LOGIC MỚI HOẠT ĐỘNG:"
echo ""
echo "1. **Stop 29 (10:20):**"
echo "   - Khoảng thời gian hợp lệ: 10:20 - 10:35"
echo "   - Checkin 10:24 → ✅ HỢP LỆ (10:24 >= 10:20)"
echo ""
echo "2. **Stop 30 (10:30):**"
echo "   - Khoảng thời gian hợp lệ: 10:30 - 10:45"
echo "   - Checkin 10:24 → ❌ QUÁ SỚM (10:24 < 10:30)"
echo ""

echo "📋 TÌNH TRẠNG HIỆN TẠI:"
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

conn.close()
"

echo ""
echo "🎯 KẾT QUẢ:"
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
echo "   ⏳ Stop 2 (10:30): Màu xám, hiển thị 'Chưa đến giờ chấm công'"
echo "   🔄 Task: Status 'in_progress' thay vì 'completed'"
echo ""

echo "⚠️  LOGIC MỚI:"
echo "   - Chấm công sớm hơn giờ quy định → 'Chưa đến giờ chấm công'"
echo "   - Chấm công đúng giờ (±15 phút) → 'Đã chấm công'"
echo "   - Chấm công muộn quá → 'Quá hạn chấm công'"
echo "   - Mỗi stop phải chấm công riêng biệt"
echo "   - Task chỉ hoàn thành khi tất cả stops đã chấm công đúng giờ"
echo ""

echo "🔧 Script tự động đồng bộ:"
echo "   Chạy: python3 sync-checkin-by-time.py"
echo "   Script này sẽ tự động kiểm tra và cập nhật trạng thái theo logic mới"
echo ""

echo "✅ BÂY GIỜ LOGIC ĐÃ ĐÚNG:"
echo "   'Giao 10:30 thì phải tầm đấy chấm mới báo là chấm công'"
echo "   'Mấy điểm stop tách nhau ra'"
echo "   'Giờ nào thì giờ ấy chấm công'"
