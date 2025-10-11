#!/usr/bin/env python3
"""
Script để backup và restore QR codes khi đổi IP backend/frontend
"""

import os
import shutil
import json
import requests
from datetime import datetime

class QRCodeBackup:
    def __init__(self, api_base_url="https://localhost:8000/api"):
        self.api_base_url = api_base_url
        self.backup_dir = "qr_backup"
        self.qr_codes_dir = "backend/uploads/qr_codes"
        
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
    
    def backup_qr_codes(self):
        """Backup QR codes từ database và files"""
        print("🔄 Bắt đầu backup QR codes...")
        
        # Tạo thư mục backup
        os.makedirs(self.backup_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = os.path.join(self.backup_dir, f"qr_backup_{timestamp}")
        os.makedirs(backup_path, exist_ok=True)
        
        try:
            # Lấy danh sách QR codes từ API
            response = requests.get(
                f"{self.api_base_url}/qr-codes/",
                headers=self.headers,
                verify=False
            )
            response.raise_for_status()
            qr_codes = response.json()
            
            # Lưu metadata vào file JSON
            metadata_file = os.path.join(backup_path, "qr_codes_metadata.json")
            with open(metadata_file, 'w', encoding='utf-8') as f:
                json.dump(qr_codes, f, ensure_ascii=False, indent=2)
            
            # Copy QR code files
            qr_files_dir = os.path.join(backup_path, "qr_files")
            os.makedirs(qr_files_dir, exist_ok=True)
            
            for qr in qr_codes:
                filename = qr["filename"]
                src_path = os.path.join(self.qr_codes_dir, filename)
                dst_path = os.path.join(qr_files_dir, filename)
                
                if os.path.exists(src_path):
                    shutil.copy2(src_path, dst_path)
                    print(f"✅ Copied: {filename}")
                else:
                    print(f"⚠️ File not found: {filename}")
            
            print(f"✅ Backup hoàn thành: {backup_path}")
            print(f"📊 Tổng cộng: {len(qr_codes)} QR codes")
            return backup_path
            
        except Exception as e:
            print(f"❌ Lỗi backup: {e}")
            return None
    
    def restore_qr_codes(self, backup_path):
        """Restore QR codes từ backup"""
        print(f"🔄 Bắt đầu restore từ: {backup_path}")
        
        try:
            # Đọc metadata
            metadata_file = os.path.join(backup_path, "qr_codes_metadata.json")
            with open(metadata_file, 'r', encoding='utf-8') as f:
                qr_codes = json.load(f)
            
            # Restore files
            qr_files_dir = os.path.join(backup_path, "qr_files")
            os.makedirs(self.qr_codes_dir, exist_ok=True)
            
            restored_count = 0
            for qr in qr_codes:
                filename = qr["filename"]
                src_path = os.path.join(qr_files_dir, filename)
                dst_path = os.path.join(self.qr_codes_dir, filename)
                
                if os.path.exists(src_path):
                    shutil.copy2(src_path, dst_path)
                    print(f"✅ Restored: {filename}")
                    restored_count += 1
                else:
                    print(f"⚠️ Backup file not found: {filename}")
            
            print(f"✅ Restore hoàn thành: {restored_count}/{len(qr_codes)} files")
            
            # Lưu metadata để có thể import vào database sau
            restore_metadata = {
                "restore_time": datetime.now().isoformat(),
                "qr_codes": qr_codes,
                "note": "Cần import vào database bằng script khác"
            }
            
            restore_file = os.path.join(backup_path, "restore_info.json")
            with open(restore_file, 'w', encoding='utf-8') as f:
                json.dump(restore_metadata, f, ensure_ascii=False, indent=2)
            
            print(f"📝 Thông tin restore: {restore_file}")
            return True
            
        except Exception as e:
            print(f"❌ Lỗi restore: {e}")
            return False
    
    def list_backups(self):
        """Liệt kê các backup có sẵn"""
        if not os.path.exists(self.backup_dir):
            print("❌ Không có backup nào")
            return []
        
        backups = []
        for item in os.listdir(self.backup_dir):
            if item.startswith("qr_backup_"):
                backup_path = os.path.join(self.backup_dir, item)
                if os.path.isdir(backup_path):
                    backups.append(backup_path)
        
        backups.sort(reverse=True)  # Mới nhất trước
        
        print("📁 Danh sách backup:")
        for i, backup in enumerate(backups, 1):
            print(f"  {i}. {os.path.basename(backup)}")
        
        return backups

def main():
    backup_tool = QRCodeBackup()
    
    print("🔧 QR Code Backup/Restore Tool")
    print("=" * 40)
    
    # Đăng nhập
    if not backup_tool.login():
        return
    
    while True:
        print("\n📋 Menu:")
        print("1. Backup QR codes")
        print("2. Restore QR codes")
        print("3. List backups")
        print("4. Exit")
        
        choice = input("\nChọn (1-4): ").strip()
        
        if choice == "1":
            backup_path = backup_tool.backup_qr_codes()
            if backup_path:
                print(f"\n✅ Backup thành công: {backup_path}")
        
        elif choice == "2":
            backups = backup_tool.list_backups()
            if not backups:
                continue
            
            try:
                idx = int(input("Chọn backup (số): ")) - 1
                if 0 <= idx < len(backups):
                    backup_tool.restore_qr_codes(backups[idx])
                else:
                    print("❌ Số không hợp lệ")
            except ValueError:
                print("❌ Vui lòng nhập số")
        
        elif choice == "3":
            backup_tool.list_backups()
        
        elif choice == "4":
            print("👋 Tạm biệt!")
            break
        
        else:
            print("❌ Lựa chọn không hợp lệ")

if __name__ == "__main__":
    main()
