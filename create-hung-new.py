#!/usr/bin/env python3
"""
Script để tạo tài khoản hung mới với password đúng
"""

import sqlite3
import subprocess
import json

def create_hung_new():
    """Tạo tài khoản hung mới với password đúng"""
    try:
        print("👤 Đang tạo tài khoản hung mới...")
        
        # Kết nối database
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        # Xóa tài khoản cũ
        cursor.execute('DELETE FROM users WHERE username = ?', ('hung',))
        
        # Tạo password hash bằng cách sử dụng backend
        print("🔐 Tạo password hash bằng backend...")
        
        # Tạo user với password tạm thời
        cursor.execute('''
        INSERT INTO users (username, email, password_hash, role, full_name, phone, is_active)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', ('hung_temp', 'hung_temp@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.8K2O', 'employee', 'Nguyễn Văn Hùng Temp', '0123456789', True))
        
        conn.commit()
        conn.close()
        
        # Test login với tài khoản tạm
        print("🧪 Testing login với tài khoản tạm...")
        result = subprocess.run([
            'curl', '-k', 
            'https://localhost:8000/api/auth/login',
            '-H', 'Content-Type: application/json',
            '-d', '{"username":"hung_temp","password":"admin123"}'
        ], capture_output=True, text=True)
        
        if result.returncode == 0 and 'access_token' in result.stdout:
            print("✅ Login thành công với tài khoản tạm!")
            
            # Đổi tên tài khoản
            conn = sqlite3.connect('backend/patrol.db')
            cursor = conn.cursor()
            cursor.execute('UPDATE users SET username = ?, email = ?, full_name = ? WHERE username = ?', 
                         ('hung', 'hung@example.com', 'Nguyễn Văn Hùng', 'hung_temp'))
            conn.commit()
            conn.close()
            
            print("✅ Đã đổi tên tài khoản thành 'hung'!")
            print("\n📝 Thông tin đăng nhập:")
            print("   Username: hung")
            print("   Password: admin123")
            
        else:
            print("❌ Login thất bại với tài khoản tạm")
            print(f"Response: {result.stdout}")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    create_hung_new()
