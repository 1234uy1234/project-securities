from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin
from ..models import PatrolTask, User, Location
from ..services.push_notification import push_service
# from ..schemas import PatrolTask as PatrolTaskSchema

router = APIRouter(prefix="/patrol-tasks", tags=["patrol-tasks"])

@router.post("/")
async def create_patrol_task(
    task_data: dict,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Tạo nhiệm vụ tuần tra mới - Admin/Manager only"""
    try:
        from sqlalchemy import text
        
        # Validate required fields
        required_fields = ['title', 'assigned_to', 'location_id']
        for field in required_fields:
            if field not in task_data or not task_data[field]:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Field '{field}' is required"
                )
        
        # Insert task vào database
        insert_query = text("""
            INSERT INTO patrol_tasks (title, description, assigned_to, location_id, status, created_at)
            VALUES (:title, :description, :assigned_to, :location_id, :status, :created_at)
        """)
        
        now = datetime.now(timezone.utc)
        
        result = db.execute(insert_query, {
            "title": task_data['title'],
            "description": task_data.get('description', ''),
            "assigned_to": task_data['assigned_to'],
            "location_id": task_data['location_id'],
            "status": task_data.get('status', 'pending'),
            "created_at": now
        })
        
        # Lấy task_id vừa tạo
        task_id = result.lastrowid
        
        # Tạo stops nếu có trong request
        if 'stops' in task_data and task_data['stops']:
            stops = task_data['stops']
            print(f"🔍 DEBUG: Creating {len(stops)} stops for task {task_id}")
            print(f"🔍 DEBUG: Stops data: {stops}")
            
            for i, stop in enumerate(stops):
                # Frontend gửi qr_code_name, cần tìm location_id tương ứng
                location_id = None
                qr_code_name = None
                
                if 'location_id' in stop and stop['location_id']:
                    location_id = stop['location_id']
                elif 'qr_code_name' in stop and stop['qr_code_name']:
                    # Lưu QR code name để hiển thị
                    qr_code_name = stop['qr_code_name']
                    # Tạm thời dùng location_id = 1 cho tất cả QR codes
                    location_id = 1
                    print(f"🔍 DEBUG: Using QR name: {qr_code_name}, location_id=1")
                
                if location_id:
                    insert_stop_query = text("""
                        INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, created_at, qr_code_name)
                        VALUES (:task_id, :location_id, :sequence, :scheduled_time, :created_at, :qr_code_name)
                    """)
                    
                    db.execute(insert_stop_query, {
                        "task_id": task_id,
                        "location_id": location_id,
                        "sequence": i + 1,
                        "scheduled_time": stop.get('scheduled_time', '08:00'),
                        "created_at": now,
                        "qr_code_name": qr_code_name
                    })
                    print(f"✅ Created stop {i+1}: location_id={location_id}, qr_name={qr_code_name}, scheduled_time={stop.get('scheduled_time', '08:00')}")
        
        db.commit()
        
        # Gửi push notification cho user được giao nhiệm vụ
        try:
            # Lấy thông tin user được giao nhiệm vụ
            assigned_user = db.query(User).filter(User.id == task_data['assigned_to']).first()
            if assigned_user:
                # Gửi thông báo push sử dụng service mới
                await push_service.send_task_assignment_notification(
                    task_id=task_id,
                    assigned_to_user_id=assigned_user.id,
                    task_title=task_data['title'],
                    task_description=task_data.get('description', '')
                )
                
        except Exception as e:
            # Không làm lỗi tạo task nếu gửi thông báo thất bại
            print(f"⚠️ Warning: Failed to send push notification: {e}")
        
        return {"message": "Patrol task created successfully", "task_id": task_id}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.delete("/{task_id}")
async def delete_patrol_task(
    task_id: int,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Xóa nhiệm vụ tuần tra - Admin/Manager only"""
    try:
        from sqlalchemy import text
        
        # Kiểm tra task có tồn tại không
        result = db.execute(text("SELECT id FROM patrol_tasks WHERE id = :task_id"), {"task_id": task_id})
        row = result.fetchone()
        
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Patrol task not found"
            )
        
        # Delete from database
        db.execute(text("DELETE FROM patrol_tasks WHERE id = :task_id"), {"task_id": task_id})
        db.commit()
        
        return {"message": "Patrol task deleted successfully"}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.get("/")
