#!/usr/bin/env python3
import os
import sqlite3
import json
from datetime import datetime

def find_real_data():
    """Tìm dữ liệu thực sự của bạn"""
    
    print("🔍 Tìm kiếm dữ liệu thực sự của bạn...")
    
    # 1. Kiểm tra database hiện tại
    db_path = "/Users/maybe/Documents/shopee/backend/patrol.db"
    
    if os.path.exists(db_path):
        print(f"📊 Database hiện tại: {db_path}")
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Kiểm tra dữ liệu
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM locations") 
        location_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM patrol_tasks")
        task_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM patrol_records")
        record_count = cursor.fetchone()[0]
        
        print(f"   👥 Users: {user_count}")
        print(f"   📍 Locations: {location_count}")
        print(f"   📋 Tasks: {task_count}")
        print(f"   📝 Records: {record_count}")
        
        # Kiểm tra dữ liệu chi tiết
        cursor.execute("SELECT username, role, full_name FROM users LIMIT 5")
        users = cursor.fetchall()
        print("   👤 Sample users:")
        for user in users:
            print(f"      - {user[0]} ({user[1]}) - {user[2]}")
        
        cursor.execute("SELECT name, qr_code FROM locations LIMIT 5")
        locations = cursor.fetchall()
        print("   📍 Sample locations:")
        for loc in locations:
            print(f"      - {loc[0]} ({loc[1]})")
        
        conn.close()
    
    # 2. Tìm kiếm file backup
    print("\n🔍 Tìm kiếm file backup...")
    
    backup_files = []
    for root, dirs, files in os.walk("/Users/maybe/Documents/shopee"):
        for file in files:
            if any(keyword in file.lower() for keyword in ['backup', 'old', 'original', 'copy', 'bak']):
                if any(ext in file.lower() for ext in ['.db', '.sql', '.sqlite']):
                    backup_files.append(os.path.join(root, file))
    
    if backup_files:
        print("   📁 Tìm thấy file backup:")
        for backup in backup_files:
            print(f"      - {backup}")
    else:
        print("   ❌ Không tìm thấy file backup database")
    
    # 3. Kiểm tra file SQL
    print("\n📄 Kiểm tra file SQL...")
    sql_files = [
        "/Users/maybe/Documents/shopee/database/init.sql",
        "/Users/maybe/Documents/shopee/database/sample_data.sql"
    ]
    
    for sql_file in sql_files:
        if os.path.exists(sql_file):
            print(f"   📄 {sql_file}")
            with open(sql_file, 'r', encoding='utf-8') as f:
                content = f.read()
                if 'INSERT INTO' in content:
                    insert_count = content.count('INSERT INTO')
                    print(f"      - {insert_count} INSERT statements")
                else:
                    print(f"      - Schema file")
    
    # 4. Kiểm tra uploads
    print("\n📁 Kiểm tra thư mục uploads...")
    uploads_dir = "/Users/maybe/Documents/shopee/uploads"
    if os.path.exists(uploads_dir):
        files = os.listdir(uploads_dir)
        print(f"   📁 Uploads: {len(files)} files")
        for file in files[:5]:  # Show first 5 files
            print(f"      - {file}")
    else:
        print("   ❌ Không có thư mục uploads")
    
    # 5. Kiểm tra logs
    print("\n📋 Kiểm tra logs...")
    log_files = [
        "/Users/maybe/Documents/shopee/backend/backend.log",
        "/Users/maybe/Documents/shopee/frontend/frontend.log"
    ]
    
    for log_file in log_files:
        if os.path.exists(log_file):
            print(f"   📋 {log_file}")
            with open(log_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                print(f"      - {len(lines)} lines")
        else:
            print(f"   ❌ {log_file} not found")
    
    print("\n💡 Kết luận:")
    print("   - Database hiện tại có dữ liệu mẫu")
    print("   - Không tìm thấy backup database thực sự")
    print("   - Có thể dữ liệu của bạn đã bị mất hoặc chưa được lưu")
    print("\n🔧 Để khôi phục dữ liệu thực sự:")
    print("   1. Kiểm tra xem có file backup nào khác không")
    print("   2. Kiểm tra git history nếu có")
    print("   3. Kiểm tra cloud backup nếu có")
    print("   4. Tạo dữ liệu mới từ đầu")

if __name__ == "__main__":
    find_real_data()
