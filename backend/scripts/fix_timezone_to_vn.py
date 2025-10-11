"""
One-off script: Normalize historical timestamps to Vietnam time (UTC+7).

Strategy (idempotent-ish):
- Shift +7 hours for rows whose hour-of-day is between 0..7 (likely UTC-stored times)
- Applies to patrol_records.check_in_time, check_out_time, created_at
- Applies to patrol_tasks.created_at, updated_at

Run:  python backend/scripts/fix_timezone_to_vn.py
"""
from sqlalchemy import create_engine, text
from pathlib import Path
import os

# Try to reuse the project's database URL if available
def load_database_url() -> str:
    # Prefer DATABASE_URL env if present
    db_url = os.getenv("DATABASE_URL")
    if db_url:
        return db_url

    # Fallback: read from backend/app/config.py settings.database_url
    # We avoid importing app.config to keep this as a standalone utility
    # Allow user to set via environment for safety
    raise RuntimeError("Please set DATABASE_URL env var to run this script.")


QUERIES = [
    # Patrol records: check_in_time
    """
    UPDATE patrol_records
    SET check_in_time = check_in_time + INTERVAL '7 hours'
    WHERE check_in_time IS NOT NULL
      AND EXTRACT(HOUR FROM check_in_time) BETWEEN 0 AND 7;
    """,
    # Patrol records: check_out_time
    """
    UPDATE patrol_records
    SET check_out_time = check_out_time + INTERVAL '7 hours'
    WHERE check_out_time IS NOT NULL
      AND EXTRACT(HOUR FROM check_out_time) BETWEEN 0 AND 7;
    """,
    # Patrol records: created_at if exists
    """
    UPDATE patrol_records
    SET created_at = created_at + INTERVAL '7 hours'
    WHERE created_at IS NOT NULL
      AND EXTRACT(HOUR FROM created_at) BETWEEN 0 AND 7;
    """,
    # Patrol tasks: created_at
    """
    UPDATE patrol_tasks
    SET created_at = created_at + INTERVAL '7 hours'
    WHERE created_at IS NOT NULL
      AND EXTRACT(HOUR FROM created_at) BETWEEN 0 AND 7;
    """,
    # Patrol tasks: updated_at
    """
    UPDATE patrol_tasks
    SET updated_at = updated_at + INTERVAL '7 hours'
    WHERE updated_at IS NOT NULL
      AND EXTRACT(HOUR FROM updated_at) BETWEEN 0 AND 7;
    """,
]


def main() -> None:
    db_url = load_database_url()
    engine = create_engine(db_url)
    with engine.begin() as conn:
        for i, q in enumerate(QUERIES, start=1):
            conn.execute(text(q))
            print(f"[OK] Applied step {i}")
    print("All timezone normalization steps completed.")


if __name__ == "__main__":
    main()


