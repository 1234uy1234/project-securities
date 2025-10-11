#!/usr/bin/env python3
"""
Script backup đơn giản - chỉ cần chạy để backup toàn bộ hệ thống
"""

import os
import sys
import subprocess
from datetime import datetime

def run_backup():
    """Chạy backup toàn diện"""
    print("🚀 Bắt đầu backup toàn diện hệ thống...")
    print(f"⏰ Thời gian: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    try:
        # Chạy script backup
        result = subprocess.run([sys.executable, "full_system_backup.py"], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Backup hoàn thành thành công!")
            print("\n📋 Output:")
            print(result.stdout)
        else:
            print("❌ Backup thất bại!")
            print("\n❌ Error:")
            print(result.stderr)
            
    except Exception as e:
        print(f"❌ Lỗi chạy backup: {e}")

def show_backup_status():
    """Hiển thị trạng thái backup"""
    backup_dir = "full_system_backup"
    
    if not os.path.exists(backup_dir):
        print("❌ Chưa có backup nào")
        return
    
    backups = []
    for item in os.listdir(backup_dir):
        if item.startswith("full_backup_"):
            backup_path = os.path.join(backup_dir, item)
            if os.path.isdir(backup_path):
                backups.append(backup_path)
    
    backups.sort(reverse=True)  # Mới nhất trước
    
    print("📁 Danh sách backup:")
    for i, backup in enumerate(backups, 1):
        backup_name = os.path.basename(backup)
        backup_time = backup_name.replace("full_backup_", "").replace("_", " ")
        print(f"  {i}. {backup_time}")
    
    if backups:
        latest = backups[0]
        info_file = os.path.join(latest, "backup_info.json")
        if os.path.exists(info_file):
            import json
            with open(info_file, 'r') as f:
                info = json.load(f)
            print(f"\n📊 Backup mới nhất:")
            print(f"  - Thời gian: {info['backup_time']}")
            print(f"  - QR codes: {info['database_summary']['qr_codes_count']}")
            print(f"  - Patrol records: {info['database_summary']['patrol_records_count']}")
            print(f"  - Tasks: {info['database_summary']['patrol_tasks_count']}")
            print(f"  - Locations: {info['database_summary']['locations_count']}")
            print(f"  - Files: {info['files_backed_up']}")

def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "status":
            show_backup_status()
        elif sys.argv[1] == "restore":
            if len(sys.argv) > 2:
                backup_path = sys.argv[2]
                print(f"🔄 Restore từ: {backup_path}")
                subprocess.run([sys.executable, "restore_full_system.py", backup_path])
            else:
                print("❌ Vui lòng chỉ định backup path")
                print("Usage: python3 backup.py restore <backup_path>")
        else:
            print("❌ Lệnh không hợp lệ")
            print("Usage: python3 backup.py [status|restore <path>]")
    else:
        run_backup()

if __name__ == "__main__":
    main()
