#!/usr/bin/env python3
"""
Script để tạo tài khoản nguyen van hung
"""

import sqlite3
import os
import sys
import bcrypt

def create_hung_user():
    """Tạo tài khoản nguyen van hung"""
    try:
        # Kết nối database
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        print("👤 Đang tạo tài khoản nguyen van hung...")
        
        # Kiểm tra xem tài khoản đã tồn tại chưa
        cursor.execute('SELECT id FROM users WHERE username = ? OR email = ?', ('hung', 'hung@example.com'))
        existing_user = cursor.fetchone()
        
        if existing_user:
            print("⚠️  Tài khoản 'hung' đã tồn tại")
            return
        
        # Tạo password hash
        password = 'hung123'
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        
        # Insert user
        cursor.execute('''
        INSERT INTO users (username, email, password_hash, role, full_name, phone, is_active)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', ('hung', 'hung@example.com', password_hash, 'employee', 'Nguyễn Văn Hùng', '0123456789', True))
        
        user_id = cursor.lastrowid
        
        # Commit changes
        conn.commit()
        conn.close()
        
        print(f"✅ Đã tạo tài khoản nguyen van hung thành công!")
        print(f"   - User ID: {user_id}")
        print(f"   - Username: hung")
        print(f"   - Password: hung123")
        print(f"   - Full name: Nguyễn Văn Hùng")
        print(f"   - Email: hung@example.com")
        print(f"   - Role: employee")
        
        print("\n📝 Thông tin đăng nhập:")
        print("   Username: hung")
        print("   Password: hung123")
        
        print("\n🎯 Bây giờ bạn có thể:")
        print("1. Đăng nhập với tài khoản này")
        print("2. Vào trang cài đặt khuôn mặt")
        print("3. Đăng ký khuôn mặt mới")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    create_hung_user()
