#!/usr/bin/env python3
"""
Script để import QR codes vào database sau khi restore
"""

import os
import json
import requests
from datetime import datetime

class QRCodeImporter:
    def __init__(self, api_base_url="https://localhost:8000/api"):
        self.api_base_url = api_base_url
        
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
    
    def import_qr_codes(self, restore_info_file):
        """Import QR codes từ restore info vào database"""
        print(f"🔄 Bắt đầu import từ: {restore_info_file}")
        
        try:
            with open(restore_info_file, 'r', encoding='utf-8') as f:
                restore_data = json.load(f)
            
            qr_codes = restore_data["qr_codes"]
            imported_count = 0
            
            for qr in qr_codes:
                try:
                    # Tạo QR code mới trong database
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
                        print(f"✅ Imported: {qr['data']} -> ID {new_qr['id']}")
                        imported_count += 1
                    else:
                        print(f"⚠️ Failed to import: {qr['data']} - {response.text}")
                        
                except Exception as e:
                    print(f"❌ Error importing {qr['data']}: {e}")
            
            print(f"✅ Import hoàn thành: {imported_count}/{len(qr_codes)} QR codes")
            return True
            
        except Exception as e:
            print(f"❌ Lỗi import: {e}")
            return False
    
    def check_existing_qr_codes(self):
        """Kiểm tra QR codes hiện có trong database"""
        try:
            response = requests.get(
                f"{self.api_base_url}/qr-codes/",
                headers=self.headers,
                verify=False
            )
            response.raise_for_status()
            qr_codes = response.json()
            
            print(f"📊 QR codes hiện có trong database: {len(qr_codes)}")
            for qr in qr_codes:
                print(f"  - ID {qr['id']}: {qr['data']} ({qr['type']})")
            
            return qr_codes
            
        except Exception as e:
            print(f"❌ Lỗi kiểm tra: {e}")
            return []

def main():
    importer = QRCodeImporter()
    
    print("🔧 QR Code Database Importer")
    print("=" * 40)
    
    # Đăng nhập
    if not importer.login():
        return
    
    # Kiểm tra QR codes hiện có
    print("\n📋 QR codes hiện có:")
    importer.check_existing_qr_codes()
    
    # Tìm restore info files
    backup_dir = "qr_backup"
    restore_files = []
    
    if os.path.exists(backup_dir):
        for root, dirs, files in os.walk(backup_dir):
            for file in files:
                if file == "restore_info.json":
                    restore_files.append(os.path.join(root, file))
    
    if not restore_files:
        print("\n❌ Không tìm thấy restore_info.json files")
        return
    
    print(f"\n📁 Tìm thấy {len(restore_files)} restore files:")
    for i, file in enumerate(restore_files, 1):
        print(f"  {i}. {file}")
    
    try:
        idx = int(input("\nChọn restore file (số): ")) - 1
        if 0 <= idx < len(restore_files):
            importer.import_qr_codes(restore_files[idx])
        else:
            print("❌ Số không hợp lệ")
    except ValueError:
        print("❌ Vui lòng nhập số")

if __name__ == "__main__":
    main()
