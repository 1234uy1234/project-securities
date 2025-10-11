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
    # created_tasks = relationship("PatrolTask", foreign_keys="PatrolTask.created_by", back_populates="creator")  # Comment out vì không có created_by
    assigned_tasks = relationship("PatrolTask", foreign_keys="PatrolTask.assigned_to", back_populates="assignee")
    face_data = relationship("UserFaceData", back_populates="user", uselist=False)

class Location(Base):
    __tablename__ = "locations"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    qr_code = Column(String(255), unique=True, nullable=True)  # Nullable cho database cũ
    is_active = Column(Boolean, default=True)  # Có trong database cũ
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    patrol_tasks = relationship("PatrolTask", back_populates="location")
    patrol_records = relationship("PatrolRecord", back_populates="location")

class PatrolTask(Base):
    __tablename__ = "patrol_tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=False)
    assigned_to = Column(Integer, ForeignKey("users.id"), nullable=False)
    status = Column(String(20), default="pending")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    location = relationship("Location", back_populates="patrol_tasks")
    assignee = relationship("User", foreign_keys=[assigned_to], back_populates="assigned_tasks")

# Model HOÀN TOÀN tương thích với database cũ - CHỈ có các field tồn tại
class PatrolRecord(Base):
    __tablename__ = "patrol_records"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=False)
    check_in_time = Column(DateTime(timezone=True), nullable=False)
    check_out_time = Column(DateTime(timezone=True))
    notes = Column(Text)
    photo_path = Column(String(255))  # Sử dụng photo_path thay vì photo_url
    photo_base64 = Column(Text)  # Lưu ảnh dưới dạng base64
    updated_at = Column(DateTime(timezone=True))
    task_id = Column(Integer, ForeignKey("patrol_tasks.id"), nullable=True)  # Thêm task_id
    gps_latitude = Column(Float, nullable=True)
    gps_longitude = Column(Float, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="patrol_records")
    location = relationship("Location", back_populates="patrol_records")

class QRCode(Base):
    __tablename__ = "qr_codes"
    
    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text, nullable=False)  # Khớp với database thực tế
    qr_type = Column(String(20), default='static')  # Khớp với database thực tế
    location = Column(Text, nullable=True)  # Khớp với database thực tế
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    created_by = Column(String(50), nullable=True)  # Khớp với database thực tế
    is_active = Column(Boolean, default=True)  # Khớp với database thực tế

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User")

# Comment out PatrolTaskStop vì không có trong database cũ
class PatrolTaskStop(Base):
    __tablename__ = "patrol_task_stops"
    
    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, ForeignKey("patrol_tasks.id"), nullable=False)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=False)
    sequence = Column(Integer, default=1)
    scheduled_time = Column(String(10), nullable=True)  # VARCHAR(10) như database thực tế
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    qr_code_name = Column(Text, nullable=True)  # TEXT như database thực tế
    completed = Column(Boolean, default=False)  # Trạng thái hoàn thành
    completed_at = Column(DateTime(timezone=True), nullable=True)  # Thời gian hoàn thành

    # Không có relationships để tránh lỗi

class UserFaceData(Base):
    __tablename__ = "user_face_data"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True)
    face_encoding = Column(Text, nullable=False)
    face_image_path = Column(String(500))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    # updated_at = Column(DateTime(timezone=True), onupdate=func.now())  # Comment out vì không có trong database cũ
    
    # Relationships
    user = relationship("User", back_populates="face_data")
