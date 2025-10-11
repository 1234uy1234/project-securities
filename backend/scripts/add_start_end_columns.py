"""Quick migration: add start_time and end_time to patrol_tasks if missing."""
import sqlalchemy
from app.config import settings

def run():
    engine = sqlalchemy.create_engine(settings.database_url.replace('localhost','127.0.0.1'))
    with engine.connect() as conn:
        # Add start_time
        try:
            conn.execute(sqlalchemy.text("ALTER TABLE patrol_tasks ADD COLUMN IF NOT EXISTS start_time timestamptz"))
            conn.execute(sqlalchemy.text("ALTER TABLE patrol_tasks ADD COLUMN IF NOT EXISTS end_time timestamptz"))
            print('Migration applied: start_time and end_time ensured')
        except Exception as e:
            print('Migration error:', e)

if __name__ == '__main__':
    run()
