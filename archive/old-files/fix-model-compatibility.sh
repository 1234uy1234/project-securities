#!/bin/bash

# Script tạo model tương thích với database cũ
# Sử dụng: ./fix-model-compatibility.sh

echo "🔧 SỬA MODEL TƯƠNG THÍCH VỚI DATABASE CŨ"
echo "========================================"

# Backup model cũ
cp backend/app/models.py backend/app/models.py.backup

# Tạo model mới tương thích
cat > backend/app/models_compatible.py << 'EOF'
from sqlalchemy import Column, Integer, String, DateTime, Float, Text, ForeignKey, Boolean, Time, LargeBinary
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base
from sqlalchemy import Enum as SAEnum
import enum

class UserRole(str, enum.Enum):
    EMPLOYEE = "employee"
    MANAGER = "manager"
    ADMIN = "admin"

class TaskStatus(str, enum.Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(20), default=UserRole.EMPLOYEE.value)
    full_name = Column(String(100), nullable=False)
    phone = Column(String(20))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    patrol_records = relationship("PatrolRecord", back_populates="user")
    created_tasks = relationship("PatrolTask", foreign_keys="PatrolTask.created_by", back_populates="creator")
    assigned_tasks = relationship("PatrolTask", foreign_keys="PatrolTask.assigned_to", back_populates="assignee")
    face_data = relationship("UserFaceData", back_populates="user", uselist=False)

class Location(Base):
    __tablename__ = "locations"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    qr_code = Column(String(255), unique=True, nullable=True)  # Nullable cho database cũ
    address = Column(String(255))
    gps_latitude = Column(Float)
    gps_longitude = Column(Float)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    patrol_tasks = relationship("PatrolTask", back_populates="location")
    patrol_records = relationship("PatrolRecord", back_populates="location")
    patrol_stops = relationship("PatrolTaskStop", back_populates="location")

class PatrolTask(Base):
    __tablename__ = "patrol_tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=False)
    assigned_to = Column(Integer, ForeignKey("users.id"), nullable=False)
    schedule_week = Column(Text, nullable=False)
    status = Column(SAEnum(TaskStatus), default=TaskStatus.PENDING)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    start_time = Column(DateTime(timezone=True), nullable=True)
    end_time = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    location = relationship("Location", back_populates="patrol_tasks")
    assignee = relationship("User", foreign_keys=[assigned_to], back_populates="assigned_tasks")
    creator = relationship("User", foreign_keys=[created_by], back_populates="created_tasks")
    patrol_records = relationship("PatrolRecord", back_populates="task")
    patrol_stops = relationship("PatrolTaskStop", back_populates="task")

# Model tương thích với database cũ
class PatrolRecord(Base):
    __tablename__ = "patrol_records"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    task_id = Column(Integer, ForeignKey("patrol_tasks.id"), nullable=True)  # Nullable cho database cũ
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=False)
    check_in_time = Column(DateTime(timezone=True), nullable=False)
    check_out_time = Column(DateTime(timezone=True))
    gps_latitude = Column(Float, nullable=True)  # Nullable cho database cũ
    gps_longitude = Column(Float, nullable=True)  # Nullable cho database cũ
    photo_url = Column(String(255))  # Ảnh check-in
    photo_path = Column(String(255))  # Tương thích với database cũ
    checkout_photo_url = Column(String(255))  # Ảnh check-out
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="patrol_records")
    task = relationship("PatrolTask", back_populates="patrol_records")
    location = relationship("Location", back_populates="patrol_records")

class QRCode(Base):
    __tablename__ = "qr_codes"
    
    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String(255), nullable=False)
    qr_url = Column(String(255), nullable=False)
    data = Column(String(255), nullable=False)
    qr_type = Column(String(20), nullable=False)
    qr_content = Column(Text, nullable=False)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=True)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    location = relationship("Location")
    creator = relationship("User")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User")

class PatrolTaskStop(Base):
    __tablename__ = "patrol_task_stops"

    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, ForeignKey("patrol_tasks.id"), nullable=False)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=False)
    sequence = Column(Integer, default=0)
    required = Column(Boolean, default=True)
    scheduled_time = Column(Time, nullable=True)

    # Relationships
    location = relationship("Location", back_populates="patrol_stops")
    task = relationship("PatrolTask", back_populates="patrol_stops")

class UserFaceData(Base):
    __tablename__ = "user_face_data"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True)
    face_encoding = Column(LargeBinary, nullable=False)
    face_image_path = Column(String(500))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="face_data")
EOF

# Thay thế model cũ bằng model mới
mv backend/app/models_compatible.py backend/app/models.py

echo "✅ Đã sửa model tương thích với database cũ!"
echo "📋 Thay đổi chính:"
echo "   - task_id: nullable=True"
echo "   - gps_latitude, gps_longitude: nullable=True"
echo "   - qr_code: nullable=True"
echo "   - Thêm photo_path field"
echo ""
echo "🔄 Cần restart backend để áp dụng thay đổi"
