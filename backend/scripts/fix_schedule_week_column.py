#!/usr/bin/env python3
"""
Script để mở rộng cột schedule_week trong bảng patrol_tasks
"""

import os
import sys
import asyncio
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Thêm đường dẫn backend vào sys.path
backend_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(backend_path)

from app.database import database_url

async def fix_schedule_week_column():
    """Mở rộng cột schedule_week để chứa JSON string dài hơn"""
    
    # Kết nối database
    engine = create_engine(database_url)
    
    try:
        with engine.connect() as conn:
            # Kiểm tra cột hiện tại
            result = conn.execute(text("""
                SELECT column_name, data_type, character_maximum_length 
                FROM information_schema.columns 
                WHERE table_name = 'patrol_tasks' 
                AND column_name = 'schedule_week'
            """))
            
            column_info = result.fetchone()
            if column_info:
                print(f"Current schedule_week column: {column_info[1]} (max length: {column_info[2]})")
            
            # Mở rộng cột schedule_week thành TEXT để chứa JSON
            print("Expanding schedule_week column to TEXT...")
            conn.execute(text("""
                ALTER TABLE patrol_tasks 
                ALTER COLUMN schedule_week TYPE TEXT
            """))
            
            # Commit thay đổi
            conn.commit()
            print("✅ Successfully expanded schedule_week column to TEXT")
            
            # Kiểm tra lại
            result = conn.execute(text("""
                SELECT column_name, data_type, character_maximum_length 
                FROM information_schema.columns 
                WHERE table_name = 'patrol_tasks' 
                AND column_name = 'schedule_week'
            """))
            
            column_info = result.fetchone()
            if column_info:
                print(f"Updated schedule_week column: {column_info[1]} (max length: {column_info[2]})")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False
    
    return True

if __name__ == "__main__":
    print("🔧 Fixing schedule_week column...")
    success = asyncio.run(fix_schedule_week_column())
    if success:
        print("✅ Database fix completed successfully!")
    else:
        print("❌ Database fix failed!")
        sys.exit(1)
