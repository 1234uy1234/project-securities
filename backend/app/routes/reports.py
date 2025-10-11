from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin
from ..models import PatrolRecord, User, PatrolTask, Location
from ..schemas import PatrolRecord as PatrolRecordSchema
from sqlalchemy.orm import joinedload

router = APIRouter(prefix="/reports", tags=["reports"])

def format_vietnam_time(dt):
    """Format datetime to Vietnam timezone"""
    if not dt:
        return None
    if dt.tzinfo is None:
        # Check if this looks like UTC time (17:xx) or Vietnam time (10:xx)
        if dt.hour >= 17:
            # This looks like UTC time, convert to Vietnam time
            # But we want to show the correct Vietnam time, not UTC+7
            # If it's 17:31 UTC, we want to show 10:31 Vietnam time
            vietnam_dt = dt.replace(hour=dt.hour - 7)
            return vietnam_dt.replace(tzinfo=timezone(timedelta(hours=7))).isoformat()
        else:
            # This looks like Vietnam time, just add timezone
            return dt.replace(tzinfo=timezone(timedelta(hours=7))).isoformat()
    else:
        # Already has timezone info, just return as is
        return dt.isoformat()

@router.get("/patrol-records")
async def get_patrol_records_report(
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Lấy dữ liệu patrol records cho báo cáo - Admin/Manager only"""
    try:
        # Query cơ bản
        query = db.query(PatrolRecord)
        
        # Filter theo ngày nếu có
        if start_date:
            try:
                start_dt = datetime.strptime(start_date, "%Y-%m-%d").replace(tzinfo=timezone(timedelta(hours=7)))
                query = query.filter(PatrolRecord.check_in_time >= start_dt)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid start_date format. Use YYYY-MM-DD"
                )
        
        if end_date:
            try:
                end_dt = datetime.strptime(end_date, "%Y-%m-%d").replace(tzinfo=timezone(timedelta(hours=7))) + timedelta(days=1)
                query = query.filter(PatrolRecord.check_in_time < end_dt)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid end_date format. Use YYYY-MM-DD"
                )
        
        # Lấy records với eager loading (compatible với old database)
        records = query.options(
            joinedload(PatrolRecord.user),
            joinedload(PatrolRecord.location)
        ).order_by(PatrolRecord.check_in_time.desc()).offset(skip).limit(limit).all()
        
        # Convert sang dict để tránh lỗi serialization
        result = []
        for record in records:
            # Lấy task title thật từ database
            task_title = "Không có nhiệm vụ"
            if getattr(record, 'task_id', None):
                from sqlalchemy import text
                task_result = db.execute(text("SELECT title FROM patrol_tasks WHERE id = :task_id"), {"task_id": getattr(record, 'task_id', None)})
                task_row = task_result.fetchone()
                if task_row:
                    task_title = task_row[0]
                else:
                    task_title = "Unknown Task"
            result.append({
                "id": getattr(record, 'id', None),
                "user_id": getattr(record, 'user_id', None),
                "user": {
                    "id": getattr(record.user, 'id', None) if record.user else None,
                    "username": getattr(record.user, 'username', "Unknown") if record.user else "Unknown",
                    "full_name": getattr(record.user, 'full_name', "Unknown User") if record.user else "Unknown User"
                } if record.user else None,
                "task_id": getattr(record, 'task_id', None),
                "task": {
                    "id": getattr(record, 'task_id', None),
                    "title": task_title,
                    "description": None
                },
                "location_id": getattr(record, 'location_id', None),
                "location": {
                    "id": getattr(record.location, 'id', None) if record.location else None,
                    "name": getattr(record.location, 'name', "Unknown Location") if record.location else "Unknown Location",
                    "address": getattr(record.location, 'address', None) if record.location else None
                } if record.location else None,
                "check_in_time": format_vietnam_time(getattr(record, 'check_in_time', None)),
                "check_out_time": format_vietnam_time(getattr(record, 'check_out_time', None)),
                "photo_url": getattr(record, 'photo_path', None),
                "notes": getattr(record, 'notes', None),
                "created_at": getattr(record, 'check_in_time', None).isoformat() if getattr(record, 'check_in_time', None) else None,
            })
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error in get_patrol_records_report: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get("/health")
async def reports_health():
    """Health check cho reports module"""
    return {"status": "ok", "message": "Reports module is working"}
