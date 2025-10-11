from pydantic import BaseModel, EmailStr
from typing import Optional, List, Union
from datetime import datetime
from .models import UserRole, TaskStatus

# Base schemas
class UserBase(BaseModel):
    username: str
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    # Accept both enum and string on input; store/return string
    role: str = UserRole.EMPLOYEE.value

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[UserRole] = None
    is_active: Optional[bool] = None
    password: Optional[str] = None

class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class LocationBase(BaseModel):
    name: str
    description: Optional[str] = None
    address: Optional[str] = None
    gps_latitude: Optional[float] = None
    gps_longitude: Optional[float] = None

class LocationCreate(LocationBase):
    pass

class LocationUpdate(LocationBase):
    name: Optional[str] = None

class Location(LocationBase):
    id: int
    qr_code: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class PatrolTaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    location_id: Union[int, str]  # Can be ID or text description
    assigned_to: Union[int, str]  # Can be ID or text description
    status: Optional[str] = "pending"  # Add status field

class PatrolTaskStopCreate(BaseModel):
    location_id: Optional[Union[int, str]] = None  # Can be ID or location name
    qr_code_id: Optional[int] = None  # QR code ID
    qr_code_name: Optional[str] = None  # QR code name/data
    scheduled_time: Optional[str] = None  # Time in HH:MM format
    required: bool = True

class PatrolTaskCreate(PatrolTaskBase):
    stops: Optional[List[Union[int, str, PatrolTaskStopCreate]]] = None  # list of location IDs, names, or stop objects with time
    pass

class PatrolTaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    location_id: Optional[int] = None
    assigned_to: Optional[int] = None
    schedule_week: Optional[str] = None
    status: Optional[TaskStatus] = None

class PatrolTask(PatrolTaskBase):
    id: int
    status: TaskStatus
    created_at: datetime
    assigned_user: Optional[User] = None
    location: Optional[Location] = None
    
    class Config:
        from_attributes = True

class PatrolRecordBase(BaseModel):
    task_id: int
    location_id: int
    gps_latitude: float
    gps_longitude: float
    notes: Optional[str] = None

class PatrolRecordCreate(PatrolRecordBase):
    pass

class PatrolRecordUpdate(BaseModel):
    check_out_time: Optional[datetime] = None
    notes: Optional[str] = None

class PatrolRecord(PatrolRecordBase):
    id: int
    user_id: int
    check_in_time: datetime
    check_out_time: Optional[datetime] = None
    photo_url: Optional[str] = None  # Ảnh check-in
    checkout_photo_url: Optional[str] = None  # Ảnh check-out
    created_at: datetime
    user: Optional[User] = None
    task: Optional[PatrolTask] = None
    location: Optional[Location] = None
    
    # Computed fields for display
    @property
    def user_name(self) -> str:
        return self.user.full_name if self.user else f"User {self.user_id}"
    
    @property
    def location_name(self) -> str:
        return self.location.name if self.location else f"Location {self.location_id}"
    
    class Config:
        from_attributes = True

# Authentication schemas
class Token(BaseModel):
    access_token: str
    token_type: str
    user: User

class TokenData(BaseModel):
    username: Optional[str] = None

class LoginRequest(BaseModel):
    username: str
    password: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

# Response schemas
class PatrolTaskWithRecords(PatrolTask):
    patrol_records: List[PatrolRecord] = []

class UserWithTasks(User):
    assigned_tasks: List[PatrolTask] = []
    created_tasks: List[PatrolTask] = []

class LocationWithTasks(Location):
    patrol_tasks: List[PatrolTask] = []

# Report schemas
class PatrolReport(BaseModel):
    total_tasks: int
    completed_tasks: int
    pending_tasks: int
    in_progress_tasks: int
    total_records: int
    users_count: int
    locations_count: int

class WeeklyReport(BaseModel):
    week: str
    tasks: List[PatrolTask]
    records: List[PatrolRecord]
    completion_rate: float
