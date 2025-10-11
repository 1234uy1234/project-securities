#!/usr/bin/env python3
import psycopg2
import bcrypt
import os

def create_admin_user():
    # Kết nối database
    conn = psycopg2.connect(
        host="localhost",
        database="patrol_system",
        user="postgres",
        password=""
    )
    cursor = conn.cursor()
    
    # Tạo password hash cho admin123
    password = "admin123"
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    
    # Xóa tài khoản admin cũ
    cursor.execute("DELETE FROM users WHERE username = 'admin';")
    
    # Tạo tài khoản admin mới
    cursor.execute("""
        INSERT INTO users (username, email, password_hash, full_name, phone, role, is_active) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        'admin',
        'admin@manhtoan.com',
        hashed_password.decode('utf-8'),
        'Administrator',
        '0123456789',
        'ADMIN',
        True
    ))
    
    # Commit và đóng kết nối
    conn.commit()
    cursor.close()
    conn.close()
    
    print("✅ Tài khoản admin đã được tạo thành công!")
    print("🔑 Username: admin")
    print("🔑 Password: admin123")
    print("🔑 Role: ADMIN")

if __name__ == "__main__":
    create_admin_user()
