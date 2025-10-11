#!/usr/bin/env python3
"""
Script sửa lỗi logic task "bjsucd" - gán đúng task_id cho checkin records
"""

import sqlite3
from datetime import datetime

def fix_bjsucd_task_logic():
    conn = sqlite3.connect('backend/app.db')
    cursor = conn.cursor()
    
    print("🔧 SỬA LỖI LOGIC TASK 'bjsucd'")
    print("================================")
    
    # 1. Kiểm tra task "bjsucd"
    cursor.execute("SELECT * FROM patrol_tasks WHERE title LIKE '%bjsucd%'")
    bjsucd_task = cursor.fetchone()
    
    if not bjsucd_task:
        print("❌ Không tìm thấy task 'bjsucd'")
        return
    
    task_id, title, description, location_id, assigned_to, status, created_at = bjsucd_task
    print(f"✅ Tìm thấy task 'bjsucd': ID={task_id}, Status={status}, Created={created_at}")
    
    # 2. Tìm checkin records được tạo sau khi task "bjsucd" được tạo
    cursor.execute("""
        SELECT id, task_id, location_id, check_in_time, photo_path
        FROM patrol_records 
        WHERE check_in_time >= ? AND photo_path IS NOT NULL AND photo_path != ''
        ORDER BY check_in_time ASC
    """, (created_at,))
    
    records = cursor.fetchall()
    print(f"\n📋 Tìm thấy {len(records)} checkin records sau khi task 'bjsucd' được tạo:")
    
    for record in records:
        record_id, current_task_id, record_location_id, checkin_time, photo_path = record
        print(f"   Record {record_id}: Task {current_task_id}, Location {record_location_id}, Time {checkin_time}")
    
    # 3. Tìm checkin record phù hợp nhất với task "bjsucd"
    # Ưu tiên record có location_id giống với task và thời gian gần nhất
    suitable_records = []
    for record in records:
        record_id, current_task_id, record_location_id, checkin_time, photo_path = record
        
        # Kiểm tra location_id có khớp không
        if record_location_id == location_id:
            suitable_records.append(record)
    
    if not suitable_records:
        print("\n⚠️ Không tìm thấy checkin record phù hợp với location_id của task 'bjsucd'")
        print("   Có thể cần kiểm tra logic tạo task hoặc checkin")
        return
    
    # 4. Chọn record phù hợp nhất (gần nhất với thời gian tạo task)
    best_record = suitable_records[0]  # Lấy record đầu tiên (gần nhất)
    record_id, current_task_id, record_location_id, checkin_time, photo_path = best_record
    
    print(f"\n🎯 Chọn record {record_id} để gán cho task 'bjsucd':")
    print(f"   - Thời gian checkin: {checkin_time}")
    print(f"   - Ảnh: {photo_path}")
    print(f"   - Location: {record_location_id}")
    
    # 5. Cập nhật task_id cho record
    cursor.execute("""
        UPDATE patrol_records 
        SET task_id = ? 
        WHERE id = ?
    """, (task_id, record_id))
    
    # 6. Cập nhật trạng thái task
    cursor.execute("""
        UPDATE patrol_tasks 
        SET status = 'completed' 
        WHERE id = ?
    """, (task_id,))
    
    # 7. Cập nhật trạng thái stop
    cursor.execute("""
        UPDATE patrol_task_stops 
        SET completed = 1, completed_at = ? 
        WHERE task_id = ?
    """, (checkin_time, task_id))
    
    conn.commit()
    
    print(f"\n✅ Đã sửa xong:")
    print(f"   - Gán record {record_id} cho task 'bjsucd' (ID: {task_id})")
    print(f"   - Cập nhật status task thành 'completed'")
    print(f"   - Cập nhật stop thành completed")
    
    # 8. Kiểm tra kết quả
    cursor.execute("""
        SELECT pr.id, pr.task_id, pr.check_in_time, pr.photo_path, pt.title
        FROM patrol_records pr
        LEFT JOIN patrol_tasks pt ON pr.task_id = pt.id
        WHERE pr.id = ?
    """, (record_id,))
    
    result = cursor.fetchone()
    if result:
        print(f"\n🔍 Kết quả sau khi sửa:")
        print(f"   Record {result[0]}: Task {result[1]} ({result[4]}), Time {result[2]}, Photo {result[3]}")
    
    conn.close()
    print("\n🎉 Hoàn thành!")

if __name__ == "__main__":
    fix_bjsucd_task_logic()
