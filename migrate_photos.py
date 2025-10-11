#!/usr/bin/env python3
"""
Migrate existing photos from files to base64 in database
"""

import sqlite3
import base64
import os
from pathlib import Path

def migrate_photos():
    db_path = "/Users/maybe/Documents/shopee/app.db"
    uploads_dir = "/Users/maybe/Documents/shopee/backend/uploads"
    
    # Connect to database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get all records with photo_path but no photo_base64
    cursor.execute("""
        SELECT id, photo_path 
        FROM patrol_records 
        WHERE photo_path IS NOT NULL 
        AND photo_base64 IS NULL
    """)
    
    records = cursor.fetchall()
    print(f"Found {len(records)} records to migrate")
    
    for record_id, photo_path in records:
        try:
            # Extract filename from path
            if photo_path and '/' in photo_path:
                filename = photo_path.split('/')[-1]
            else:
                filename = photo_path
            
            # Full path to photo file
            full_path = os.path.join(uploads_dir, filename)
            
            if os.path.exists(full_path):
                # Read photo file and convert to base64
                with open(full_path, 'rb') as f:
                    photo_data = f.read()
                    photo_base64 = base64.b64encode(photo_data).decode('utf-8')
                    # Add data URL prefix
                    photo_base64 = f"data:image/jpeg;base64,{photo_base64}"
                
                # Update database
                cursor.execute("""
                    UPDATE patrol_records 
                    SET photo_base64 = ? 
                    WHERE id = ?
                """, (photo_base64, record_id))
                
                print(f"✅ Migrated record {record_id}: {filename}")
            else:
                print(f"⚠️ File not found: {full_path}")
                
        except Exception as e:
            print(f"❌ Error migrating record {record_id}: {e}")
    
    # Commit changes
    conn.commit()
    conn.close()
    
    print("🎉 Migration completed!")

if __name__ == "__main__":
    migrate_photos()
