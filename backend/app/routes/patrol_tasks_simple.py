from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin
from ..models import PatrolTask, User, Location
# from ..schemas import PatrolTask as PatrolTaskSchema

router = APIRouter(prefix="/patrol-tasks", tags=["patrol-tasks"])

@router.get("/")
async def get_patrol_tasks(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Lấy danh sách nhiệm vụ tuần tra - Admin/Manager only"""
    try:
        print(f"🔍 DEBUG: User role: {current_user.role}")
        print(f"🔍 DEBUG: User ID: {current_user.id}")
        
        # Query cơ bản
        query = db.query(PatrolTask)
        
        # Count total
        total_tasks = query.count()
        print(f"🔍 DEBUG: Total tasks in DB: {total_tasks}")
        
        # Get tasks
        tasks = query.offset(skip).limit(limit).all()
        print(f"🔍 DEBUG: Found {len(tasks)} tasks")
        
        # Convert to response format
        result = []
        for task in tasks:
            # Get assigned user info
            assigned_user = db.query(User).filter(User.id == task.assigned_to).first()
            
            # Get location info
            location = db.query(Location).filter(Location.id == task.location_id).first()
            
            result.append({
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "location_id": task.location_id,
                "assigned_to": task.assigned_to,
                "status": task.status,
                "created_at": task.created_at.isoformat() if task.created_at else None,
                "assigned_user": {
                    "id": assigned_user.id if assigned_user else None,
                    "username": assigned_user.username if assigned_user else None,
                    "full_name": assigned_user.full_name if assigned_user else None,
                } if assigned_user else None,
                "location": {
                    "id": location.id if location else None,
                    "name": location.name if location else None,
                    "description": location.description if location else None,
                } if location else None,
            })
        
        return result
        
    except Exception as e:
        print(f"Error in get_patrol_tasks: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching patrol tasks: {str(e)}"
        )

@router.get("/{task_id}")
async def get_patrol_task(
    task_id: int,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Lấy chi tiết một nhiệm vụ tuần tra"""
    try:
        task = db.query(PatrolTask).filter(PatrolTask.id == task_id).first()
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        # Get assigned user info
        assigned_user = db.query(User).filter(User.id == task.assigned_to).first()
        
        # Get location info
        location = db.query(Location).filter(Location.id == task.location_id).first()
        
        return {
            "id": task.id,
            "title": task.title,
            "description": task.description,
            "location_id": task.location_id,
            "assigned_to": task.assigned_to,
            "status": task.status,
            "created_at": task.created_at.isoformat() if task.created_at else None,
            "assigned_user": {
                "id": assigned_user.id if assigned_user else None,
                "username": assigned_user.username if assigned_user else None,
                "full_name": assigned_user.full_name if assigned_user else None,
            } if assigned_user else None,
            "location": {
                "id": location.id if location else None,
                "name": location.name if location else None,
                "description": location.description if location else None,
            } if location else None,
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in get_patrol_task: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching patrol task: {str(e)}"
        )
