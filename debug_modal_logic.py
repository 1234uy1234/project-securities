#!/usr/bin/env python3
"""
Script debug logic modal - kiểm tra tại sao modal hiển thị "Chưa chấm công"
"""

import sqlite3
import requests
import json

def debug_modal_logic():
    print("🔍 DEBUG MODAL LOGIC - KIỂM TRA TẠI SAO MODAL HIỂN THỊ 'CHƯA CHẤM CÔNG'")
    print("=" * 80)
    
    # 1. Kiểm tra dữ liệu database
    conn = sqlite3.connect('backend/app.db')
    cursor = conn.cursor()
    
    print("📋 1. Kiểm tra dữ liệu database:")
    print("-" * 40)
    
    # Tìm task "tuan tra" hoặc "tuần tra"
    cursor.execute("""
        SELECT pt.id, pt.title, pt.status, pts.id as stop_id, pts.location_id, pts.sequence, pts.scheduled_time, pts.completed, pts.completed_at
        FROM patrol_tasks pt
        LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id
        WHERE pt.title LIKE '%tuan tra%' OR pt.title LIKE '%tuần tra%'
        ORDER BY pt.id DESC
        LIMIT 5
    """)
    
    tasks = cursor.fetchall()
    print(f"Tìm thấy {len(tasks)} tasks:")
    for task in tasks:
        print(f"  Task {task[0]}: {task[1]} (status: {task[2]})")
        if task[4]:  # location_id
            print(f"    Stop {task[3]}: location {task[4]}, sequence {task[5]}, scheduled {task[6]}, completed {task[7]}")
    
    print()
    
    # Tìm checkin records cho các tasks này
    if tasks:
        task_ids = [str(task[0]) for task in tasks]
        cursor.execute(f"""
            SELECT pr.id, pr.task_id, pr.location_id, pr.check_in_time, pr.photo_path, pt.title
            FROM patrol_records pr
            LEFT JOIN patrol_tasks pt ON pr.task_id = pt.id
            WHERE pr.task_id IN ({','.join(task_ids)})
            ORDER BY pr.check_in_time DESC
        """)
        
        records = cursor.fetchall()
        print(f"Tìm thấy {len(records)} checkin records:")
        for record in records:
            print(f"  Record {record[0]}: Task {record[1]} ({record[5]}), Location {record[2]}, Time {record[3]}, Photo {record[4]}")
    
    conn.close()
    
    print()
    print("📋 2. Kiểm tra API response:")
    print("-" * 40)
    
    # 2. Kiểm tra API response
    try:
        # Thử gọi API (có thể cần token thật)
        response = requests.get("http://localhost:8000/api/checkin/admin/all-records", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"API trả về {len(data)} records")
            
            # Tìm records cho task "tuan tra"
            tuan_tra_records = [r for r in data if 'tuan tra' in r.get('task_title', '').lower() or 'tuần tra' in r.get('task_title', '').lower()]
            print(f"Tìm thấy {len(tuan_tra_records)} records cho task 'tuan tra':")
            for record in tuan_tra_records:
                print(f"  Record {record['id']}: Task {record['task_id']} ({record['task_title']}), Location {record['location_id']}, Time {record['check_in_time']}, Photo {record['photo_url']}")
        else:
            print(f"API trả về status code: {response.status_code}")
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Lỗi gọi API: {e}")
    
    print()
    print("🎯 3. Phân tích vấn đề:")
    print("-" * 40)
    print("Modal hiển thị 'Chưa chấm công' có nghĩa là:")
    print("1. record.check_in_time bị null hoặc rỗng")
    print("2. Logic handleStepClick không tìm thấy record")
    print("3. API không trả về đúng dữ liệu")
    print("4. Record bị null trong response")
    
    print()
    print("🔧 4. Hướng dẫn sửa:")
    print("-" * 40)
    print("1. Kiểm tra console logs trong browser (F12)")
    print("2. Xem logic handleStepClick có tìm thấy record không")
    print("3. Kiểm tra API response có đúng không")
    print("4. Đảm bảo record có check_in_time và photo_url")

if __name__ == "__main__":
    debug_modal_logic()
