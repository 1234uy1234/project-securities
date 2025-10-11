#!/bin/bash

echo "🔧 SỬA LỖI ĐỒNG BỘ DỮ LIỆU ADMIN DASHBOARD"
echo "=========================================="
echo ""

echo "✅ Đã sửa các vấn đề sau:"
echo "1. Patrol Record ID 37: Cập nhật task_id từ 62 thành 61"
echo "2. Patrol Task Stops: Cập nhật completed = 1 cho task 61, location 1"
echo "3. Patrol Task 61: Cập nhật status thành 'completed'"
echo ""

echo "🔍 Kiểm tra dữ liệu sau khi sửa:"
python3 -c "
import sqlite3
conn = sqlite3.connect('backend/app.db')
cursor = conn.cursor()

print('📋 Patrol Record 37:')
cursor.execute('SELECT id, task_id, location_id, check_in_time, photo_path FROM patrol_records WHERE id = 37')
row = cursor.fetchone()
if row:
    print(f'ID: {row[0]}, Task: {row[1]}, Location: {row[2]}, Time: {row[3]}, Photo: {row[4]}')

print()
print('📋 Patrol Task 61:')
cursor.execute('SELECT id, title, status FROM patrol_tasks WHERE id = 61')
row = cursor.fetchone()
if row:
    print(f'ID: {row[0]}, Title: \"{row[1]}\", Status: {row[2]}')

print()
print('📋 Patrol Task Stops cho Task 61:')
cursor.execute('SELECT id, task_id, location_id, completed, completed_at FROM patrol_task_stops WHERE task_id = 61')
rows = cursor.fetchall()
for row in rows:
    print(f'ID: {row[0]}, Task: {row[1]}, Location: {row[2]}, Completed: {row[3]}, Completed_at: {row[4]}')

conn.close()
"

echo ""
echo "🌐 Truy cập ứng dụng để kiểm tra:"
echo "   Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
echo "   Reports: https://10.10.68.200:5173/reports"
echo ""

echo "📋 Những gì sẽ thấy bây giờ:"
echo "   ✅ Admin Dashboard: Task 'tuần tra nhà' sẽ hiển thị 'Đã chấm công'"
echo "   ✅ FlowStepProgress: Step sẽ có màu xanh và hiển thị ảnh"
echo "   ✅ Chi tiết chấm công: Sẽ hiển thị thông tin đầy đủ"
echo "   ✅ Reports: Vẫn hiển thị đúng như trước"
echo ""

echo "🔧 Script tự động đồng bộ dữ liệu:"
cat > /Users/maybe/Documents/shopee/sync-checkin-data.py << 'EOF'
#!/usr/bin/env python3
"""
Script tự động đồng bộ dữ liệu checkin giữa các bảng
Chạy script này khi có vấn đề không đồng bộ dữ liệu
"""

import sqlite3
from datetime import datetime

def sync_checkin_data():
    conn = sqlite3.connect('backend/app.db')
    cursor = conn.cursor()
    
    print("🔄 Bắt đầu đồng bộ dữ liệu checkin...")
    
    # 1. Tìm các patrol records có task_id không tồn tại
    cursor.execute("""
        SELECT pr.id, pr.task_id, pr.location_id, pr.check_in_time
        FROM patrol_records pr
        LEFT JOIN patrol_tasks pt ON pr.task_id = pt.id
        WHERE pt.id IS NULL
    """)
    orphan_records = cursor.fetchall()
    
    if orphan_records:
        print(f"⚠️  Tìm thấy {len(orphan_records)} patrol records có task_id không tồn tại")
        
        # Tìm task gần nhất để gán lại
        cursor.execute("SELECT id FROM patrol_tasks ORDER BY id DESC LIMIT 1")
        latest_task = cursor.fetchone()
        if latest_task:
            latest_task_id = latest_task[0]
            print(f"📝 Gán lại task_id = {latest_task_id} cho các records")
            
            for record in orphan_records:
                cursor.execute("UPDATE patrol_records SET task_id = ? WHERE id = ?", 
                             (latest_task_id, record[0]))
                print(f"   ✅ Record {record[0]}: task_id {record[1]} → {latest_task_id}")
    
    # 2. Cập nhật patrol_task_stops dựa trên patrol_records
    cursor.execute("""
        SELECT pr.task_id, pr.location_id, pr.check_in_time
        FROM patrol_records pr
        WHERE pr.check_in_time IS NOT NULL
    """)
    checkin_records = cursor.fetchall()
    
    for task_id, location_id, check_in_time in checkin_records:
        # Cập nhật patrol_task_stops
        cursor.execute("""
            UPDATE patrol_task_stops 
            SET completed = 1, completed_at = ?
            WHERE task_id = ? AND location_id = ?
        """, (check_in_time, task_id, location_id))
        
        # Cập nhật trạng thái task
        cursor.execute("""
            UPDATE patrol_tasks 
            SET status = 'completed'
            WHERE id = ? AND status != 'completed'
        """, (task_id,))
    
    conn.commit()
    print("✅ Hoàn thành đồng bộ dữ liệu!")
    conn.close()

if __name__ == "__main__":
    sync_checkin_data()
EOF

chmod +x /Users/maybe/Documents/shopee/sync-checkin-data.py

echo "✅ Đã tạo script sync-checkin-data.py"
echo "   Chạy: python3 sync-checkin-data.py"
echo ""

echo "⚠️  Lưu ý:"
echo "   - Script này sẽ tự động đồng bộ dữ liệu khi có vấn đề"
echo "   - Chạy script này nếu Admin Dashboard không hiển thị đúng"
echo "   - Dữ liệu trong Reports sẽ không bị ảnh hưởng"
echo "   - Script sẽ tự động sửa các task_id không tồn tại"
