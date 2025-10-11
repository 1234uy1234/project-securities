#!/usr/bin/env python3
"""
Script để tạo tài khoản hung với password đúng
"""

import sqlite3
import bcrypt

def create_hung_correct():
    """Tạo tài khoản hung với password đúng"""
    try:
        # Kết nối database
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        print("👤 Đang tạo tài khoản hung với password đúng...")
        
        # Xóa tài khoản cũ nếu có
        cursor.execute('DELETE FROM users WHERE username = ?', ('hung',))
        
        # Tạo password hash giống admin (admin123)
        password = 'admin123'
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
        
        print(f"✅ Đã tạo tài khoản hung thành công!")
        print(f"   - User ID: {user_id}")
        print(f"   - Username: hung")
        print(f"   - Password: admin123")
        print(f"   - Full name: Nguyễn Văn Hùng")
        print(f"   - Email: hung@example.com")
        print(f"   - Role: employee")
        
        print("\n📝 Thông tin đăng nhập:")
        print("   Username: hung")
        print("   Password: admin123")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    create_hung_correct()
