from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin
from ..models import PatrolTask, User, Location

router = APIRouter(prefix="/test-tasks", tags=["test-tasks"])

@router.get("/")
async def get_test_tasks(
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Test API để lấy danh sách nhiệm vụ đơn giản"""
    try:
        print(f"🔍 DEBUG: User role: {current_user.role}")
        print(f"🔍 DEBUG: User ID: {current_user.id}")
        
        # Query cơ bản
        tasks = db.query(PatrolTask).all()
        print(f"🔍 DEBUG: Found {len(tasks)} tasks")
        
        # Convert to simple response format
        result = []
        for task in tasks:
            result.append({
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "status": task.status,
                "location_id": task.location_id,
                "assigned_to": task.assigned_to,
            })
        
        return {
            "success": True,
            "count": len(result),
            "tasks": result
        }
        
    except Exception as e:
        print(f"Error in get_test_tasks: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching test tasks: {str(e)}"
        )

