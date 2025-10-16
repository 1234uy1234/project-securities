#!/usr/bin/env python3
"""
Create sample data with proper schema
"""

import sqlite3
import json
from datetime import datetime, timedelta

def create_sample_data():
    db_path = "/Users/maybe/Documents/shopee/backend/patrol.db"
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    print("🔄 Creating sample data...")
    
    # Create sample task with multiple stops
    today = datetime.now().strftime('%Y-%m-%d')
    
    # Insert sample task
    cursor.execute("""
        INSERT INTO patrol_tasks (title, description, assigned_to, status, schedule_week, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        "kokoko",
        "Nhiệm vụ test với 2 stops",
        1,  # assigned to user 1
        "pending",
        json.dumps({
            "date": today,
            "startTime": "09:00",
            "endTime": "10:00",
            "stops": [
                {"location_id": 1, "scheduled_time": "09:00"},
                {"location_id": 2, "scheduled_time": "09:30"}
            ]
        }),
        datetime.now().isoformat()
    ))
    
    task_id = cursor.lastrowid
    print(f"✅ Created task {task_id}: kokoko")
    
    # Create stops for the task
    cursor.execute("""
        INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, completed, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (task_id, 1, 1, "09:00", 1, datetime.now().isoformat()))
    
    cursor.execute("""
        INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, completed, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (task_id, 2, 2, "09:30", 1, datetime.now().isoformat()))
    
    print(f"✅ Created 2 stops for task {task_id}")
    
    # Create sample patrol records for each stop
    checkin_time_1 = datetime.now().replace(hour=9, minute=0, second=0, microsecond=0)
    checkin_time_2 = datetime.now().replace(hour=9, minute=31, second=0, microsecond=0)
    
    # Record for stop 1 (location_id=1, 09:00)
    cursor.execute("""
        INSERT INTO patrol_records (user_id, task_id, location_id, check_in_time, notes, photo_path)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        1,  # user_id
        task_id,
        1,  # location_id for stop 1
        checkin_time_1.isoformat(),
        "Checkin tại nhà đi chơi lúc 09:00",
        "uploads/checkin_1_20251011_090000.jpg"
    ))
    
    # Record for stop 2 (location_id=2, 09:30)
    cursor.execute("""
        INSERT INTO patrol_records (user_id, task_id, location_id, check_in_time, notes, photo_path)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        1,  # user_id
        task_id,
        2,  # location_id for stop 2
        checkin_time_2.isoformat(),
        "Checkin tại nhà xe lúc 09:31",
        "uploads/checkin_1_20251011_093100.jpg"
    ))
    
    print(f"✅ Created 2 patrol records for task {task_id}")
    
    # Create another task for testing
    cursor.execute("""
        INSERT INTO patrol_tasks (title, description, assigned_to, status, schedule_week, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        "nv vm k k",
        "Nhiệm vụ test với 2 stops khác",
        1,  # assigned to user 1
        "pending",
        json.dumps({
            "date": today,
            "startTime": "13:35",
            "endTime": "14:00",
            "stops": [
                {"location_id": 1, "scheduled_time": "13:35"},
                {"location_id": 2, "scheduled_time": "14:00"}
            ]
        }),
        datetime.now().isoformat()
    ))
    
    task_id_2 = cursor.lastrowid
    print(f"✅ Created task {task_id_2}: nv vm k k")
    
    # Create stops for task 2
    cursor.execute("""
        INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, completed, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (task_id_2, 1, 1, "13:35", 1, datetime.now().isoformat()))
    
    cursor.execute("""
        INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, completed, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (task_id_2, 2, 2, "14:00", 0, datetime.now().isoformat()))
    
    print(f"✅ Created 2 stops for task {task_id_2}")
    
    # Create patrol record for stop 1 of task 2
    checkin_time_3 = datetime.now().replace(hour=13, minute=37, second=50, microsecond=0)
    
    cursor.execute("""
        INSERT INTO patrol_records (user_id, task_id, location_id, check_in_time, notes, photo_path)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        1,  # user_id
        task_id_2,
        1,  # location_id for stop 1
        checkin_time_3.isoformat(),
        "Checkin tại nhà đi chơi lúc 13:37:50",
        "uploads/checkin_1_20251011_133750.jpg"
    ))
    
    print(f"✅ Created 1 patrol record for task {task_id_2} (stop 1 only)")
    
    conn.commit()
    conn.close()
    
    print("🎉 Sample data created successfully!")
    print("📝 Data summary:")
    print(f"- Task {task_id} (kokoko): 2 stops, both completed")
    print(f"- Task {task_id_2} (nv vm k k): 2 stops, only stop 1 completed")
    print("- Each stop has its own patrol_record with correct task_id and location_id")

if __name__ == "__main__":
    create_sample_data()
