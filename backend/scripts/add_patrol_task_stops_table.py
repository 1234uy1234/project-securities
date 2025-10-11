"""Quick migration: create patrol_task_stops table if missing."""
import sqlalchemy
from app.config import settings

def run():
    engine = sqlalchemy.create_engine(settings.database_url.replace('localhost','127.0.0.1'))
    with engine.connect() as conn:
        try:
            conn.execute(sqlalchemy.text('''
            CREATE TABLE IF NOT EXISTS patrol_task_stops (
                id serial PRIMARY KEY,
                task_id integer NOT NULL REFERENCES patrol_tasks(id),
                location_id integer NOT NULL REFERENCES locations(id),
                sequence integer DEFAULT 0,
                required boolean DEFAULT true
            )
            '''))
            print('Migration applied: patrol_task_stops ensured')
        except Exception as e:
            print('Migration error:', e)

if __name__ == '__main__':
    run()
