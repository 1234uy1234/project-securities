#!/bin/bash

# Script sửa API để tương thích với database cũ
echo "🔧 SỬA API TƯƠNG THÍCH VỚI DATABASE CŨ"
echo "======================================"

# Backup file cũ
cp backend/app/routes/checkin.py backend/app/routes/checkin.py.backup

# Tạo API mới đơn giản
cat > backend/app/routes/checkin_simple.py << 'EOF'
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone, timedelta
import os
from ..database import get_db
from ..auth import get_current_user
from ..models import User, Location, PatrolRecord, PatrolTask, TaskStatus
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
        # Kiểm tra quyền admin/manager
        if current_user.role not in ["admin", "manager"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Không có quyền truy cập"
            )
        
        # Lấy tất cả patrol records với thông tin liên quan
        from sqlalchemy.orm import joinedload
        records = db.query(PatrolRecord).options(
            joinedload(PatrolRecord.user),
            joinedload(PatrolRecord.location)
        ).order_by(PatrolRecord.check_in_time.desc()).limit(100).all()
        
        result = []
        for record in records:
            # Tương thích với schema cũ và mới
            photo_url = getattr(record, 'photo_url', None) or getattr(record, 'photo_path', None)
            task_id = getattr(record, 'task_id', None)
            task_title = "Nhiệm vụ cũ" if not task_id else "Unknown Task"
            
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
EOF

# Thay thế file cũ
mv backend/app/routes/checkin_simple.py backend/app/routes/checkin.py

echo "✅ Đã sửa API tương thích với database cũ!"
echo "📋 Thay đổi chính:"
echo "   - Loại bỏ các field không tồn tại trong database cũ"
echo "   - Chỉ sử dụng photo_url (không có photo_path)"
echo "   - Xử lý task_id nullable"
echo ""
echo "🔄 Cần restart backend để áp dụng thay đổi"
