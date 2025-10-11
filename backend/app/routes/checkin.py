from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone, timedelta
import os
import base64
from ..database import get_db
from ..auth import get_current_user
from ..models import User, Location, PatrolRecord, PatrolTask, TaskStatus, QRCode
from ..config import settings

router = APIRouter(prefix="/checkin", tags=["checkin"])

def get_vietnam_time() -> datetime:
    return datetime.now(timezone(timedelta(hours=7)))

@router.get("/admin/all-records")
async def get_all_checkin_records_admin(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Lấy tất cả checkin records cho admin dashboard - Tương thích database cũ"""
    try:
        # Cho phép tất cả user roles truy cập (admin, manager, employee)
        # Employee sẽ được filter dữ liệu ở frontend
        pass
        
        # Lấy tất cả patrol records với thông tin liên quan
        from sqlalchemy.orm import joinedload
        records = db.query(PatrolRecord).options(
            joinedload(PatrolRecord.user),
            joinedload(PatrolRecord.location)
        ).order_by(PatrolRecord.check_in_time.desc()).limit(100).all()
        
        result = []
        for record in records:
            # Sử dụng photo_base64 thay vì photo_path
            photo_url = getattr(record, 'photo_base64', None)
            task_id = getattr(record, 'task_id', None)
            
            # Lấy task_title thực tế từ database
            task_title = "Nhiệm vụ cũ"
            if task_id:
                from sqlalchemy import text
                task_result = db.execute(text("SELECT title FROM patrol_tasks WHERE id = :task_id"), {"task_id": task_id})
                task_row = task_result.fetchone()
                if task_row:
                    task_title = task_row[0]
                else:
                    task_title = "Unknown Task"
            
            result.append({
                "id": record.id,
                "user_id": record.user_id,
                "user_name": record.user.username if record.user else "Unknown",
                "task_id": task_id,
                "task_title": task_title,
                "location_id": record.location_id,
                "location_name": record.location.name if record.location else "Unknown Location",
                "check_in_time": record.check_in_time.isoformat() if record.check_in_time else None,
                "check_out_time": record.check_out_time.isoformat() if record.check_out_time else None,
                "photo_url": photo_url,
                "notes": record.notes,
                "created_at": getattr(record, 'created_at', record.check_in_time).isoformat() if getattr(record, 'created_at', record.check_in_time) else None,
            })
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error in get_all_checkin_records_admin: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi server: {str(e)}"
        )

@router.post("/test-auth")
async def test_auth(
    current_user: User = Depends(get_current_user)
):
    """Test authentication endpoint"""
    return {
        "message": "Authentication successful",
        "user": current_user.username,
        "user_id": current_user.id,
        "role": current_user.role
    }

@router.post("/simple")
async def checkin_simple(
    qr_data: Optional[str] = Form(None),
    photo: Optional[UploadFile] = File(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Checkin đơn giản - tương thích với frontend"""
    print(f"🔍 SIMPLE CHECKIN: User {current_user.username}, QR: '{qr_data}'")
    
    if not qr_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="QR data là bắt buộc"
        )
    
    try:
        # Tìm location từ QR data
        location = None
        location_id = None
        
        # Thử tìm location theo QR code content
        from sqlalchemy import text
        result = db.execute(text("SELECT id, name FROM locations WHERE qr_code = :qr_data"), 
                          {"qr_data": qr_data})
        row = result.fetchone()
        
        if row:
            location_id = row[0]
            location_name = row[1]
            print(f"✅ Found location by qr_code: {location_name} (ID: {location_id})")
        else:
            # Thử tìm QR code trong database
            result = db.execute(text("SELECT id, content FROM qr_codes WHERE content = :qr_data"), 
                              {"qr_data": qr_data})
            qr_row = result.fetchone()
            
            if qr_row:
                # Tạo location tạm thời
                location_name = qr_data
                print(f"✅ Found QR code: {qr_data}")
            else:
                # Không tìm thấy QR code, nhưng vẫn cho phép tạo task tự động
                location_name = qr_data
                print(f"⚠️ QR code not found, but allowing auto task creation: {qr_data}")
        
        # Lưu ảnh nếu có
        photo_url = None
        if photo and photo.filename:
            try:
                # Tạo thư mục backend/uploads nếu chưa có
                backend_uploads_dir = "/Users/maybe/Documents/shopee/backend/uploads"
                os.makedirs(backend_uploads_dir, exist_ok=True)
                
                # Tạo tên file unique
                timestamp = int(datetime.now().timestamp())
                filename = f"checkin_{current_user.id}_{timestamp}_{photo.filename}"
                file_path = os.path.join(backend_uploads_dir, filename)
                
                # Lưu file
                with open(file_path, "wb") as buffer:
                    content = await photo.read()
                    buffer.write(content)
                
                photo_url = f"/uploads/{filename}"
                print(f"✅ Photo saved: {photo_url}")
                
            except Exception as e:
                print(f"⚠️ Photo save error: {str(e)}")
                # Không throw error, chỉ log
        
        # Tìm hoặc tạo PatrolTask
        active_task = db.query(PatrolTask).filter(
            PatrolTask.assigned_to == current_user.id,
            PatrolTask.status.in_([TaskStatus.PENDING, TaskStatus.IN_PROGRESS])
        ).first()
        
        if not active_task:
            print(f"✅ SIMPLE CHECKIN: Creating new task and checkin record")
            # Tìm một location bất kỳ để gán cho task nếu không có location cụ thể
            first_location = db.query(Location).first()
            if not first_location:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Không có vị trí nào trong hệ thống để tạo nhiệm vụ tự động."
                )
            
            print(f"✅ SIMPLE CHECKIN: Using location: {first_location.name} (ID: {first_location.id})")
            
            # Tạo task mới
            active_task = PatrolTask(
                title=f"Nhiệm vụ tự động - {qr_data}",
                description=f"Nhiệm vụ được tạo tự động",
                assigned_to=current_user.id,
                location_id=first_location.id,  # Sử dụng location đầu tiên có sẵn
                status=TaskStatus.IN_PROGRESS
            )
            db.add(active_task)
            db.commit()
            db.refresh(active_task)
            print(f"✅ SIMPLE CHECKIN: Created auto task: {active_task.id}")
            
            # Tạo stop cho task tự động
            from sqlalchemy import text
            insert_stop_query = text("""
                INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, created_at, qr_code_name)
                VALUES (:task_id, :location_id, :sequence, :scheduled_time, :created_at, :qr_code_name)
            """)
            
            db.execute(insert_stop_query, {
                "task_id": active_task.id,
                "location_id": first_location.id,
                "sequence": 1,
                "scheduled_time": "08:00",
                "created_at": get_vietnam_time(),
                "qr_code_name": qr_data
            })
            db.commit()
            print(f"✅ SIMPLE CHECKIN: Created stop for auto task: {active_task.id}")
        else:
            print(f"🔍 SIMPLE CHECKIN: Found active task: {active_task.id}")
        
        # Lấy thông tin location cho checkin
        checkin_location = db.query(Location).filter(Location.id == location_id).first()
        if not checkin_location:
            # Fallback nếu location_id từ QR không tìm thấy
            checkin_location = db.query(Location).first()
            print(f"⚠️ SIMPLE CHECKIN: Using fallback location: {checkin_location.name} (ID: {checkin_location.id})")
        
        print(f"✅ SIMPLE CHECKIN: Using checkin location: {checkin_location.name} (ID: {checkin_location.id})")
        
        # Tạo checkin record
        checkin_time = get_vietnam_time()
        
        patrol_record = PatrolRecord(
            user_id=current_user.id,
            task_id=active_task.id,
            location_id=checkin_location.id,
            check_in_time=checkin_time,
            gps_latitude=0.0,
            gps_longitude=0.0,
            photo_path=photo_url.replace('/uploads/', '') if photo_url else None,  # Lưu filename không có prefix
            notes=f"Chấm công đơn giản - QR: {qr_data}"
        )
        
        db.add(patrol_record)
        db.commit()
        db.refresh(patrol_record)
        
        # Cập nhật trạng thái stop nếu có - VỚI KIỂM TRA THỜI GIAN
        if active_task and checkin_location:
            from sqlalchemy import text
            # Tìm stop tương ứng với location này
            stop_result = db.execute(text("""
                SELECT id, scheduled_time FROM patrol_task_stops 
                WHERE task_id = :task_id AND location_id = :location_id
            """), {"task_id": active_task.id, "location_id": checkin_location.id})
            
            stop_row = stop_result.fetchone()
            if stop_row:
                stop_id = stop_row[0]
                scheduled_time_str = stop_row[1]
                
                # KIỂM TRA THỜI GIAN CHECKIN CÓ ĐÚNG KHÔNG (±15 phút)
                if scheduled_time_str:
                    try:
                        # Parse scheduled_time (format: "HH:MM")
                        scheduled_hour, scheduled_minute = map(int, scheduled_time_str.split(':'))
                        scheduled_minutes = scheduled_hour * 60 + scheduled_minute
                        
                        # Parse checkin_time
                        checkin_hour = checkin_time.hour
                        checkin_minute = checkin_time.minute
                        checkin_minutes = checkin_hour * 60 + checkin_minute
                        
                        # Tính khoảng cách thời gian (phút)
                        time_diff = abs(checkin_minutes - scheduled_minutes)
                        
                        print(f"🔍 TIME CHECK: Scheduled {scheduled_time_str} ({scheduled_minutes} min), Checkin {checkin_time.strftime('%H:%M')} ({checkin_minutes} min), Diff: {time_diff} min")
                        
                        # Chỉ cho phép checkin trong khoảng ±15 phút
                        if time_diff <= 15:
                            # Cập nhật stop là đã hoàn thành
                            db.execute(text("""
                                UPDATE patrol_task_stops 
                                SET completed = 1, completed_at = :completed_at 
                                WHERE id = :stop_id
                            """), {"stop_id": stop_id, "completed_at": checkin_time})
                            db.commit()
                            
                            print(f"✅ SIMPLE CHECKIN: Updated stop {stop_id} as completed (within time window)")
                        else:
                            print(f"⚠️ SIMPLE CHECKIN: Checkin time {checkin_time.strftime('%H:%M')} is outside allowed window (±15 min from {scheduled_time_str})")
                            print(f"⚠️ SIMPLE CHECKIN: Stop {stop_id} NOT marked as completed")
                    except Exception as e:
                        print(f"❌ SIMPLE CHECKIN: Error parsing scheduled_time '{scheduled_time_str}': {e}")
                        # Fallback: vẫn cập nhật stop nếu không parse được thời gian
                        db.execute(text("""
                            UPDATE patrol_task_stops 
                            SET completed = 1, completed_at = :completed_at 
                            WHERE id = :stop_id
                        """), {"stop_id": stop_id, "completed_at": checkin_time})
                        db.commit()
                        print(f"✅ SIMPLE CHECKIN: Updated stop {stop_id} as completed (fallback)")
                else:
                    print(f"⚠️ SIMPLE CHECKIN: No scheduled_time for stop {stop_id}, marking as completed")
                    db.execute(text("""
                        UPDATE patrol_task_stops 
                        SET completed = 1, completed_at = :completed_at 
                        WHERE id = :stop_id
                    """), {"stop_id": stop_id, "completed_at": checkin_time})
                    db.commit()
            else:
                print(f"⚠️ SIMPLE CHECKIN: No stop found for task {active_task.id} and location {checkin_location.id}")
        
        print(f"✅ SIMPLE CHECKIN: Checkin successful - Record ID: {patrol_record.id}")
        
        return {
            "message": f"Chấm công thành công cho: {qr_data}",
            "type": "checkin",
            "check_in_time": patrol_record.check_in_time.isoformat(),
            "qr_content": qr_data,
            "photo_url": f"/uploads/{photo_url.replace('/uploads/', '')}" if photo_url else None,  # Thêm /uploads/ prefix
            "task_title": active_task.title,
            "location_name": checkin_location.name
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Checkin error: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Lỗi chấm công: {str(e)}"
        )
