#!/usr/bin/env python3
"""
Script backup toàn diện cho toàn bộ hệ thống
Bao gồm: Database, QR codes, ảnh chấm công, face data
"""

import os
import shutil
import json
import requests
import sqlite3
import psycopg2
from datetime import datetime
from pathlib import Path

class FullSystemBackup:
    def __init__(self, api_base_url="https://localhost:8000/api"):
        self.api_base_url = api_base_url
        self.backup_dir = "full_system_backup"
        self.upload_dir = "backend/uploads"
        
    def login(self, username="admin", password="admin123"):
        """Đăng nhập và lấy token"""
        try:
            response = requests.post(
                f"{self.api_base_url}/auth/login",
                json={"username": username, "password": password},
                verify=False
            )
            response.raise_for_status()
            token = response.json()["access_token"]
            self.headers = {"Authorization": f"Bearer {token}"}
            print("✅ Đăng nhập thành công")
            return True
        except Exception as e:
            print(f"❌ Lỗi đăng nhập: {e}")
            return False
    
    def backup_database_data(self, backup_path):
        """Backup tất cả dữ liệu từ database qua API"""
        print("🔄 Backup database data...")
        
        try:
            # Backup QR codes
            qr_response = requests.get(f"{self.api_base_url}/qr-codes/", headers=self.headers, verify=False)
            qr_response.raise_for_status()
            qr_codes = qr_response.json()
            
            # Backup patrol records
            records_response = requests.get(f"{self.api_base_url}/patrol-records/", headers=self.headers, verify=False)
            records_response.raise_for_status()
            patrol_records = records_response.json()
            
            # Backup tasks
            tasks_response = requests.get(f"{self.api_base_url}/patrol-tasks/", headers=self.headers, verify=False)
            tasks_response.raise_for_status()
            patrol_tasks = tasks_response.json()
            
            # Backup locations
            locations_response = requests.get(f"{self.api_base_url}/locations/", headers=self.headers, verify=False)
            locations_response.raise_for_status()
            locations = locations_response.json()
            
            # Backup users
            users_response = requests.get(f"{self.api_base_url}/users/", headers=self.headers, verify=False)
            users_response.raise_for_status()
            users = users_response.json()
            
            # Lưu tất cả vào file JSON
            database_data = {
                "backup_time": datetime.now().isoformat(),
                "qr_codes": qr_codes,
                "patrol_records": patrol_records,
                "patrol_tasks": patrol_tasks,
                "locations": locations,
                "users": users,
                "summary": {
                    "qr_codes_count": len(qr_codes),
                    "patrol_records_count": len(patrol_records),
                    "patrol_tasks_count": len(patrol_tasks),
                    "locations_count": len(locations),
                    "users_count": len(users)
                }
            }
            
            db_file = os.path.join(backup_path, "database_data.json")
            with open(db_file, 'w', encoding='utf-8') as f:
                json.dump(database_data, f, ensure_ascii=False, indent=2)
            
            print(f"✅ Database backup: {db_file}")
            print(f"📊 QR codes: {len(qr_codes)}, Records: {len(patrol_records)}, Tasks: {len(patrol_tasks)}")
            
            return database_data
            
        except Exception as e:
            print(f"❌ Lỗi backup database: {e}")
            return None
    
    def backup_upload_files(self, backup_path):
        """Backup tất cả files trong thư mục uploads"""
        print("🔄 Backup upload files...")
        
        try:
            uploads_backup_dir = os.path.join(backup_path, "uploads")
            os.makedirs(uploads_backup_dir, exist_ok=True)
            
            if not os.path.exists(self.upload_dir):
                print(f"⚠️ Upload directory không tồn tại: {self.upload_dir}")
                return 0
            
            copied_count = 0
            total_size = 0
            
            # Copy tất cả files trong uploads
            for root, dirs, files in os.walk(self.upload_dir):
                for file in files:
                    src_path = os.path.join(root, file)
                    rel_path = os.path.relpath(src_path, self.upload_dir)
                    dst_path = os.path.join(uploads_backup_dir, rel_path)
                    
                    # Tạo thư mục đích nếu cần
                    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                    
                    # Copy file
                    shutil.copy2(src_path, dst_path)
                    
                    file_size = os.path.getsize(src_path)
                    total_size += file_size
                    copied_count += 1
                    
                    print(f"✅ Copied: {rel_path} ({file_size} bytes)")
            
            print(f"✅ Upload files backup: {copied_count} files, {total_size/1024/1024:.2f} MB")
            return copied_count
            
        except Exception as e:
            print(f"❌ Lỗi backup upload files: {e}")
            return 0
    
    def create_backup_info(self, backup_path, db_data, files_count):
        """Tạo file thông tin backup"""
        backup_info = {
            "backup_time": datetime.now().isoformat(),
            "api_base_url": self.api_base_url,
            "backup_type": "full_system",
            "database_summary": db_data["summary"] if db_data else {},
            "files_backed_up": files_count,
            "backup_path": backup_path,
            "restore_instructions": [
                "1. Restore database data: python3 restore_database_data.py",
                "2. Restore upload files: python3 restore_upload_files.py",
                "3. Update API base URL in frontend if needed",
                "4. Restart backend server"
            ],
            "note": "Full system backup - includes all data and files"
        }
        
        info_file = os.path.join(backup_path, "backup_info.json")
        with open(info_file, 'w', encoding='utf-8') as f:
            json.dump(backup_info, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Backup info: {info_file}")
        return backup_info
    
    def full_backup(self):
        """Thực hiện backup toàn diện"""
        print("🚀 Bắt đầu backup toàn diện hệ thống...")
        
        # Tạo thư mục backup
        os.makedirs(self.backup_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = os.path.join(self.backup_dir, f"full_backup_{timestamp}")
        os.makedirs(backup_path, exist_ok=True)
        
        try:
            # Backup database data
            db_data = self.backup_database_data(backup_path)
            
            # Backup upload files
            files_count = self.backup_upload_files(backup_path)
            
            # Tạo backup info
            backup_info = self.create_backup_info(backup_path, db_data, files_count)
            
            print(f"\n✅ BACKUP HOÀN THÀNH: {backup_path}")
            print(f"📊 Database: {db_data['summary'] if db_data else 'Failed'}")
            print(f"📁 Files: {files_count} files")
            print(f"📝 Info: {os.path.join(backup_path, 'backup_info.json')}")
            
            return backup_path
            
        except Exception as e:
            print(f"❌ Lỗi backup toàn diện: {e}")
            return None

def main():
    backup_tool = FullSystemBackup()
    
    print("🔧 Full System Backup Tool")
    print("=" * 50)
    
    # Đăng nhập
    if not backup_tool.login():
        return
    
    # Thực hiện backup
    backup_path = backup_tool.full_backup()
    
    if backup_path:
        print(f"\n🎉 Backup thành công!")
        print(f"📁 Backup location: {backup_path}")
        print(f"💡 Để restore: python3 restore_full_system.py {backup_path}")
    else:
        print("\n❌ Backup thất bại!")

if __name__ == "__main__":
    main()
