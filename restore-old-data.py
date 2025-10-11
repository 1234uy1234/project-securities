#!/usr/bin/env python3
import sqlite3
import os
from datetime import datetime, timedelta

def restore_old_data():
    """Khôi phục dữ liệu cũ vào database"""
    
    db_path = "/Users/maybe/Documents/shopee/backend/patrol.db"
    
    # Kết nối database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    print("🔄 Đang khôi phục dữ liệu cũ...")
    
    try:
        # 1. Xóa dữ liệu cũ nếu có
        print("🧹 Xóa dữ liệu cũ...")
        cursor.execute("DELETE FROM patrol_records")
        cursor.execute("DELETE FROM patrol_tasks") 
        cursor.execute("DELETE FROM locations")
        cursor.execute("DELETE FROM users")
        
        # 2. Thêm users
        print("👥 Thêm users...")
        users_data = [
            ('admin', 'admin@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'admin', 'Administrator', '0123456789', True),
            ('manager', 'manager@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'manager', 'Nguyễn Văn Quản Lý', '0987654321', True),
            ('employee1', 'employee1@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'employee', 'Trần Văn Nhân Viên 1', '0123456780', True),
            ('employee2', 'employee2@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'employee', 'Lê Văn Nhân Viên 2', '0123456781', True),
            ('employee3', 'employee3@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'employee', 'Phạm Văn Nhân Viên 3', '0123456782', True)
        ]
        
        cursor.executemany("""
            INSERT INTO users (username, email, password_hash, role, full_name, phone, is_active, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, users_data)
        
        # 3. Thêm locations
        print("📍 Thêm locations...")
        locations_data = [
            ('Khu vực A - Cổng chính', 'Khu vực cổng chính nhà máy', 'location_1_cong_chinh', 'Cổng chính nhà máy MANHTOAN PLASTIC', 10.762622, 106.660172),
            ('Khu vực B - Nhà kho', 'Khu vực nhà kho nguyên liệu', 'location_2_nha_kho', 'Nhà kho nguyên liệu', 10.762800, 106.660300),
            ('Khu vực C - Xưởng sản xuất', 'Khu vực xưởng sản xuất chính', 'location_3_xuong_sx', 'Xưởng sản xuất chính', 10.763000, 106.660500),
            ('Khu vực D - Bãi xe', 'Khu vực bãi xe nhân viên', 'location_4_bai_xe', 'Bãi xe nhân viên', 10.763200, 106.660700),
            ('Khu vực E - Văn phòng', 'Khu vực văn phòng hành chính', 'location_5_van_phong', 'Văn phòng hành chính', 10.763400, 106.660900)
        ]
        
        cursor.executemany("""
            INSERT INTO locations (name, description, qr_code, address, gps_latitude, gps_longitude, created_at)
            VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, locations_data)
        
        # 4. Thêm patrol_tasks
        print("📋 Thêm patrol tasks...")
        tasks_data = [
            ('Tuần tra cổng chính', 'Kiểm tra an ninh cổng chính', 1, 3, '2024-W01', 'pending', 2),
            ('Tuần tra nhà kho', 'Kiểm tra an toàn nhà kho', 2, 4, '2024-W01', 'pending', 2),
            ('Tuần tra xưởng sản xuất', 'Kiểm tra an toàn lao động', 3, 5, '2024-W01', 'pending', 2),
            ('Tuần tra bãi xe', 'Kiểm tra trật tự bãi xe', 4, 3, '2024-W01', 'pending', 2),
            ('Tuần tra văn phòng', 'Kiểm tra an ninh văn phòng', 5, 4, '2024-W01', 'pending', 2)
        ]
        
        cursor.executemany("""
            INSERT INTO patrol_tasks (title, description, location_id, assigned_to, schedule_week, status, created_by, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, tasks_data)
        
        # 5. Thêm patrol_records
        print("📝 Thêm patrol records...")
        now = datetime.now()
        records_data = [
            (3, 1, 1, now - timedelta(hours=2), 10.762622, 106.660172, 'Tuần tra bình thường'),
            (4, 2, 2, now - timedelta(hours=1), 10.762800, 106.660300, 'Không có vấn đề gì'),
            (5, 3, 3, now - timedelta(minutes=30), 10.763000, 106.660500, 'Mọi thứ ổn định')
        ]
        
        cursor.executemany("""
            INSERT INTO patrol_records (user_id, task_id, location_id, check_in_time, gps_latitude, gps_longitude, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, records_data)
        
        # Commit changes
        conn.commit()
        
        # 6. Kiểm tra dữ liệu
        print("🔍 Kiểm tra dữ liệu đã khôi phục...")
        
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        print(f"   👥 Users: {user_count}")
        
        cursor.execute("SELECT COUNT(*) FROM locations")
        location_count = cursor.fetchone()[0]
        print(f"   📍 Locations: {location_count}")
        
        cursor.execute("SELECT COUNT(*) FROM patrol_tasks")
        task_count = cursor.fetchone()[0]
        print(f"   📋 Tasks: {task_count}")
        
        cursor.execute("SELECT COUNT(*) FROM patrol_records")
        record_count = cursor.fetchone()[0]
        print(f"   📝 Records: {record_count}")
        
        print("✅ Khôi phục dữ liệu thành công!")
        
    except Exception as e:
        print(f"❌ Lỗi khi khôi phục dữ liệu: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    restore_old_data()
