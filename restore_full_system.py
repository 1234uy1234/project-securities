#!/usr/bin/env python3
"""
Script restore toàn diện cho toàn bộ hệ thống
"""

import os
import shutil
import json
import requests
from datetime import datetime

class FullSystemRestore:
    def __init__(self, api_base_url="https://localhost:8000/api"):
        self.api_base_url = api_base_url
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
    
    def restore_upload_files(self, backup_path):
        """Restore tất cả files từ backup"""
        print("🔄 Restore upload files...")
        
        try:
            uploads_backup_dir = os.path.join(backup_path, "uploads")
            
            if not os.path.exists(uploads_backup_dir):
                print(f"⚠️ Upload backup directory không tồn tại: {uploads_backup_dir}")
                return 0
            
            # Tạo thư mục uploads nếu chưa có
            os.makedirs(self.upload_dir, exist_ok=True)
            
            restored_count = 0
            
            # Copy tất cả files từ backup
            for root, dirs, files in os.walk(uploads_backup_dir):
                for file in files:
                    src_path = os.path.join(root, file)
                    rel_path = os.path.relpath(src_path, uploads_backup_dir)
                    dst_path = os.path.join(self.upload_dir, rel_path)
                    
                    # Tạo thư mục đích nếu cần
                    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                    
                    # Copy file
                    shutil.copy2(src_path, dst_path)
                    
                    restored_count += 1
                    print(f"✅ Restored: {rel_path}")
            
            print(f"✅ Upload files restore: {restored_count} files")
            return restored_count
            
        except Exception as e:
            print(f"❌ Lỗi restore upload files: {e}")
            return 0
    
    def restore_qr_codes(self, qr_codes):
        """Restore QR codes vào database"""
        print("🔄 Restore QR codes...")
        
        try:
            restored_count = 0
            
            for qr in qr_codes:
                try:
                    # Tạo QR code mới
                    response = requests.post(
                        f"{self.api_base_url}/qr-codes/generate-simple",
                        params={
                            "data": qr["data"],
                            "type": qr["type"]
                        },
                        headers=self.headers,
                        verify=False
                    )
                    
                    if response.status_code == 200:
                        new_qr = response.json()
                        print(f"✅ Restored QR: {qr['data']} -> ID {new_qr['id']}")
                        restored_count += 1
                    else:
                        print(f"⚠️ Failed to restore QR: {qr['data']} - {response.text}")
                        
                except Exception as e:
                    print(f"❌ Error restoring QR {qr['data']}: {e}")
            
            print(f"✅ QR codes restore: {restored_count}/{len(qr_codes)}")
            return restored_count
            
        except Exception as e:
            print(f"❌ Lỗi restore QR codes: {e}")
            return 0
    
    def restore_locations(self, locations):
        """Restore locations vào database"""
        print("🔄 Restore locations...")
        
        try:
            restored_count = 0
            
            for location in locations:
                try:
                    # Tạo location mới
                    response = requests.post(
                        f"{self.api_base_url}/locations/",
                        json={
                            "name": location["name"],
                            "description": location.get("description", ""),
                            "address": location.get("address", ""),
                            "latitude": location.get("latitude", 0.0),
                            "longitude": location.get("longitude", 0.0)
                        },
                        headers=self.headers,
                        verify=False
                    )
                    
                    if response.status_code == 200:
                        new_location = response.json()
                        print(f"✅ Restored location: {location['name']} -> ID {new_location['id']}")
                        restored_count += 1
                    else:
                        print(f"⚠️ Failed to restore location: {location['name']} - {response.text}")
                        
                except Exception as e:
                    print(f"❌ Error restoring location {location['name']}: {e}")
            
            print(f"✅ Locations restore: {restored_count}/{len(locations)}")
            return restored_count
            
        except Exception as e:
            print(f"❌ Lỗi restore locations: {e}")
            return 0
    
    def restore_patrol_tasks(self, patrol_tasks):
        """Restore patrol tasks vào database"""
        print("🔄 Restore patrol tasks...")
        
        try:
            restored_count = 0
            
            for task in patrol_tasks:
                try:
                    # Tạo task mới
                    response = requests.post(
                        f"{self.api_base_url}/patrol-tasks/",
                        json={
                            "title": task["title"],
                            "description": task.get("description", ""),
                            "assigned_to": task["assigned_to"],
                            "location_id": task.get("location_id", 1),
                            "schedule_week": task.get("schedule_week", "{}"),
                            "stops": task.get("stops", [])
                        },
                        headers=self.headers,
                        verify=False
                    )
                    
                    if response.status_code == 200:
                        new_task = response.json()
                        print(f"✅ Restored task: {task['title']} -> ID {new_task['id']}")
                        restored_count += 1
                    else:
                        print(f"⚠️ Failed to restore task: {task['title']} - {response.text}")
                        
                except Exception as e:
                    print(f"❌ Error restoring task {task['title']}: {e}")
            
            print(f"✅ Patrol tasks restore: {restored_count}/{len(patrol_tasks)}")
            return restored_count
            
        except Exception as e:
            print(f"❌ Lỗi restore patrol tasks: {e}")
            return 0
    
    def restore_database_data(self, backup_path):
        """Restore tất cả dữ liệu database"""
        print("🔄 Restore database data...")
        
        try:
            # Đọc database data
            db_file = os.path.join(backup_path, "database_data.json")
            with open(db_file, 'r', encoding='utf-8') as f:
                db_data = json.load(f)
            
            # Restore theo thứ tự: QR codes -> Locations -> Tasks
            qr_count = self.restore_qr_codes(db_data["qr_codes"])
            location_count = self.restore_locations(db_data["locations"])
            task_count = self.restore_patrol_tasks(db_data["patrol_tasks"])
            
            print(f"✅ Database restore summary:")
            print(f"  - QR codes: {qr_count}")
            print(f"  - Locations: {location_count}")
            print(f"  - Tasks: {task_count}")
            
            return True
            
        except Exception as e:
            print(f"❌ Lỗi restore database data: {e}")
            return False
    
    def full_restore(self, backup_path):
        """Thực hiện restore toàn diện"""
        print(f"🚀 Bắt đầu restore từ: {backup_path}")
        
        try:
            # Kiểm tra backup path
            if not os.path.exists(backup_path):
                print(f"❌ Backup path không tồn tại: {backup_path}")
                return False
            
            # Restore upload files
            files_count = self.restore_upload_files(backup_path)
            
            # Restore database data
            db_success = self.restore_database_data(backup_path)
            
            print(f"\n✅ RESTORE HOÀN THÀNH!")
            print(f"📁 Files restored: {files_count}")
            print(f"📊 Database restored: {'Success' if db_success else 'Failed'}")
            
            return True
            
        except Exception as e:
            print(f"❌ Lỗi restore toàn diện: {e}")
            return False

def main():
    import sys
    
    if len(sys.argv) < 2:
        print("❌ Vui lòng chỉ định backup path")
        print("Usage: python3 restore_full_system.py <backup_path>")
        return
    
    backup_path = sys.argv[1]
    
    restore_tool = FullSystemRestore()
    
    print("🔧 Full System Restore Tool")
    print("=" * 50)
    
    # Đăng nhập
    if not restore_tool.login():
        return
    
    # Thực hiện restore
    success = restore_tool.full_restore(backup_path)
    
    if success:
        print(f"\n🎉 Restore thành công!")
        print(f"💡 Hệ thống đã được khôi phục hoàn toàn")
    else:
        print("\n❌ Restore thất bại!")

if __name__ == "__main__":
    main()
