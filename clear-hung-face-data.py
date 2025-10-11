#!/usr/bin/env python3
"""
Script để xóa dữ liệu khuôn mặt của nguyen van hung
"""

import sqlite3
import os
import sys

def clear_hung_face_data():
    """Xóa dữ liệu khuôn mặt của nguyen van hung"""
    try:
        # Kết nối database
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        print("🔍 Đang tìm tài khoản nguyen van hung...")
        
        # Tìm user_id của nguyen van hung
        cursor.execute('SELECT id, username, full_name FROM users WHERE username LIKE "%hung%" OR full_name LIKE "%hung%"')
        users = cursor.fetchall()
        
        if not users:
            print("❌ Không tìm thấy tài khoản nào có tên 'hung'")
            return
        
        print("📋 Tìm thấy các tài khoản:")
        for user_id, username, full_name in users:
            print(f"   - ID: {user_id}, Username: {username}, Full name: {full_name}")
        
        # Tìm tài khoản nguyen van hung cụ thể
        hung_user = None
        for user_id, username, full_name in users:
            if 'nguyen' in full_name.lower() and 'hung' in full_name.lower():
                hung_user = (user_id, username, full_name)
                break
        
        if not hung_user:
            print("❌ Không tìm thấy tài khoản 'nguyen van hung' cụ thể")
            print("💡 Các tài khoản có thể:")
            for user_id, username, full_name in users:
                print(f"   - {full_name} (username: {username})")
            return
        
        user_id, username, full_name = hung_user
        print(f"✅ Tìm thấy tài khoản: {full_name} (ID: {user_id}, Username: {username})")
        
        # Kiểm tra dữ liệu khuôn mặt hiện tại
        cursor.execute('SELECT id, face_image_path, is_active, created_at FROM user_face_data WHERE user_id = ?', (user_id,))
        face_data = cursor.fetchall()
        
        if face_data:
            print(f"📸 Tìm thấy {len(face_data)} bản ghi khuôn mặt:")
            for face_id, image_path, is_active, created_at in face_data:
                status = "Hoạt động" if is_active else "Không hoạt động"
                print(f"   - Face ID: {face_id}, Status: {status}, Created: {created_at}")
                if image_path:
                    print(f"     Image path: {image_path}")
        else:
            print("📸 Không tìm thấy dữ liệu khuôn mặt")
        
        # Xác nhận xóa
        print("\n⚠️  Bạn có chắc chắn muốn xóa dữ liệu khuôn mặt của tài khoản này?")
        confirm = input("Nhập 'YES' để xác nhận: ")
        
        if confirm != 'YES':
            print("❌ Hủy bỏ thao tác")
            return
        
        print("🗑️  Đang xóa dữ liệu khuôn mặt...")
        
        # Xóa file ảnh
        for face_id, image_path, is_active, created_at in face_data:
            if image_path and os.path.exists(image_path):
                try:
                    os.remove(image_path)
                    print(f"✅ Đã xóa file: {image_path}")
                except Exception as e:
                    print(f"❌ Lỗi xóa file {image_path}: {e}")
        
        # Xóa dữ liệu khuôn mặt từ database
        cursor.execute('DELETE FROM user_face_data WHERE user_id = ?', (user_id,))
        deleted_count = cursor.rowcount
        
        # Commit changes
        conn.commit()
        conn.close()
        
        print(f"✅ Đã xóa {deleted_count} bản ghi khuôn mặt của {full_name}")
        print("🎉 Hoàn tất! Bây giờ tài khoản này có thể đăng ký khuôn mặt mới.")
        print("\n📝 Hướng dẫn tiếp theo:")
        print("1. Đăng nhập với tài khoản này")
        print("2. Vào trang cài đặt khuôn mặt")
        print("3. Đăng ký khuôn mặt mới")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    clear_hung_face_data()
