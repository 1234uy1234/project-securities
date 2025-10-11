#!/usr/bin/env python3
"""
Script để export dữ liệu từ SQLite sang JSON format
"""

import sqlite3
import json
import os
from datetime import datetime

SQLITE_DB = "/Users/maybe/Documents/shopee/backend/app.db"
EXPORT_DIR = "/Users/maybe/Documents/shopee/backups"

def export_table_to_json(table_name):
    """Export một table sang JSON"""
    conn = sqlite3.connect(SQLITE_DB)
    conn.row_factory = sqlite3.Row  # Để có thể access columns by name
    cursor = conn.cursor()
    
    try:
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()
        
        # Convert rows to list of dictionaries
        data = []
        for row in rows:
            data.append(dict(row))
        
        # Save to JSON file
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{table_name}_{timestamp}.json"
        filepath = os.path.join(EXPORT_DIR, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)
        
        print(f"✅ Exported {len(data)} records from {table_name} to {filename}")
        return filepath
        
    except Exception as e:
        print(f"❌ Error exporting {table_name}: {e}")
        return None
    finally:
        conn.close()

def export_all_data():
    """Export tất cả dữ liệu"""
    print("🚀 Starting data export...")
    print(f"📅 {datetime.now()}")
    print()
    
    # Tạo thư mục export nếu chưa có
    os.makedirs(EXPORT_DIR, exist_ok=True)
    
    # Danh sách các tables
    tables = [
        'users',
        'locations', 
        'qr_codes',
        'patrol_tasks',
        'patrol_records',
        'patrol_task_stops'
    ]
    
    exported_files = []
    
    for table in tables:
        filepath = export_table_to_json(table)
        if filepath:
            exported_files.append(filepath)
    
    print()
    print("🎉 Export completed!")
    print(f"📊 Exported {len(exported_files)} tables")
    print()
    print("📋 Exported files:")
    for filepath in exported_files:
        size = os.path.getsize(filepath)
        print(f"   - {os.path.basename(filepath)} ({size} bytes)")
    
    # Tạo summary file
    summary = {
        "export_date": datetime.now().isoformat(),
        "tables_exported": len(exported_files),
        "files": [os.path.basename(f) for f in exported_files]
    }
    
    summary_file = os.path.join(EXPORT_DIR, f"export_summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
    with open(summary_file, 'w', encoding='utf-8') as f:
        json.dump(summary, f, indent=2, ensure_ascii=False)
    
    print(f"📄 Summary saved to: {os.path.basename(summary_file)}")

if __name__ == "__main__":
    export_all_data()