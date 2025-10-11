#!/usr/bin/env python3

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def create_database():
    print("Creating database schema...")
    
    # Connect to database using psql
    commands = [
        "DROP TABLE IF EXISTS patrol_records, patrol_tasks, locations, users CASCADE;",
        """
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            full_name VARCHAR(100) NOT NULL,
            phone VARCHAR(20),
            role VARCHAR(20) NOT NULL DEFAULT 'employee',
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP
        );
        """,
        """
        CREATE TABLE locations (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            qr_code VARCHAR(255) UNIQUE NOT NULL,
            address VARCHAR(255),
            gps_latitude DECIMAL(10,8),
            gps_longitude DECIMAL(11,8),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP
        );
        """,
        """
        CREATE TABLE patrol_tasks (
            id SERIAL PRIMARY KEY,
            title VARCHAR(200) NOT NULL,
            description TEXT,
            location_id INTEGER REFERENCES locations(id),
            assigned_to INTEGER REFERENCES users(id),
            created_by INTEGER REFERENCES users(id),
            schedule_week VARCHAR(20) NOT NULL,
            status VARCHAR(20) DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP
        );
        """,
        """
        CREATE TABLE patrol_records (
            id SERIAL PRIMARY KEY,
            user_id INTEGER REFERENCES users(id),
            task_id INTEGER REFERENCES patrol_tasks(id),
            location_id INTEGER REFERENCES locations(id),
            check_in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            check_out_time TIMESTAMP,
            gps_latitude DECIMAL(10,8),
            gps_longitude DECIMAL(11,8),
            photo_url VARCHAR(255),
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP
        );
        """,
        """
        INSERT INTO users (username, email, password_hash, full_name, phone, role, is_active) 
        VALUES ('admin', 'admin@manhtoan.com', '$2b$12$XC0ZjDLx84RrOyhkjkyik.1NfWQNYxIkneQ/jyaWC3WhH4AikqjuO', 'Administrator', '0123456789', 'admin', true)
        ON CONFLICT (username) DO NOTHING;
        """
    ]
    
    for i, cmd in enumerate(commands):
        print(f"Executing command {i+1}/{len(commands)}...")
        os.system(f"psql -U postgres -d patrol_system -c \"{cmd}\"")
    
    print("Database schema created successfully!")

if __name__ == "__main__":
    create_database()
