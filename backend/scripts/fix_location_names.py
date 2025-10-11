#!/usr/bin/env python3
"""
Script sửa tên locations bị lỗi debug info
"""

import os
import sys
import re
from sqlalchemy import create_engine, text

# Thêm đường dẫn backend vào sys.path
backend_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(backend_path)

from app.database import database_url

def fix_location_names():
    """Sửa tên locations bị lỗi debug info"""
    
    # Kết nối database
    engine = create_engine(database_url)
    
    try:
        with engine.connect() as conn:
            # Tìm các locations có tên bị lỗi
            result = conn.execute(text("""
                SELECT id, name 
                FROM locations 
                WHERE name LIKE '%location_id=%'
                ORDER BY id
            """))
            
            locations_to_fix = result.fetchall()
            print(f"Found {len(locations_to_fix)} locations with debug info in names")
            
            for loc in locations_to_fix:
                old_name = loc[1]
                # Extract clean name from debug string
                match = re.search(r"location_id='([^']+)'", old_name)
                if match:
                    new_name = match.group(1)
                    print(f"Fixing location {loc[0]}: '{old_name}' -> '{new_name}'")
                    
                    # Update location name
                    conn.execute(text("""
                        UPDATE locations 
                        SET name = :new_name, address = :new_name
                        WHERE id = :location_id
                    """), {
                        'new_name': new_name,
                        'location_id': loc[0]
                    })
                else:
                    print(f"Could not parse location {loc[0]}: '{old_name}'")
            
            # Commit changes
            conn.commit()
            print("✅ Location names fixed successfully!")
            
            # Verify fixes
            result = conn.execute(text("""
                SELECT id, name 
                FROM locations 
                WHERE name LIKE '%location_id=%'
                ORDER BY id
            """))
            
            remaining_bad = result.fetchall()
            if remaining_bad:
                print(f"⚠️  Still {len(remaining_bad)} locations with debug info:")
                for loc in remaining_bad:
                    print(f"  ID {loc[0]}: '{loc[1]}'")
            else:
                print("✅ All location names are clean!")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False
    
    return True

if __name__ == "__main__":
    print("🔧 Fixing location names...")
    success = fix_location_names()
    if success:
        print("✅ Location names fix completed!")
    else:
        print("❌ Location names fix failed!")
        sys.exit(1)
