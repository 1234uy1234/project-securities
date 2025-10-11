#!/usr/bin/env python3
"""
Script để reset hoàn toàn face authentication
"""

import sqlite3
import os
import sys

def reset_face_auth():
    """Reset hoàn toàn face authentication"""
    try:
        # Kết nối database
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        print("🗑️  Đang reset face authentication...")
        
        # Xóa tất cả dữ liệu khuôn mặt
        cursor.execute('DELETE FROM user_face_data')
        deleted_count = cursor.rowcount
        
        # Reset auto increment
        cursor.execute('DELETE FROM sqlite_sequence WHERE name = "user_face_data"')
        
        # Commit changes
        conn.commit()
        conn.close()
        
        print(f"✅ Đã xóa {deleted_count} bản ghi khuôn mặt")
        print("✅ Đã reset auto increment")
        
        # Xóa file ảnh cũ
        uploads_dir = 'backend/uploads'
        if os.path.exists(uploads_dir):
            for file in os.listdir(uploads_dir):
                if file.startswith('face_') and file.endswith('.jpg'):
                    file_path = os.path.join(uploads_dir, file)
                    try:
                        os.remove(file_path)
                        print(f"✅ Đã xóa file: {file}")
                    except Exception as e:
                        print(f"❌ Lỗi xóa file {file}: {e}")
        
        print("🎉 Reset hoàn tất! Bây giờ bạn có thể đăng ký khuôn mặt mới.")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    reset_face_auth()
