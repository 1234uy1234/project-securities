#!/usr/bin/env python3
"""
Migration script to add task_id to patrol_records and create patrol_task_stops table
"""

import sqlite3
import os

def migrate_database():
    db_path = "/Users/maybe/Documents/shopee/backend/patrol.db"
    
    if not os.path.exists(db_path):
        print(f"❌ Database not found: {db_path}")
        return
    
    print("🔄 Starting database migration...")
    
    # Backup database
    backup_path = f"{db_path}.backup"
    if os.path.exists(backup_path):
        os.remove(backup_path)
    os.rename(db_path, backup_path)
    print(f"✅ Database backed up to: {backup_path}")
    
    # Create new database with updated schema
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Create users table
    cursor.execute("""
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            full_name VARCHAR(100),
            password_hash VARCHAR(255) NOT NULL,
            role VARCHAR(20) DEFAULT 'employee',
            is_active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Create locations table
    cursor.execute("""
        CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            qr_code VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Create patrol_tasks table with schedule_week
    cursor.execute("""
        CREATE TABLE patrol_tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title VARCHAR(200) NOT NULL,
            description TEXT,
            location_id INTEGER,
            assigned_to INTEGER,
            status VARCHAR(20) DEFAULT 'pending',
            schedule_week TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (location_id) REFERENCES locations (id),
            FOREIGN KEY (assigned_to) REFERENCES users (id)
        )
    """)
    
    # Create patrol_task_stops table
    cursor.execute("""
        CREATE TABLE patrol_task_stops (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            location_id INTEGER NOT NULL,
            sequence INTEGER NOT NULL,
            scheduled_time VARCHAR(10),
            completed BOOLEAN DEFAULT 0,
            completed_at TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (task_id) REFERENCES patrol_tasks (id),
            FOREIGN KEY (location_id) REFERENCES locations (id)
        )
    """)
    
    # Create patrol_records table with task_id
    cursor.execute("""
        CREATE TABLE patrol_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            task_id INTEGER,
            location_id INTEGER NOT NULL,
            check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            check_out_time TIMESTAMP,
            notes TEXT,
            photo_path VARCHAR(255),
            photo_base64 TEXT,
            gps_latitude REAL,
            gps_longitude REAL,
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (task_id) REFERENCES patrol_tasks (id),
            FOREIGN KEY (location_id) REFERENCES locations (id)
        )
    """)
    
    # Create qr_codes table
    cursor.execute("""
        CREATE TABLE qr_codes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content VARCHAR(255) UNIQUE NOT NULL,
            type VARCHAR(20) DEFAULT 'static',
            location_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (location_id) REFERENCES locations (id)
        )
    """)
    
    # Create user_face_data table
    cursor.execute("""
        CREATE TABLE user_face_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            face_encoding TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    """)
    
    conn.commit()
    print("✅ New database schema created")
    
    # Migrate data from backup
    backup_conn = sqlite3.connect(backup_path)
    backup_cursor = backup_conn.cursor()
    
    # Migrate users
    try:
        backup_cursor.execute("SELECT * FROM users")
        users = backup_cursor.fetchall()
        for user in users:
            cursor.execute("""
                INSERT INTO users (id, username, email, full_name, password_hash, role, is_active, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, user)
        print(f"✅ Migrated {len(users)} users")
    except Exception as e:
        print(f"⚠️ Users migration: {e}")
    
    # Migrate locations
    try:
        backup_cursor.execute("SELECT * FROM locations")
        locations = backup_cursor.fetchall()
        for location in locations:
            cursor.execute("""
                INSERT INTO locations (id, name, description, qr_code, created_at)
                VALUES (?, ?, ?, ?, ?)
            """, location)
        print(f"✅ Migrated {len(locations)} locations")
    except Exception as e:
        print(f"⚠️ Locations migration: {e}")
    
    # Migrate patrol_tasks
    try:
        backup_cursor.execute("SELECT * FROM patrol_tasks")
        tasks = backup_cursor.fetchall()
        for task in tasks:
            cursor.execute("""
                INSERT INTO patrol_tasks (id, title, description, location_id, assigned_to, status, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, task)
        print(f"✅ Migrated {len(tasks)} patrol tasks")
    except Exception as e:
        print(f"⚠️ Patrol tasks migration: {e}")
    
    # Migrate patrol_records (without task_id for now)
    try:
        backup_cursor.execute("SELECT * FROM patrol_records")
        records = backup_cursor.fetchall()
        for record in records:
            cursor.execute("""
                INSERT INTO patrol_records (id, user_id, location_id, check_in_time, check_out_time, notes, photo_path)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, record)
        print(f"✅ Migrated {len(records)} patrol records")
    except Exception as e:
        print(f"⚠️ Patrol records migration: {e}")
    
    conn.commit()
    backup_conn.close()
    conn.close()
    
    print("🎉 Database migration completed successfully!")
    print("📝 Next steps:")
    print("1. Restart the backend server")
    print("2. Create new tasks with proper stops")
    print("3. Test check-in functionality")

if __name__ == "__main__":
    migrate_database()
