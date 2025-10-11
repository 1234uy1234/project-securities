from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone, timedelta
def get_vietnam_time() -> datetime:
    return datetime.now(timezone(timedelta(hours=7)))
import qrcode
import os
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin
from ..models import Location, QRCode, PatrolTask
from ..config import settings

router = APIRouter(prefix="/qr-codes", tags=["qr codes"])

@router.post("/")
async def create_qr_code(
    qr_data: dict,
    current_user = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Tạo QR code mới"""
    try:
        from sqlalchemy import text
        
        # Validate required fields
        required_fields = ['content', 'qr_type']
        for field in required_fields:
            if field not in qr_data or not qr_data[field]:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Field '{field}' is required"
                )
        
        # Generate QR code image
        filename = generate_qr_code(qr_data['content'], qr_data['qr_type'])
        
        # Insert vào database
        insert_query = text("""
            INSERT INTO qr_codes (content, qr_type, location, created_at, created_by, is_active)
            VALUES (:content, :qr_type, :location, :created_at, :created_by, :is_active)
        """)
        
        now = get_vietnam_time()
        
        db.execute(insert_query, {
            "content": qr_data['content'],
            "qr_type": qr_data['qr_type'],
            "location": qr_data.get('location', ''),
            "created_at": now,
            "created_by": current_user.username,
            "is_active": True
        })
        
        db.commit()
        
        return {"message": "QR code created successfully", "filename": filename}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

def generate_qr_code(data: str, qr_type: str = "custom") -> str:
    """Generate QR code and return filename"""
    # Generate QR code
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(data)
    qr.make(fit=True)
    
    # Create image
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Save to file
    timestamp = int(get_vietnam_time().timestamp())
    filename = f"qr_{qr_type}_{timestamp}.png"
    file_path = os.path.join(settings.upload_dir, "qr_codes", filename)
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    img.save(file_path)
    return filename

@router.get("/")
async def get_qr_codes(
    current_user = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Get list of generated QR codes"""
    try:
        from sqlalchemy import text
        result = db.execute(text("SELECT id, content, qr_type, location, created_at, created_by, is_active FROM qr_codes ORDER BY created_at DESC"))
        rows = result.fetchall()
        return [
            {
                "id": row[0],
                "content": row[1],
                "type": row[2],  # Map qr_type to type for frontend
                "location": row[3],
                "created_at": str(row[4]) if row[4] else None,
                "created_by": row[5],
                "is_active": row[6]
            }
            for row in rows
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/generate-location")
async def generate_location_qr(
    location_name: str,
    current_user = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Tạo QR code tĩnh cho vị trí mới"""
    
    if not location_name or not location_name.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tên vị trí không được để trống"
        )
    
    # Tạo vị trí mới
    location = Location(
        name=location_name.strip(),
        description=f"Vị trí được tạo tự động: {location_name.strip()}",
        qr_code=f"smart_location_{int(get_vietnam_time().timestamp())}"  # QR code unique
    )
    db.add(location)
    db.commit()
    db.refresh(location)
    
    # Tạo QR data tĩnh - chỉ chứa location_id
    qr_data = str(location.id)
    qr_content = f"location_{location.id}"
    
    # Generate QR code
    filename = generate_qr_code(qr_content, f"location_{location.id}")
    
    # Lưu vào database
    db_qr = QRCode(
        data=qr_data,
        qr_content=qr_content,
        qr_type="location",
        filename=filename,
        qr_url=f"/uploads/qr_codes/{filename}",
        location_id=location.id,
        created_by=current_user.id
    )
    
    db.add(db_qr)
    db.commit()
    db.refresh(db_qr)
    
    return {
        "id": db_qr.id,
        "filename": db_qr.filename,
        "qr_url": db_qr.qr_url,
        "data": db_qr.data,
        "qr_type": db_qr.qr_type,
        "qr_content": db_qr.qr_content,
        "location_id": db_qr.location_id,
        "location_name": location.name,
        "created_at": db_qr.created_at.isoformat(),
        "message": f"✅ Đã tạo QR thông minh cho '{location.name}' thành công! QR sẽ tự động chuyển đến login (nếu chưa đăng nhập) hoặc chấm công (nếu đã đăng nhập). Vị trí mới đã được tạo với ID: {location.id}"
    }

from pydantic import BaseModel

class QRGenerateRequest(BaseModel):
    task_id: int = None
    data: str = None
    type: str = "fixed"
    location_id: int = None

@router.post("/generate-task-qr/{task_id}")
async def generate_task_qr(
    task_id: int,
    current_user = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Generate QR code for a specific task"""
    task = db.query(PatrolTask).filter(PatrolTask.id == task_id).first()
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task không tồn tại"
        )
    
    qr_data = str(task_id)
    qr_content = f"{settings.frontend_base_url}/checkin?task_id={task_id}"
    
    # Generate QR code with login link
    qr_filename = generate_qr_code(qr_content, "task")
    qr_url = f"/uploads/qr_codes/{qr_filename}"
    
    # Save QR code to database
    qr_code = QRCode(
        filename=qr_filename,
        content=qr_content,
        qr_data=qr_data,
        type="task",
        created_by=current_user.id
    )
    db.add(qr_code)
    db.commit()
    db.refresh(qr_code)
    
    return {
        "id": qr_code.id,
        "filename": qr_code.filename,
        "content": qr_code.content,
        "qr_data": qr_code.qr_data,
        "type": qr_code.type,
        "qr_url": qr_url,
        "created_at": qr_code.created_at.isoformat(),
        "message": f"✅ Đã tạo QR code cho task '{task.title}' thành công!"
    }

@router.post("/generate-simple")
async def generate_qr_simple(
    data: str,
    type: str = "static",
    location_id: str = None,
    current_user = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Generate QR code with query parameters - SIMPLIFIED LOGIC"""
    if not data or not data.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Data là bắt buộc"
        )
    
    # Đơn giản hóa: QR data và content giống nhau
    qr_data = data.strip()
    qr_content = data.strip()
    
    print(f"🔍 GENERATE QR: Creating QR with data='{qr_data}', content='{qr_content}'")
    
    # Generate QR code file
    qr_filename = generate_qr_code(qr_content, type)
    qr_url = f"/uploads/qr_codes/{qr_filename}"
    
    # Save QR code to database - ĐẢM BẢO DATA ĐƯỢC LƯU
    qr_code = QRCode(
        filename=qr_filename,
        qr_url=qr_url,
        data=qr_data,  # Tên QR code
        qr_type=type,
        qr_content=qr_content,  # Nội dung QR
        created_by=current_user.id
    )
    db.add(qr_code)
    db.commit()
    db.refresh(qr_code)
    
    print(f"✅ GENERATE QR: Saved QR code ID={qr_code.id}, data='{qr_code.data}', content='{qr_code.qr_content}'")
    
    return {
        "id": qr_code.id,
        "filename": qr_code.filename,
        "qr_url": qr_url,
        "data": qr_code.data,
        "type": qr_code.qr_type,
        "qr_content": qr_code.qr_content,
        "created_at": qr_code.created_at.isoformat(),
        "message": f"✅ Đã tạo QR code thành công: {qr_data}"
    }

@router.post("/generate")
async def generate_qr_code_endpoint(
    request: Request,
    current_user = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Generate a new QR code - supports both query params and JSON body"""
    
    # Try to get data from JSON body first
    try:
        body = await request.json()
        data = body.get('data')
        type = body.get('type', 'static')
        location_id = body.get('location_id')
        task_id = body.get('task_id')
    except:
        # Fallback to query parameters
        data = request.query_params.get('data')
        type = request.query_params.get('type', 'static')
        location_id = request.query_params.get('location_id')
        task_id = request.query_params.get('task_id')
        if task_id:
            task_id = int(task_id)
    
    # Nếu có task_id, tạo QR cho task đó
    if task_id is not None and task_id > 0:
        task = db.query(PatrolTask).filter(PatrolTask.id == task_id).first()
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task không tồn tại"
            )
        qr_data = str(task_id)
        qr_content = f"{settings.frontend_base_url}/checkin?task_id={task_id}"
    else:
        # QR code tùy ý
        if not data or not data.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Data hoặc task_id là bắt buộc"
            )
        qr_data = data
        
        # QR content chỉ là tên đơn giản, không phải URL
        qr_content = data
    
    # Generate QR code with login link
    qr_filename = generate_qr_code(qr_content, type)
    qr_url = f"/uploads/qr_codes/{qr_filename}"
    
    # Save QR code to database
    qr_code = QRCode(
        filename=qr_filename,
        qr_url=qr_url,
        data=qr_data,
        qr_type=type,
        qr_content=qr_content,
        location_id=location_id,
        created_by=current_user.id
    )
    db.add(qr_code)
    db.commit()
    db.refresh(qr_code)
    
    return {
        "id": qr_code.id,
        "qr_url": qr_url,
        "filename": qr_filename,
        "data": qr_data,
        "type": type,
        "location_id": location_id,
        "qr_content": qr_content,  # Include the actual QR content for reference
        "created_at": qr_code.created_at.isoformat()
    }

@router.get("/validate/{qr_content}")
async def validate_qr_code(
    qr_content: str,
    db: Session = Depends(get_db)
):
    """Validate QR code content and return QR data"""
    try:
        from sqlalchemy import text
        
        # Sử dụng raw SQL để tìm QR code theo content
        result = db.execute(text("SELECT id, content, qr_type, location, is_active FROM qr_codes WHERE content = :content"), 
                          {"content": qr_content})
        row = result.fetchone()
        
        if not row:
            return {
                "valid": False,
                "message": "QR code không tồn tại"
            }
        
        # Kiểm tra QR code có active không
        if not row[4]:  # is_active column
            return {
                "valid": False,
                "message": "QR code đã bị vô hiệu hóa"
            }
        
        return {
            "valid": True,
            "id": row[0],
            "data": row[1],  # content
            "content": row[1],  # content
            "location_id": None,  # Không có location_id trong schema hiện tại
            "type": row[2],  # qr_type
            "message": "QR code hợp lệ"
        }
        
    except Exception as e:
        print(f"❌ QR Validation Error: {str(e)}")
        return {
            "valid": False,
            "message": f"Lỗi xác thực QR code: {str(e)}"
        }

@router.get("/{qr_id}/image")
@router.head("/{qr_id}/image")
async def get_qr_code_image(
    qr_id: int,
    db: Session = Depends(get_db)
):
    """Get QR code image by ID"""
    try:
        from sqlalchemy import text
        result = db.execute(text("SELECT id, content FROM qr_codes WHERE id = :qr_id"), {"qr_id": qr_id})
        row = result.fetchone()
        
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="QR code not found"
            )
        
        # Tìm file QR code dựa trên content
        qr_content = row[1]
        qr_files_dir = os.path.join(settings.upload_dir, "qr_codes")
        
        if not os.path.exists(qr_files_dir):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="QR codes directory not found"
            )
        
        # Tìm file có chứa content này (tìm file mới nhất)
        matching_files = []
        for filename in os.listdir(qr_files_dir):
            if filename.endswith('.png') and qr_content in filename:
                file_path = os.path.join(qr_files_dir, filename)
                if os.path.exists(file_path):
                    matching_files.append((file_path, os.path.getmtime(file_path)))
        
        if matching_files:
            # Lấy file mới nhất
            latest_file = max(matching_files, key=lambda x: x[1])[0]
            print(f"🔍 Found QR file: {latest_file}")
            # Đọc file và trả về bytes
            with open(latest_file, 'rb') as f:
                image_data = f.read()
            from fastapi.responses import Response
            return Response(content=image_data, media_type="image/png")
        
        # Nếu không tìm thấy file, tạo QR code mới
        import qrcode
        import io
        
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(qr_content)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Chuyển image thành bytes
        img_buffer = io.BytesIO()
        img.save(img_buffer, format='PNG')
        img_buffer.seek(0)
        image_data = img_buffer.getvalue()
        
        # Lưu file để cache
        timestamp = int(datetime.now().timestamp())
        filename = f"qr_static_{timestamp}.png"
        file_path = os.path.join(qr_files_dir, filename)
        img.save(file_path)
        
        from fastapi.responses import Response
        return Response(content=image_data, media_type="image/png")
        
    except Exception as e:
        print(f"❌ QR Code Image Error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"QR Code image error: {str(e)}"
        )

@router.delete("/{qr_id}")
async def delete_qr_code(
    qr_id: int,
    current_user = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    """Delete a QR code"""
    try:
        from sqlalchemy import text
        
        # Kiểm tra QR code có tồn tại không
        result = db.execute(text("SELECT id, content FROM qr_codes WHERE id = :qr_id"), {"qr_id": qr_id})
        row = result.fetchone()
        
        if not row:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="QR code not found"
            )
        
        # Tìm và xoá file QR code
        qr_content = row[1]
        qr_files_dir = os.path.join(settings.upload_dir, "qr_codes")
        
        if os.path.exists(qr_files_dir):
            for filename in os.listdir(qr_files_dir):
                if filename.endswith('.png') and qr_content in filename:
                    file_path = os.path.join(qr_files_dir, filename)
                    if os.path.exists(file_path):
                        try:
                            os.remove(file_path)
                        except Exception as e:
                            print(f"Warning: Could not delete QR file {file_path}: {e}")
        
        # Delete from database
        db.execute(text("DELETE FROM qr_codes WHERE id = :qr_id"), {"qr_id": qr_id})
        db.commit()
        
        return {"message": "QR code deleted successfully"}
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )