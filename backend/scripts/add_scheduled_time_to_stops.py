#!/usr/bin/env python3
"""
Migration script to add scheduled_time column to patrol_task_stops table
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import create_engine, text
from app.config import settings

def run():
    try:
        database_url = settings.database_url.replace("localhost", "127.0.0.1")
        engine = create_engine(database_url)
        
        with engine.connect() as conn:
            # Check if column already exists
            result = conn.execute(text("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = 'patrol_task_stops' 
                AND column_name = 'scheduled_time'
            """))
            
            if result.fetchone():
                print('Column scheduled_time already exists in patrol_task_stops table')
                return
            
            # Add scheduled_time column
            conn.execute(text("""
                ALTER TABLE patrol_task_stops 
                ADD COLUMN scheduled_time TIME
            """))
            
            conn.commit()
            print('✅ Successfully added scheduled_time column to patrol_task_stops table')
            
    except Exception as e:
        print('Migration error:', e)

if __name__ == '__main__':
    run()
