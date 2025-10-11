#!/usr/bin/env python3
"""
Script tự động restore QR codes
"""

import os
import shutil
import json
import requests
from datetime import datetime

def restore_qr_codes(backup_path=None):
    """Restore QR codes từ backup"""
    
    # Tìm backup mới nhất nếu không chỉ định
    if not backup_path:
        backup_dir = "qr_backup"
        if not os.path.exists(backup_dir):
            print("❌ Không có backup nào")
            return False
        
        backups = []
        for item in os.listdir(backup_dir):
            if item.startswith("qr_backup_"):
                backup_path_candidate = os.path.join(backup_dir, item)
                if os.path.isdir(backup_path_candidate):
                    backups.append(backup_path_candidate)
        
        if not backups:
            print("❌ Không có backup nào")
            return False
        
        backups.sort(reverse=True)  # Mới nhất trước
        backup_path = backups[0]
        print(f"📁 Sử dụng backup mới nhất: {os.path.basename(backup_path)}")
    
    print(f"🔄 Bắt đầu restore từ: {backup_path}")
    
    try:
        # Đọc restore info
        restore_info_file = os.path.join(backup_path, "restore_info.json")
        with open(restore_info_file, 'r', encoding='utf-8') as f:
            restore_info = json.load(f)
        
        print(f"📊 Backup info: {restore_info['total_qr_codes']} QR codes, {restore_info['copied_files']} files")
        
        # Restore files
        qr_files_dir = os.path.join(backup_path, "qr_files")
        qr_codes_dir = "backend/uploads/qr_codes"
        os.makedirs(qr_codes_dir, exist_ok=True)
        
        restored_count = 0
        for filename in os.listdir(qr_files_dir):
            if filename.endswith('.png'):
                src_path = os.path.join(qr_files_dir, filename)
                dst_path = os.path.join(qr_codes_dir, filename)
                
                shutil.copy2(src_path, dst_path)
                print(f"✅ Restored: {filename}")
                restored_count += 1
        
        print(f"✅ Restore files hoàn thành: {restored_count} files")
        
        # Đọc metadata để có thể import vào database
        metadata_file = os.path.join(backup_path, "qr_codes_metadata.json")
        with open(metadata_file, 'r', encoding='utf-8') as f:
            qr_codes = json.load(f)
        
        print(f"📝 Metadata có sẵn: {len(qr_codes)} QR codes")
        print("💡 Để import vào database, chạy: python3 qr_import_tool.py")
        
        return True
        
    except Exception as e:
        print(f"❌ Lỗi restore: {e}")
        return False

def list_backups():
    """Liệt kê các backup có sẵn"""
    backup_dir = "qr_backup"
    if not os.path.exists(backup_dir):
        print("❌ Không có backup nào")
        return []
    
    backups = []
    for item in os.listdir(backup_dir):
        if item.startswith("qr_backup_"):
            backup_path = os.path.join(backup_dir, item)
            if os.path.isdir(backup_path):
                backups.append(backup_path)
    
    backups.sort(reverse=True)  # Mới nhất trước
    
    print("📁 Danh sách backup:")
    for i, backup in enumerate(backups, 1):
        print(f"  {i}. {os.path.basename(backup)}")
    
    return backups

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "list":
            list_backups()
        else:
            restore_qr_codes(sys.argv[1])
    else:
        restore_qr_codes()
