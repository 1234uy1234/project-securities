from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from datetime import datetime, timedelta, timezone
from ..database import get_db
from ..auth import require_manager_or_admin
from ..models import User, UserRole, Location, PatrolTask, PatrolRecord, TaskStatus

router = APIRouter(prefix="/stats", tags=["stats"]) 

@router.get("/overview")
async def get_overview(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_manager_or_admin())
):
    now = datetime.now(timezone(timedelta(hours=7)))
    start_today = datetime(now.year, now.month, now.day)
    start_week = start_today - timedelta(days=start_today.weekday())

    total_users = db.query(func.count(User.id)).scalar() or 0
    total_employees = db.query(func.count(User.id)).filter(User.role == UserRole.EMPLOYEE).scalar() or 0
    total_managers = db.query(func.count(User.id)).filter(User.role == UserRole.MANAGER).scalar() or 0
    total_locations = db.query(func.count(Location.id)).scalar() or 0

    total_tasks = db.query(func.count(PatrolTask.id)).scalar() or 0
    pending_tasks = db.query(func.count(PatrolTask.id)).filter(PatrolTask.status == TaskStatus.PENDING).scalar() or 0
    in_progress_tasks = db.query(func.count(PatrolTask.id)).filter(PatrolTask.status == TaskStatus.IN_PROGRESS).scalar() or 0
    completed_tasks = db.query(func.count(PatrolTask.id)).filter(PatrolTask.status == TaskStatus.COMPLETED).scalar() or 0

    records_today = db.query(func.count(PatrolRecord.id)).filter(PatrolRecord.check_in_time >= start_today).scalar() or 0
    records_week = db.query(func.count(PatrolRecord.id)).filter(PatrolRecord.check_in_time >= start_week).scalar() or 0

    return {
        "users": {
            "total": total_users,
            "employees": total_employees,
            "managers": total_managers,
        },
        "locations": total_locations,
        "tasks": {
            "total": total_tasks,
            "pending": pending_tasks,
            "in_progress": in_progress_tasks,
            "completed": completed_tasks,
        },
        "records": {
            "today": records_today,
            "week": records_week,
        }
    }
