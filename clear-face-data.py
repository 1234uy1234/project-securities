#!/usr/bin/env python3
"""
Script để xóa tất cả dữ liệu khuôn mặt cũ và chuẩn bị đăng ký mới
"""

import sqlite3
import os
import sys

def clear_face_data():
    """Xóa tất cả dữ liệu khuôn mặt từ database"""
    try:
        # Kết nối database
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        print("🗑️  Đang xóa dữ liệu khuôn mặt cũ...")
        
        # Lấy danh sách file ảnh cần xóa
        cursor.execute('SELECT face_image_path FROM user_face_data WHERE face_image_path IS NOT NULL')
        image_paths = cursor.fetchall()
        
        # Xóa file ảnh
        for (image_path,) in image_paths:
            if image_path and os.path.exists(image_path):
                try:
                    os.remove(image_path)
                    print(f"✅ Đã xóa file: {image_path}")
                except Exception as e:
                    print(f"❌ Lỗi xóa file {image_path}: {e}")
        
        # Xóa tất cả dữ liệu khuôn mặt từ database
        cursor.execute('DELETE FROM user_face_data')
        deleted_count = cursor.rowcount
        
        # Commit changes
        conn.commit()
        conn.close()
        
        print(f"✅ Đã xóa {deleted_count} bản ghi khuôn mặt từ database")
        print("🎉 Hoàn tất! Bây giờ bạn có thể đăng ký khuôn mặt mới.")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    clear_face_data()
