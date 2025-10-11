from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc, asc
from typing import List, Optional
from datetime import datetime, timezone, timedelta
from pydantic import BaseModel
import os
import shutil
import base64
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin, require_admin
from ..models import PatrolRecord, User, PatrolTask, Location, UserRole
from ..schemas import PatrolRecordCreate, PatrolRecordUpdate, PatrolRecord as PatrolRecordSchema
from ..config import settings

router = APIRouter(prefix="/patrol-records", tags=["patrol records"])

@router.get("/photo/{filename}")
async def get_photo(filename: str):
    """Serve photo files"""
    try:
        photo_path = os.path.join(settings.upload_dir, filename)
        if os.path.exists(photo_path):
            return FileResponse(photo_path)
        else:
            raise HTTPException(status_code=404, detail="Photo not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def get_vietnam_time():
    vietnam_tz = timezone(timedelta(hours=7))
    return datetime.now(vietnam_tz)

class QRConfirmationRequest(BaseModel):
    qr_data: str
    photo_url: Optional[str] = None
    location: Optional[dict] = None

class CheckinRequest(BaseModel):
    qr_code: str
    location_id: int
    notes: Optional[str] = None
    latitude: float
    longitude: float
    photo: str

async def save_upload_file(upload_file: UploadFile) -> str:
    """Save uploaded file and return the file path"""
    if not upload_file.filename:
        raise HTTPException(status_code=400, detail="No file provided")
    
    # Create uploads directory if it doesn't exist
    upload_dir = "uploads"
    os.makedirs(upload_dir, exist_ok=True)
    
    # Generate unique filename
    timestamp = get_vietnam_time().strftime("%Y%m%d_%H%M%S")
    filename = f"{timestamp}_{upload_file.filename}"
    file_path = os.path.join(upload_dir, filename)
    
    # Save file
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(upload_file.file, buffer)
    
    return file_path

@router.post("/checkin")
async def checkin(
    checkin_data: CheckinRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Check-in endpoint for employees"""
    try:
        # Save photo
        photo_filename = f"checkin_{current_user.id}_{get_vietnam_time().strftime('%Y%m%d_%H%M%S')}.jpg"
        
        # Save directly to backend/uploads directory (where backend serves files from)
        backend_uploads_dir = "/Users/maybe/Documents/shopee/backend/uploads"
        os.makedirs(backend_uploads_dir, exist_ok=True)
        
        # Full path for saving file
        photo_path = os.path.join(backend_uploads_dir, photo_filename)

        # Save base64 photo directly to database
        photo_base64 = None
        if checkin_data.photo and checkin_data.photo.startswith('data:image'):
            try:
                photo_base64 = checkin_data.photo
                print(f"✅ Photo saved as base64 to database")
                    
            except Exception as e:
                print(f"⚠️ Photo save error: {e}")
                photo_base64 = None
        else:
            print("⚠️ No valid photo provided")
            photo_base64 = None

        # Create patrol record
        # Store relative path in database (uploads/filename.jpg) - LUÔN CÓ ẢNH
        db_photo_path = f"uploads/{photo_filename}" if photo_path else None
        
        # Tìm task active cho user này
        active_task = db.query(PatrolTask).filter(
            PatrolTask.assigned_to == current_user.id,
            PatrolTask.status.in_(["pending", "in_progress"])
        ).first()
        
        patrol_record = PatrolRecord(
            user_id=current_user.id,
            task_id=active_task.id if active_task else None,
            location_id=checkin_data.location_id,
            check_in_time=get_vietnam_time(),
            notes=checkin_data.notes,
            gps_latitude=checkin_data.latitude,
            gps_longitude=checkin_data.longitude,
            photo_path=db_photo_path,
            photo_base64=photo_base64
        )

        db.add(patrol_record)
        db.commit()
        db.refresh(patrol_record)

        # Cập nhật trạng thái task nếu có
        if active_task:
            # Kiểm tra xem tất cả stops đã được checkin chưa
            from sqlalchemy import text
            stops_result = db.execute(text("""
                SELECT COUNT(*) as total_stops,
                       COUNT(CASE WHEN pr.id IS NOT NULL THEN 1 END) as completed_stops
                FROM patrol_task_stops pts
                LEFT JOIN patrol_records pr ON pts.location_id = pr.location_id 
                    AND pr.task_id = :task_id 
                    AND DATE(pr.check_in_time) = DATE(:checkin_time)
                WHERE pts.task_id = :task_id
            """), {
                "task_id": active_task.id,
                "checkin_time": get_vietnam_time()
            })
            
            result = stops_result.fetchone()
            total_stops = result[0] if result else 0
            completed_stops = result[1] if result else 0
            
            print(f"Task {active_task.id}: {completed_stops}/{total_stops} stops completed")
            
            # Cập nhật trạng thái task
            if completed_stops >= total_stops and total_stops > 0:
                active_task.status = "completed"
                print(f"Task {active_task.id} marked as completed")
            else:
                active_task.status = "in_progress"
                print(f"Task {active_task.id} marked as in_progress")
            
            db.add(active_task)
            db.commit()

        return {
            "success": True,
            "message": "Check-in thành công",
            "record_id": patrol_record.id
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi khi check-in: {str(e)}")

@router.get("/", response_model=List[dict])
async def get_all_patrol_records(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Get all patrol records (Admin/Manager only) - simplified version"""
    try:
        records = db.query(PatrolRecord).order_by(PatrolRecord.check_in_time.desc()).offset(skip).limit(limit).all()
        
        result = []
        for record in records:
            result.append({
                "id": record.id,
                "user_id": record.user_id,
                "task_id": record.task_id,
                "location_id": record.location_id,
                "check_in_time": record.check_in_time.isoformat() if record.check_in_time else None,
                "check_out_time": record.check_out_time.isoformat() if record.check_out_time else None,
                "photo_url": record.photo_base64 if record.photo_base64 else None,
                "notes": record.notes,
                "created_at": record.check_in_time.isoformat() if record.check_in_time else None,
            })
        
        return result
        
    except Exception as e:
        print(f"Error in get_all_patrol_records: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.get("/report")
async def get_patrol_report():
    """Get patrol records report - simple version without authentication"""
    try:
        from ..database import SessionLocal
        from sqlalchemy.orm import joinedload
        db = SessionLocal()
        
        # Query với eager loading để lấy thông tin user, task, location
        records = db.query(PatrolRecord).options(
            joinedload(PatrolRecord.user),
            joinedload(PatrolRecord.location)
        ).order_by(PatrolRecord.check_in_time.desc()).limit(100).all()
        
        result = []
        for record in records:
            # Lấy task title nếu có task_id
            task_title = None
            if record.task_id:
                task = db.query(PatrolTask).filter(PatrolTask.id == record.task_id).first()
                if task:
                    task_title = task.title
            
            result.append({
                "id": record.id,
                "user_id": record.user_id,
                "task_id": record.task_id,
                "location_id": record.location_id,
                "check_in_time": record.check_in_time.isoformat() if record.check_in_time else None,
                "check_out_time": record.check_out_time.isoformat() if record.check_out_time else None,
                "photo_url": record.photo_base64 if record.photo_base64 else None,
                "notes": record.notes,
                "created_at": record.check_in_time.isoformat() if record.check_in_time else None,
                # Thêm thông tin user, task, location
                "user": {
                    "username": record.user.username if record.user else f"user_{record.user_id}",
                    "full_name": record.user.full_name if record.user else f"User {record.user_id}"
                } if record.user else None,
                "location": {
                    "name": record.location.name if record.location else f"Location {record.location_id}"
                } if record.location else None,
                "task": {
                    "title": task_title or f"Task {record.task_id}" if record.task_id else "Check-in tự do"
                },
            })
        
        db.close()
        return result
        
    except Exception as e:
        print(f"Error in get_patrol_report: {e}")
        return {"error": str(e), "type": type(e).__name__}

@router.get("/history", response_model=List[dict])
async def get_patrol_history(
    skip: int = 0,
    limit: int = 100,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get patrol history - simplified version"""
    try:
        query = db.query(PatrolRecord)  # Lấy tất cả records, không filter theo user
        
        # Filter by date range if provided
        if start_date:
            try:
                start_dt = datetime.strptime(start_date, "%Y-%m-%d")
                query = query.filter(PatrolRecord.check_in_time >= start_dt)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid start_date format. Use YYYY-MM-DD"
                )
        
        if end_date:
            try:
                end_dt = datetime.strptime(end_date, "%Y-%m-%d") + timedelta(days=1)
                query = query.filter(PatrolRecord.check_in_time < end_dt)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid end_date format. Use YYYY-MM-DD"
                )
        
        records = query.order_by(PatrolRecord.check_in_time.desc()).offset(skip).limit(limit).all()
        
        result = []
        for record in records:
            result.append({
                "id": record.id,
                "user_id": record.user_id,
                "task_id": record.task_id,
                "location_id": record.location_id,
                "check_in_time": record.check_in_time.isoformat() if record.check_in_time else None,
                "check_out_time": record.check_out_time.isoformat() if record.check_out_time else None,
                "photo_url": record.photo_base64 if record.photo_base64 else None,
                "notes": record.notes,
                "created_at": record.check_in_time.isoformat() if record.check_in_time else None,
            })
        
        return result
        
    except Exception as e:
        print(f"Error in get_patrol_history: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.post("/", response_model=PatrolRecordSchema)
async def create_patrol_record(
    record_data: PatrolRecordCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new patrol record"""
    try:
        # Create new patrol record
        patrol_record = PatrolRecord(
            user_id=current_user.id,
            task_id=record_data.task_id,
            location_id=record_data.location_id,
            check_in_time=get_vietnam_time(),
            photo_path=record_data.photo_url.replace('/uploads/', '') if record_data.photo_url else None,
            notes=record_data.notes
        )
        
        db.add(patrol_record)
        db.commit()
        db.refresh(patrol_record)
        
        return patrol_record
        
    except Exception as e:
        db.rollback()
        print(f"Error creating patrol record: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create patrol record: {str(e)}"
        )

@router.put("/{record_id}", response_model=PatrolRecordSchema)
async def update_patrol_record(
    record_id: int,
    record_data: PatrolRecordUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a patrol record"""
    record = db.query(PatrolRecord).filter(PatrolRecord.id == record_id).first()
    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patrol record not found"
        )
    
    # Check permissions
    if current_user.role != UserRole.ADMIN and current_user.role != UserRole.MANAGER and record.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    # Update fields
    if record_data.task_id is not None:
        record.task_id = record_data.task_id
    if record_data.location_id is not None:
        record.location_id = record_data.location_id
    if record_data.check_out_time is not None:
        record.check_out_time = record_data.check_out_time
    if record_data.photo_url is not None:
        record.photo_path = record_data.photo_url.replace('/uploads/', '')
    if record_data.notes is not None:
        record.notes = record_data.notes
    
    db.commit()
    db.refresh(record)
    return record

@router.delete("/{record_id}")
async def delete_patrol_record(
    record_id: int,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Xóa bản ghi chấm công (Admin/Manager only)"""
    try:
        from sqlalchemy import text
        
        # Kiểm tra record có tồn tại không
        result = db.execute(text("SELECT id, photo_path FROM patrol_records WHERE id = :record_id"), {"record_id": record_id})
        row = result.fetchone()
        
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Patrol record not found"
            )
        
        # Delete photo file if exists
        photo_path = row[1]
        if photo_path:
            try:
                if os.path.exists(photo_path):
                    os.remove(photo_path)
            except Exception as e:
                print(f"Warning: Could not delete photo file {photo_path}: {e}")
        
        # Delete from database
        db.execute(text("DELETE FROM patrol_records WHERE id = :record_id"), {"record_id": record_id})
        db.commit()
        
        return {"message": "Patrol record deleted successfully"}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.get("/report/csv")
async def export_patrol_records_csv(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Export patrol records to CSV"""
    try:
        query = db.query(PatrolRecord)
        
        # Filter by date range if provided
        if start_date:
            try:
                start_dt = datetime.strptime(start_date, "%Y-%m-%d")
                query = query.filter(PatrolRecord.check_in_time >= start_dt)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid start_date format. Use YYYY-MM-DD"
                )
        
        if end_date:
            try:
                end_dt = datetime.strptime(end_date, "%Y-%m-%d") + timedelta(days=1)
                query = query.filter(PatrolRecord.check_in_time < end_dt)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid end_date format. Use YYYY-MM-DD"
                )
        
        records = query.order_by(PatrolRecord.check_in_time.desc()).all()
        
        # Create CSV content
        csv_content = "ID,User ID,Task ID,Location ID,Check In Time,Check Out Time,Photo URL,Notes,Created At\n"
        
        for record in records:
            csv_content += f"{record.id},{record.user_id},{record.task_id},{record.location_id},"
            csv_content += f"{record.check_in_time.isoformat() if record.check_in_time else ''},"
            csv_content += f"{record.check_out_time.isoformat() if record.check_out_time else ''},"
            csv_content += f"{f'/uploads/{record.photo_path}' if record.photo_path else ''},{record.notes or ''},"
            csv_content += f"{record.check_in_time.isoformat() if record.check_in_time else ''}\n"
        
        return {
            "csv_content": csv_content,
            "filename": f"patrol_records_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        }
        
    except Exception as e:
        print(f"Error exporting CSV: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to export CSV: {str(e)}"
        )
