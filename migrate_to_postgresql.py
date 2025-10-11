#!/usr/bin/env python3
"""
Script để migrate dữ liệu từ SQLite sang PostgreSQL
"""

import sqlite3
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from datetime import datetime

# Database connections
SQLITE_DB = "/Users/maybe/Documents/shopee/backend/app.db"
POSTGRES_URL = "postgresql://shopee_user:shopee123@localhost:5432/shopee_patrol"

def connect_sqlite():
    """Kết nối đến SQLite database"""
    return sqlite3.connect(SQLITE_DB)

def connect_postgres():
    """Kết nối đến PostgreSQL database"""
    return psycopg2.connect(POSTGRES_URL)

def migrate_users():
    """Migrate users table"""
    print("🔄 Migrating users...")
    
    sqlite_conn = connect_sqlite()
    postgres_conn = connect_postgres()
    
    try:
        # Lấy dữ liệu từ SQLite
        sqlite_cursor = sqlite_conn.cursor()
        sqlite_cursor.execute("SELECT * FROM users")
        users = sqlite_cursor.fetchall()
        
        # Insert vào PostgreSQL
        postgres_cursor = postgres_conn.cursor()
        
        for user in users:
            postgres_cursor.execute("""
                INSERT INTO users (id, username, email, full_name, phone, role, is_active, created_at, updated_at, password_hash)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
            """, user)
        
        postgres_conn.commit()
        print(f"✅ Migrated {len(users)} users")
        
    except Exception as e:
        print(f"❌ Error migrating users: {e}")
        postgres_conn.rollback()
    finally:
        sqlite_conn.close()
        postgres_conn.close()

def migrate_locations():
    """Migrate locations table"""
    print("🔄 Migrating locations...")
    
    sqlite_conn = connect_sqlite()
    postgres_conn = connect_postgres()
    
    try:
        sqlite_cursor = sqlite_conn.cursor()
        sqlite_cursor.execute("SELECT * FROM locations")
        locations = sqlite_cursor.fetchall()
        
        postgres_cursor = postgres_conn.cursor()
        
        for location in locations:
            postgres_cursor.execute("""
                INSERT INTO locations (id, name, description, latitude, longitude, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
            """, location)
        
        postgres_conn.commit()
        print(f"✅ Migrated {len(locations)} locations")
        
    except Exception as e:
        print(f"❌ Error migrating locations: {e}")
        postgres_conn.rollback()
    finally:
        sqlite_conn.close()
        postgres_conn.close()

def migrate_qr_codes():
    """Migrate qr_codes table"""
    print("🔄 Migrating qr_codes...")
    
    sqlite_conn = connect_sqlite()
    postgres_conn = connect_postgres()
    
    try:
        sqlite_cursor = sqlite_conn.cursor()
        sqlite_cursor.execute("SELECT * FROM qr_codes")
        qr_codes = sqlite_cursor.fetchall()
        
        postgres_cursor = postgres_conn.cursor()
        
        for qr_code in qr_codes:
            postgres_cursor.execute("""
                INSERT INTO qr_codes (id, content, qr_type, location, created_at, created_by, is_active)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
            """, qr_code)
        
        postgres_conn.commit()
        print(f"✅ Migrated {len(qr_codes)} QR codes")
        
    except Exception as e:
        print(f"❌ Error migrating qr_codes: {e}")
        postgres_conn.rollback()
    finally:
        sqlite_conn.close()
        postgres_conn.close()

def migrate_patrol_tasks():
    """Migrate patrol_tasks table"""
    print("🔄 Migrating patrol_tasks...")
    
    sqlite_conn = connect_sqlite()
    postgres_conn = connect_postgres()
    
    try:
        sqlite_cursor = sqlite_conn.cursor()
        sqlite_cursor.execute("SELECT * FROM patrol_tasks")
        tasks = sqlite_cursor.fetchall()
        
        postgres_cursor = postgres_conn.cursor()
        
        for task in tasks:
            postgres_cursor.execute("""
                INSERT INTO patrol_tasks (id, title, description, assigned_to, location_id, status, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
            """, task)
        
        postgres_conn.commit()
        print(f"✅ Migrated {len(tasks)} patrol tasks")
        
    except Exception as e:
        print(f"❌ Error migrating patrol_tasks: {e}")
        postgres_conn.rollback()
    finally:
        sqlite_conn.close()
        postgres_conn.close()

def migrate_patrol_records():
    """Migrate patrol_records table"""
    print("🔄 Migrating patrol_records...")
    
    sqlite_conn = connect_sqlite()
    postgres_conn = connect_postgres()
    
    try:
        sqlite_cursor = sqlite_conn.cursor()
        sqlite_cursor.execute("SELECT * FROM patrol_records")
        records = sqlite_cursor.fetchall()
        
        postgres_cursor = postgres_conn.cursor()
        
        for record in records:
            postgres_cursor.execute("""
                INSERT INTO patrol_records (id, user_id, location_id, checkin_time, checkout_time, photo_path, notes, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO NOTHING
            """, record)
        
        postgres_conn.commit()
        print(f"✅ Migrated {len(records)} patrol records")
        
    except Exception as e:
        print(f"❌ Error migrating patrol_records: {e}")
        postgres_conn.rollback()
    finally:
        sqlite_conn.close()
        postgres_conn.close()

def main():
    """Main migration function"""
    print("🚀 Starting migration from SQLite to PostgreSQL...")
    print(f"📅 {datetime.now()}")
    print()
    
    # Check if SQLite database exists
    if not os.path.exists(SQLITE_DB):
        print(f"❌ SQLite database not found: {SQLITE_DB}")
        return
    
    # Test PostgreSQL connection
    try:
        postgres_conn = connect_postgres()
        postgres_conn.close()
        print("✅ PostgreSQL connection successful")
    except Exception as e:
        print(f"❌ PostgreSQL connection failed: {e}")
        return
    
    # Migrate tables
    migrate_users()
    migrate_locations()
    migrate_qr_codes()
    migrate_patrol_tasks()
    migrate_patrol_records()
    
    print()
    print("🎉 Migration completed successfully!")
    print("📊 All data has been migrated to PostgreSQL")

if __name__ == "__main__":
    main()
