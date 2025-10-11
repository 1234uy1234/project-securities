#!/usr/bin/env python3
"""
Script tự động backup QR codes
"""

import os
import shutil
import json
import requests
from datetime import datetime

def backup_qr_codes():
    """Backup QR codes tự động"""
    print("🔄 Bắt đầu backup QR codes...")
    
    api_base_url = "https://localhost:8000/api"
    
    # Đăng nhập
    try:
        response = requests.post(
            f"{api_base_url}/auth/login",
            json={"username": "admin", "password": "admin123"},
            verify=False
        )
        response.raise_for_status()
        token = response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        print("✅ Đăng nhập thành công")
    except Exception as e:
        print(f"❌ Lỗi đăng nhập: {e}")
        return False
    
    # Tạo thư mục backup
    backup_dir = "qr_backup"
    os.makedirs(backup_dir, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(backup_dir, f"qr_backup_{timestamp}")
    os.makedirs(backup_path, exist_ok=True)
    
    try:
        # Lấy danh sách QR codes từ API
        response = requests.get(
            f"{api_base_url}/qr-codes/",
            headers=headers,
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
        
        qr_codes_dir = "backend/uploads/qr_codes"
        copied_count = 0
        
        for qr in qr_codes:
            filename = qr["filename"]
            src_path = os.path.join(qr_codes_dir, filename)
            dst_path = os.path.join(qr_files_dir, filename)
            
            if os.path.exists(src_path):
                shutil.copy2(src_path, dst_path)
                print(f"✅ Copied: {filename}")
                copied_count += 1
            else:
                print(f"⚠️ File not found: {filename}")
        
        # Tạo restore info
        restore_info = {
            "backup_time": datetime.now().isoformat(),
            "total_qr_codes": len(qr_codes),
            "copied_files": copied_count,
            "api_base_url": api_base_url,
            "note": "Backup tự động - có thể restore khi đổi IP"
        }
        
        restore_file = os.path.join(backup_path, "restore_info.json")
        with open(restore_file, 'w', encoding='utf-8') as f:
            json.dump(restore_info, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Backup hoàn thành: {backup_path}")
        print(f"📊 Tổng cộng: {len(qr_codes)} QR codes")
        print(f"📁 Files copied: {copied_count}")
        print(f"📝 Metadata: {metadata_file}")
        print(f"📝 Restore info: {restore_file}")
        
        return backup_path
        
    except Exception as e:
        print(f"❌ Lỗi backup: {e}")
        return None

if __name__ == "__main__":
    backup_qr_codes()
