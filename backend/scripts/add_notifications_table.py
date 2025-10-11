#!/usr/bin/env python3
"""Quick migration helper: create notifications table if not exists"""
from sqlalchemy import text
from app.database import engine

sql = """
CREATE TABLE IF NOT EXISTS notifications (
  id serial PRIMARY KEY,
  user_id integer NOT NULL REFERENCES users(id),
  title varchar(255) NOT NULL,
  message text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);
"""

with engine.connect() as conn:
    conn.execute(text(sql))
    conn.commit()

print("Notifications table ensured")
