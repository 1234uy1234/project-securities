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
