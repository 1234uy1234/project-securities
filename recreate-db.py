#!/usr/bin/env python3
"""
Script để tạo lại database hoàn toàn
"""

import sqlite3
import os
import sys

def recreate_database():
    """Tạo lại database hoàn toàn"""
    try:
        # Backup database cũ
        if os.path.exists('backend/patrol.db'):
            os.rename('backend/patrol.db', 'backend/patrol.db.backup')
            print("✅ Đã backup database cũ")
        
        # Tạo database mới
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        print("🔧 Đang tạo database mới...")
        
        # Tạo bảng users
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
        
        # Tạo bảng user_face_data
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
        
        # Tạo bảng locations
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
        
        # Tạo bảng patrol_tasks
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
        
        # Tạo bảng patrol_records
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
        
        # Insert dữ liệu mẫu
        print("📝 Đang thêm dữ liệu mẫu...")
        
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
        
        # Commit changes
        conn.commit()
        conn.close()
        
        print("✅ Đã tạo database mới thành công!")
        print("📝 Dữ liệu mẫu:")
        print("   - 5 users (admin, manager, employee1-3)")
        print("   - 5 locations")
        print("   - Password mặc định: admin123")
        print("   - Không có dữ liệu khuôn mặt")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    recreate_database()