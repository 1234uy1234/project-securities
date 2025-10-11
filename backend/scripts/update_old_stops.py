#!/usr/bin/env python3
"""
Script to update old stops data to include scheduled_time
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
            # Check if there are stops without scheduled_time
            result = conn.execute(text("""
                SELECT COUNT(*) as count 
                FROM patrol_task_stops 
                WHERE scheduled_time IS NULL
            """))
            
            count = result.fetchone()[0]
            print(f'Found {count} stops without scheduled_time')
            
            if count > 0:
                # Update all stops without scheduled_time to have a default time
                # We'll set them to 09:00 as default
                conn.execute(text("""
                    UPDATE patrol_task_stops 
                    SET scheduled_time = '09:00' 
                    WHERE scheduled_time IS NULL
                """))
                
                conn.commit()
                print(f'✅ Updated {count} stops with default time 09:00')
            else:
                print('All stops already have scheduled_time')
                
    except Exception as e:
        print('Error:', e)

if __name__ == '__main__':
    run()
