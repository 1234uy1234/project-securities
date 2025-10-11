#!/usr/bin/env python3
"""
Script sửa hẳn logic chấm công để sau này tạo nhiệm vụ mới không gặp vấn đề
"""

import sqlite3
from datetime import datetime

def fix_checkin_logic_permanently():
    conn = sqlite3.connect('backend/app.db')
    cursor = conn.cursor()
    
    print("🔧 SỬA HẲN LOGIC CHẤM CÔNG ĐỂ TRÁNH VẤN ĐỀ SAU NÀY")
    print("=" * 60)
    
    # 1. Kiểm tra và sửa tất cả tasks có nhiều stops với cùng location_id
    print("\n1. 🔍 Kiểm tra tasks có vấn đề:")
    cursor.execute("""
        SELECT task_id, location_id, COUNT(*) as stop_count
        FROM patrol_task_stops 
        GROUP BY task_id, location_id
        HAVING COUNT(*) > 1
        ORDER BY task_id, location_id
    """)
    
    problematic_tasks = cursor.fetchall()
    
    if problematic_tasks:
        print(f"   ❌ Tìm thấy {len(problematic_tasks)} tasks có vấn đề:")
        for task_id, location_id, count in problematic_tasks:
            print(f"      Task {task_id}, Location {location_id}: {count} stops")
    else:
        print("   ✅ Không có tasks nào có vấn đề")
    
    # 2. Sửa logic đồng bộ dữ liệu
    print("\n2. 🔧 Sửa logic đồng bộ dữ liệu:")
    
    # Lấy tất cả patrol task stops
    cursor.execute("""
        SELECT pts.id, pts.task_id, pts.location_id, pts.sequence, pts.scheduled_time, pts.completed
        FROM patrol_task_stops pts
        WHERE pts.scheduled_time IS NOT NULL AND pts.scheduled_time != 'Chưa xác định'
        ORDER BY pts.task_id, pts.sequence
    """)
    stops = cursor.fetchall()
    
    print(f"   📋 Kiểm tra {len(stops)} stops...")
    
    for stop_id, task_id, location_id, sequence, scheduled_time, current_completed in stops:
        print(f"\n   🔍 Stop {stop_id}: Task {task_id}, Location {location_id}, Sequence {sequence}, Time {scheduled_time}")
        
        # Reset completed status
        cursor.execute("UPDATE patrol_task_stops SET completed = 0, completed_at = NULL WHERE id = ?", (stop_id,))
        
        # Tìm checkin records cho stop này (chỉ với location_id cụ thể)
        cursor.execute("""
            SELECT id, check_in_time
            FROM patrol_records
            WHERE task_id = ? AND location_id = ?
            ORDER BY check_in_time DESC
        """, (task_id, location_id))
        
        checkin_records = cursor.fetchall()
        
        if not checkin_records:
            print(f"      ⚪ Không có checkin record")
            continue
        
        # Kiểm tra từng checkin record
        for record_id, checkin_time_str in checkin_records:
            try:
                checkin_time = datetime.fromisoformat(checkin_time_str.replace('Z', '+00:00'))
                checkin_hour = checkin_time.hour
                checkin_minute = checkin_time.minute
                checkin_time_in_minutes = checkin_hour * 60 + checkin_minute
                
                # Parse scheduled time
                scheduled_hour, scheduled_minute = map(int, scheduled_time.split(':'))
                scheduled_time_in_minutes = scheduled_hour * 60 + scheduled_minute
                
                # Logic mới: chỉ cho phép chấm công từ giờ quy định + 15 phút
                time_window = 15
                is_within_window = (
                    checkin_time_in_minutes >= scheduled_time_in_minutes and
                    checkin_time_in_minutes <= (scheduled_time_in_minutes + time_window)
                )
                
                if is_within_window:
                    print(f"      ✅ Record {record_id}: Checkin {checkin_hour:02d}:{checkin_minute:02d} hợp lệ cho Stop {sequence} ({scheduled_time})")
                    cursor.execute("""
                        UPDATE patrol_task_stops 
                        SET completed = 1, completed_at = ?
                        WHERE id = ?
                    """, (checkin_time_str, stop_id))
                    break
                else:
                    if checkin_time_in_minutes < scheduled_time_in_minutes:
                        print(f"      ⏰ Record {record_id}: Checkin {checkin_hour:02d}:{checkin_minute:02d} quá sớm cho Stop {sequence} ({scheduled_time})")
                    else:
                        print(f"      ⏰ Record {record_id}: Checkin {checkin_hour:02d}:{checkin_minute:02d} quá muộn cho Stop {sequence} ({scheduled_time})")
                    
            except Exception as e:
                print(f"      ❌ Lỗi xử lý record {record_id}: {e}")
    
    # 3. Cập nhật trạng thái task
    print(f"\n3. 🔄 Cập nhật trạng thái task...")
    
    cursor.execute("""
        SELECT DISTINCT task_id
        FROM patrol_task_stops
        WHERE completed = 1
    """)
    completed_tasks = cursor.fetchall()
    
    for (task_id,) in completed_tasks:
        # Kiểm tra xem tất cả stops của task đã hoàn thành chưa
        cursor.execute("""
            SELECT COUNT(*) as total, SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completed_count
            FROM patrol_task_stops
            WHERE task_id = ?
        """, (task_id,))
        
        total, completed_count = cursor.fetchone()
        
        if completed_count == total and total > 0:
            cursor.execute("UPDATE patrol_tasks SET status = 'completed' WHERE id = ?", (task_id,))
            print(f"   ✅ Task {task_id}: Tất cả {total} stops đã hoàn thành → status = 'completed'")
        else:
            cursor.execute("UPDATE patrol_tasks SET status = 'in_progress' WHERE id = ?", (task_id,))
            print(f"   🔄 Task {task_id}: {completed_count}/{total} stops hoàn thành → status = 'in_progress'")
    
    # 4. Tạo script tự động cho tương lai
    print(f"\n4. 📝 Tạo script tự động cho tương lai...")
    
    script_content = '''#!/usr/bin/env python3
"""
Script tự động đồng bộ dữ liệu checkin theo logic đúng giờ
Chạy script này sau khi tạo nhiệm vụ mới để đảm bảo logic chính xác
"""

import sqlite3
from datetime import datetime

def sync_checkin_data_by_time():
    conn = sqlite3.connect('backend/app.db')
    cursor = conn.cursor()
    
    print("🔄 Bắt đầu đồng bộ dữ liệu checkin theo logic đúng giờ...")
    
    # Lấy tất cả patrol task stops
    cursor.execute("""
        SELECT pts.id, pts.task_id, pts.location_id, pts.sequence, pts.scheduled_time, pts.completed
        FROM patrol_task_stops pts
        WHERE pts.scheduled_time IS NOT NULL AND pts.scheduled_time != 'Chưa xác định'
        ORDER BY pts.task_id, pts.sequence
    """)
    stops = cursor.fetchall()
    
    print(f"📋 Tìm thấy {len(stops)} stops cần kiểm tra")
    
    for stop_id, task_id, location_id, sequence, scheduled_time, current_completed in stops:
        print(f"\\n🔍 Kiểm tra Stop {stop_id}: Task {task_id}, Location {location_id}, Sequence {sequence}, Time {scheduled_time}")
        
        # Reset completed status
        cursor.execute("UPDATE patrol_task_stops SET completed = 0, completed_at = NULL WHERE id = ?", (stop_id,))
        
        # Tìm checkin records cho stop này
        cursor.execute("""
            SELECT id, check_in_time
            FROM patrol_records
            WHERE task_id = ? AND location_id = ?
            ORDER BY check_in_time DESC
        """, (task_id, location_id))
        
        checkin_records = cursor.fetchall()
        
        if not checkin_records:
            print(f"   ⚪ Không có checkin record")
            continue
        
        # Kiểm tra từng checkin record
        for record_id, checkin_time_str in checkin_records:
            try:
                checkin_time = datetime.fromisoformat(checkin_time_str.replace('Z', '+00:00'))
                checkin_hour = checkin_time.hour
                checkin_minute = checkin_time.minute
                checkin_time_in_minutes = checkin_hour * 60 + checkin_minute
                
                # Parse scheduled time
                scheduled_hour, scheduled_minute = map(int, scheduled_time.split(':'))
                scheduled_time_in_minutes = scheduled_hour * 60 + scheduled_minute
                
                # Kiểm tra có trong khoảng thời gian hợp lệ không (từ giờ quy định + 15 phút)
                time_window = 15
                is_within_window = (
                    checkin_time_in_minutes >= scheduled_time_in_minutes and
                    checkin_time_in_minutes <= (scheduled_time_in_minutes + time_window)
                )
                
                if is_within_window:
                    print(f"   ✅ Record {record_id}: Checkin {checkin_hour:02d}:{checkin_minute:02d} trong khoảng thời gian hợp lệ cho Stop {sequence} ({scheduled_time})")
                    cursor.execute("""
                        UPDATE patrol_task_stops 
                        SET completed = 1, completed_at = ?
                        WHERE id = ?
                    """, (checkin_time_str, stop_id))
                    break
                else:
                    # Kiểm tra xem có phải chấm công sớm không
                    if checkin_time_in_minutes < scheduled_time_in_minutes:
                        print(f"   ⏰ Record {record_id}: Checkin {checkin_hour:02d}:{checkin_minute:02d} quá sớm cho Stop {sequence} ({scheduled_time})")
                    elif checkin_time_in_minutes > (scheduled_time_in_minutes + time_window):
                        print(f"   ⏰ Record {record_id}: Checkin {checkin_hour:02d}:{checkin_minute:02d} quá muộn cho Stop {sequence} ({scheduled_time})")
                    else:
                        print(f"   ⚠️  Record {record_id}: Checkin {checkin_hour:02d}:{checkin_minute:02d} ngoài khoảng thời gian hợp lệ cho Stop {sequence} ({scheduled_time})")
                    
            except Exception as e:
                print(f"   ❌ Lỗi xử lý record {record_id}: {e}")
    
    # Cập nhật trạng thái task dựa trên stops
    print(f"\\n🔄 Cập nhật trạng thái task...")
    
    cursor.execute("""
        SELECT DISTINCT task_id
        FROM patrol_task_stops
        WHERE completed = 1
    """)
    completed_tasks = cursor.fetchall()
    
    for (task_id,) in completed_tasks:
        # Kiểm tra xem tất cả stops của task đã hoàn thành chưa
        cursor.execute("""
            SELECT COUNT(*) as total, SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completed_count
            FROM patrol_task_stops
            WHERE task_id = ?
        """, (task_id,))
        
        total, completed_count = cursor.fetchone()
        
        if completed_count == total and total > 0:
            cursor.execute("UPDATE patrol_tasks SET status = 'completed' WHERE id = ?", (task_id,))
            print(f"   ✅ Task {task_id}: Tất cả {total} stops đã hoàn thành → status = 'completed'")
        else:
            cursor.execute("UPDATE patrol_tasks SET status = 'in_progress' WHERE id = ?", (task_id,))
            print(f"   🔄 Task {task_id}: {completed_count}/{total} stops hoàn thành → status = 'in_progress'")
    
    conn.commit()
    print("\\n✅ Hoàn thành đồng bộ dữ liệu theo logic đúng giờ!")
    conn.close()

if __name__ == "__main__":
    sync_checkin_data_by_time()
'''
    
    with open('sync-checkin-by-time-permanent.py', 'w', encoding='utf-8') as f:
        f.write(script_content)
    
    print("   ✅ Tạo file sync-checkin-by-time-permanent.py")
    
    conn.commit()
    print("\n✅ Hoàn thành sửa hẳn logic chấm công!")
    conn.close()

if __name__ == "__main__":
    fix_checkin_logic_permanently()
