#!/usr/bin/env python3
"""
Script để khôi phục database với dữ liệu mẫu
"""

import sqlite3
import os

def restore_database():
    """Khôi phục database với dữ liệu mẫu"""
    try:
        print("🔧 Khôi phục database với dữ liệu mẫu...")
        
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()

        print("1. Xóa tất cả bảng cũ...")
        cursor.execute('DROP TABLE IF EXISTS patrol_records')
        cursor.execute('DROP TABLE IF EXISTS patrol_tasks')
        cursor.execute('DROP TABLE IF EXISTS locations')
        cursor.execute('DROP TABLE IF EXISTS user_face_data')
        cursor.execute('DROP TABLE IF EXISTS users')

        print("2. Tạo lại bảng users...")
        cursor.execute('''
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username VARCHAR(50) NOT NULL UNIQUE,
            email VARCHAR(100) NOT NULL UNIQUE,
            password_hash VARCHAR(255) NOT NULL,
            role VARCHAR(20) NOT NULL DEFAULT 'employee',
            full_name VARCHAR(100) NOT NULL,
            phone VARCHAR(20),
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        ''')

        print("3. Tạo bảng user_face_data...")
        cursor.execute('''
        CREATE TABLE user_face_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            face_encoding BLOB NOT NULL,
            face_image_path VARCHAR(255),
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
        ''')

        print("4. Tạo bảng locations...")
        cursor.execute('''
        CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            qr_code VARCHAR(255),
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        ''')

        print("5. Tạo bảng patrol_tasks...")
        cursor.execute('''
        CREATE TABLE patrol_tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title VARCHAR(200) NOT NULL,
            description TEXT,
            location_id INTEGER,
            assigned_to INTEGER,
            status VARCHAR(20) DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (location_id) REFERENCES locations (id),
            FOREIGN KEY (assigned_to) REFERENCES users (id)
        )
        ''')

        print("6. Tạo bảng patrol_records...")
        cursor.execute('''
        CREATE TABLE patrol_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            location_id INTEGER NOT NULL,
            check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            check_out_time TIMESTAMP,
            notes TEXT,
            photo_path VARCHAR(255),
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (location_id) REFERENCES locations (id)
        )
        ''')

        print("7. Thêm dữ liệu mẫu...")
        
        # Users
        users_data = [
            ('admin', 'admin@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.8K2O', 'admin', 'Administrator', None),
            ('manager', 'manager@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.8K2O', 'manager', 'Nguyễn Văn Quản Lý', None),
            ('employee1', 'emp1@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.8K2O', 'employee', 'Trần Văn Nhân Viên 1', None),
            ('employee2', 'emp2@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.8K2O', 'employee', 'Lê Văn Nhân Viên 2', None),
            ('employee3', 'emp3@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.8K2O', 'employee', 'Phạm Văn Nhân Viên 3', None)
        ]

        cursor.executemany('''
        INSERT INTO users (username, email, password_hash, role, full_name, phone)
        VALUES (?, ?, ?, ?, ?, ?)
        ''', users_data)

        # Locations
        locations_data = [
            ('Khu vực A', 'Mô tả khu vực A', 'QR_A_001', True),
            ('Khu vực B', 'Mô tả khu vực B', 'QR_B_002', True),
            ('Khu vực C', 'Mô tả khu vực C', 'QR_C_003', True),
            ('Khu vực D', 'Mô tả khu vực D', 'QR_D_004', True),
            ('Khu vực E', 'Mô tả khu vực E', 'QR_E_005', True)
        ]

        cursor.executemany('''
        INSERT INTO locations (name, description, qr_code, is_active)
        VALUES (?, ?, ?, ?)
        ''', locations_data)

        # Thêm một số patrol_records mẫu với ảnh
        print("8. Thêm patrol_records mẫu với ảnh...")
        checkin_photos_dir = '/Users/maybe/Documents/shopee/checkin_photos/'
        if os.path.exists(checkin_photos_dir):
            checkin_photos = os.listdir(checkin_photos_dir)
            if checkin_photos:
                # Lấy 10 ảnh đầu tiên để tạo records mẫu
                sample_photos = checkin_photos[:10]
                for i, photo in enumerate(sample_photos):
                    if photo.endswith('.jpg'):
                        cursor.execute('''
                        INSERT INTO patrol_records (user_id, location_id, check_in_time, photo_path)
                        VALUES (?, ?, datetime('now', '-{} days'), ?)
                        '''.format(i), (1, (i % 5) + 1, f'checkin_photos/{photo}'))

        conn.commit()
        conn.close()

        print("🎉 HOÀN TẤT! Database đã được khôi phục!")
        print("✅ Ảnh checkin đã được khôi phục!")
        print("✅ Báo cáo và admin dashboard sẽ hiển thị ảnh lại!")
        print("✅ Face auth đã được reset sạch!")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")

if __name__ == "__main__":
    restore_database()