async def get_patrol_tasks(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Lấy danh sách nhiệm vụ tuần tra - Tất cả user roles"""
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
            
            # Get stops data với thông tin hoàn thành
            from sqlalchemy import text
            from datetime import datetime, timezone, timedelta
            
            # Lấy ngày hiện tại để chỉ hiển thị check-in cùng ngày
            today = datetime.now(timezone(timedelta(hours=7))).date()
            
            stops_result = db.execute(text("""
                SELECT pts.id, pts.location_id, pts.sequence, pts.scheduled_time, 
                       COALESCE(pts.qr_code_name, l.name) as display_name,
                       pts.completed, pts.completed_at
                FROM patrol_task_stops pts
                JOIN locations l ON pts.location_id = l.id
                WHERE pts.task_id = :task_id
                ORDER BY pts.sequence
            """), {"task_id": task.id})
            
            stops = []
            for stop_row in stops_result.fetchall():
                stop_id, location_id, sequence, scheduled_time, display_name, completed, completed_at = stop_row
                
                # Kiểm tra xem có check-in thực tế trong ngày hôm nay không
                checkin_result = db.execute(text("""
                    SELECT pr.check_in_time, pr.photo_base64
                    FROM patrol_records pr
                    WHERE pr.task_id = :task_id 
                    AND pr.location_id = :location_id
                    AND DATE(pr.check_in_time) = :today
                    ORDER BY pr.check_in_time DESC
                    LIMIT 1
                """), {
                    "task_id": task.id,
                    "location_id": location_id,
                    "today": today
                })
                
                checkin_row = checkin_result.fetchone()
                is_completed_today = checkin_row is not None
                actual_completed_at = checkin_row[0] if checkin_row else None
                
                # Xử lý completed_at - có thể là string hoặc datetime
                completed_at_str = None
                if actual_completed_at:
                    if hasattr(actual_completed_at, 'isoformat'):
                        completed_at_str = actual_completed_at.isoformat()
                    else:
                        completed_at_str = str(actual_completed_at)
                
                stops.append({
                    "stop_id": stop_id,
                    "location_id": location_id,
                    "sequence": sequence,
                    "scheduled_time": scheduled_time,
                    "location_name": display_name,
                    "completed": is_completed_today,  # Chỉ true nếu có check-in hôm nay
                    "completed_at": completed_at_str
                })
            
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
                "stops": stops
            })
        
        return result
        
    except Exception as e:
        print(f"Error in get_patrol_tasks: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching patrol tasks: {str(e)}"
        )

@router.get("/my-tasks")
async def get_my_tasks(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Lấy danh sách nhiệm vụ của employee hiện tại"""
    try:
        print(f"🔍 MY-TASKS: User {current_user.username} (ID: {current_user.id}) requesting tasks")
        
        # Query tasks assigned to current user
        tasks = db.query(PatrolTask).filter(PatrolTask.assigned_to == current_user.id).all()
        print(f"🔍 MY-TASKS: Found {len(tasks)} tasks for user {current_user.id}")
        
        # Convert to response format
        result = []
        for task in tasks:
            # Get assigned user info
            assigned_user = db.query(User).filter(User.id == task.assigned_to).first()
            
            # Get location info
            location = db.query(Location).filter(Location.id == task.location_id).first()
            
            # Get stops for this task với logic kiểm tra ngày
            from sqlalchemy import text
            from datetime import datetime, timezone, timedelta
            
            # Lấy ngày hiện tại để chỉ hiển thị check-in cùng ngày
            today = datetime.now(timezone(timedelta(hours=7))).date()
            
            stops_query = text("""
                SELECT pts.id as stop_id, pts.location_id, pts.sequence, pts.scheduled_time, 
                       COALESCE(pts.qr_code_name, l.name) as location_name
                FROM patrol_task_stops pts
                LEFT JOIN locations l ON pts.location_id = l.id
                WHERE pts.task_id = :task_id
                ORDER BY pts.sequence
            """)
            
            stops_result = db.execute(stops_query, {"task_id": task.id})
            stops_list = []
            for stop_row in stops_result:
                stop_id, location_id, sequence, scheduled_time, location_name = stop_row
                
                # Kiểm tra xem có check-in thực tế trong ngày hôm nay không
                checkin_result = db.execute(text("""
                    SELECT pr.check_in_time, pr.photo_base64
                    FROM patrol_records pr
                    WHERE pr.task_id = :task_id 
                    AND pr.location_id = :location_id
                    AND DATE(pr.check_in_time) = :today
                    ORDER BY pr.check_in_time DESC
                    LIMIT 1
                """), {
                    "task_id": task.id,
                    "location_id": location_id,
                    "today": today
                })
                
                checkin_row = checkin_result.fetchone()
                is_completed_today = checkin_row is not None
                actual_completed_at = checkin_row[0] if checkin_row else None
                
                # Xử lý completed_at - có thể là string hoặc datetime
                completed_at_str = None
                if actual_completed_at:
                    if hasattr(actual_completed_at, 'isoformat'):
                        completed_at_str = actual_completed_at.isoformat()
                    else:
                        completed_at_str = str(actual_completed_at)
                
                stops_list.append({
                    "stop_id": stop_id,
                    "location_id": location_id,
                    "sequence": sequence,
                    "scheduled_time": scheduled_time,
                    "location_name": location_name,
                    "completed": is_completed_today,  # Chỉ true nếu có check-in hôm nay
                    "completed_at": completed_at_str
                })

            task_dict = {
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "status": task.status,
                "created_at": task.created_at,
                "location_id": task.location_id,
                "assigned_to": task.assigned_to,
                "location_name": location.name if location else f"Location {task.location_id}",
                "assigned_user": {
                    "id": assigned_user.id if assigned_user else task.assigned_to,
                    "username": assigned_user.username if assigned_user else "Unknown",
                    "full_name": assigned_user.full_name if assigned_user else "Unknown User"
                },
                "stops": stops_list
            }
            result.append(task_dict)
        
        print(f"🔍 MY-TASKS: Returning {len(result)} tasks")
        return result
        
    except Exception as e:
        print(f"Error in get_my_tasks: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching my tasks: {str(e)}"
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

@router.put("/{task_id}")
async def update_patrol_task(
    task_id: int,
    task_data: dict,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Cập nhật nhiệm vụ tuần tra - Admin/Manager only"""
    try:
        from sqlalchemy import text
        
        # Kiểm tra task tồn tại
        task = db.query(PatrolTask).filter(PatrolTask.id == task_id).first()
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        
        # Cập nhật các trường được phép
        update_fields = []
        update_values = {"task_id": task_id}
        
        if 'status' in task_data:
            update_fields.append("status = :status")
            update_values["status"] = task_data['status']
        
        if 'title' in task_data:
            update_fields.append("title = :title")
            update_values["title"] = task_data['title']
        
        if 'description' in task_data:
            update_fields.append("description = :description")
            update_values["description"] = task_data['description']
        
        if 'assigned_to' in task_data:
            update_fields.append("assigned_to = :assigned_to")
            update_values["assigned_to"] = task_data['assigned_to']
        
        if 'location_id' in task_data:
            update_fields.append("location_id = :location_id")
            update_values["location_id"] = task_data['location_id']
        
        if update_fields:
            update_query = text(f"""
                UPDATE patrol_tasks 
                SET {', '.join(update_fields)}
                WHERE id = :task_id
            """)
            
            db.execute(update_query, update_values)
            db.commit()
            
            print(f"✅ Updated task {task_id}: {', '.join(update_fields)}")
        
        # Lấy task đã cập nhật
        updated_task = db.query(PatrolTask).filter(PatrolTask.id == task_id).first()
        
        return {
            "message": "Task updated successfully",
            "task": {
                "id": updated_task.id,
                "title": updated_task.title,
                "description": updated_task.description,
                "status": updated_task.status,
                "assigned_to": updated_task.assigned_to,
                "location_id": updated_task.location_id,
                "created_at": updated_task.created_at.isoformat() if updated_task.created_at else None
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in update_patrol_task: {e}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error updating patrol task: {str(e)}"
        )
