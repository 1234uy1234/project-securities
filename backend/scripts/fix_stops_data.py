#!/usr/bin/env python3
"""
Script to fix stops data that might be stored as raw strings
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
            # Check current data
            result = conn.execute(text("""
                SELECT id, location_name, scheduled_time 
                FROM patrol_task_stops 
                ORDER BY id
            """))
            
            print("Current stops data:")
            for row in result:
                print(f'ID: {row[0]}, Name: "{row[1]}", Time: "{row[2]}"')
            
            # Check if there are any stops with raw data format
            result = conn.execute(text("""
                SELECT id, location_name, scheduled_time 
                FROM patrol_task_stops 
                WHERE location_name LIKE '%location_id%' 
                OR location_name LIKE '%scheduled_time%'
                OR location_name LIKE '%required%'
            """))
            
            raw_data_stops = result.fetchall()
            print(f"\nFound {len(raw_data_stops)} stops with raw data format")
            
            if raw_data_stops:
                print("Raw data stops:")
                for row in raw_data_stops:
                    print(f'ID: {row[0]}, Name: "{row[1]}", Time: "{row[2]}"')
                
                # Delete these problematic stops
                conn.execute(text("""
                    DELETE FROM patrol_task_stops 
                    WHERE location_name LIKE '%location_id%' 
                    OR location_name LIKE '%scheduled_time%'
                    OR location_name LIKE '%required%'
                """))
                
                conn.commit()
                print(f"✅ Deleted {len(raw_data_stops)} problematic stops")
            else:
                print("No raw data stops found")
                
    except Exception as e:
        print('Error:', e)

if __name__ == '__main__':
    run()
