from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone, timedelta
def get_vietnam_time() -> datetime:
    return datetime.now(timezone(timedelta(hours=7)))
import qrcode
import os
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin
from ..models import Location, User, UserRole
from ..schemas import LocationCreate, LocationUpdate, Location as LocationSchema
from ..config import settings

router = APIRouter(prefix="/locations", tags=["locations"])

def generate_qr_code(location_id: int, location_name: str) -> str:
    """Generate QR code for location and return filename"""
    # Create QR code data
    qr_data = f"patrol://location/{location_id}"
    
    # Generate QR code
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(qr_data)
    qr.make(fit=True)
    
    # Create image
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Save to file
    filename = f"location_{location_id}_{location_name.replace(' ', '_')}.png"
    file_path = os.path.join(settings.upload_dir, "qr_codes", filename)
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    img.save(file_path)
    return filename

def generate_login_qr(data: str) -> str:
    """Generate QR image for arbitrary data and return filename"""
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    filename = f"dynamic_{int(get_vietnam_time().timestamp())}.png"
    file_path = os.path.join(settings.upload_dir, "qr_codes", filename)
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    img.save(file_path)
    return filename

@router.get("/", response_model=List[LocationSchema])
async def get_locations(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    locations = db.query(Location).offset(skip).limit(limit).all()
    return locations

@router.get("/{location_id}", response_model=LocationSchema)
async def get_location(
    location_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    location = db.query(Location).filter(Location.id == location_id).first()
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Location not found"
        )
    return location

@router.post("/", response_model=LocationSchema)
async def create_location(
    location_data: LocationCreate,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    # Check if location name already exists
    existing_location = db.query(Location).filter(Location.name == location_data.name).first()
    if existing_location:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Location name already exists"
        )
    
    # Create location
    db_location = Location(**location_data.dict())
    db.add(db_location)
    db.commit()
    db.refresh(db_location)
    
    # Generate QR code
    qr_filename = generate_qr_code(db_location.id, db_location.name)
    db_location.qr_code = qr_filename
    
    db.commit()
    db.refresh(db_location)
    
    return db_location

@router.put("/{location_id}", response_model=LocationSchema)
async def update_location(
    location_id: int,
    location_data: LocationUpdate,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    location = db.query(Location).filter(Location.id == location_id).first()
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Location not found"
        )
    
    # Check if new name conflicts with existing location
    if location_data.name and location_data.name != location.name:
        existing_location = db.query(Location).filter(
            Location.name == location_data.name,
            Location.id != location_id
        ).first()
        if existing_location:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Location name already exists"
            )
    
    # Update fields
    update_data = location_data.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(location, field, value)
    
    location.updated_at = get_vietnam_time()
    db.commit()
    db.refresh(location)
    
    return location

@router.delete("/{location_id}")
async def delete_location(
    location_id: int,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    location = db.query(Location).filter(Location.id == location_id).first()
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Location not found"
        )
    
    # Check if location has any tasks
    from ..models import PatrolTask
    tasks = db.query(PatrolTask).filter(PatrolTask.location_id == location_id).first()
    if tasks:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete location with existing patrol tasks"
        )
    
    # Check if location has any records
    from ..models import PatrolRecord
    records = db.query(PatrolRecord).filter(PatrolRecord.location_id == location_id).first()
    if records:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete location with existing patrol records"
        )
    
    # Delete QR code file if exists
    if location.qr_code:
        qr_file_path = os.path.join(settings.upload_dir, "qr_codes", location.qr_code)
        if os.path.exists(qr_file_path):
            os.remove(qr_file_path)
    
    db.delete(location)
    db.commit()
    
    return {"message": "Location deleted successfully"}

@router.get("/{location_id}/qr-code")
async def get_location_qr_code(
    location_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get QR code image for a location"""
    location = db.query(Location).filter(Location.id == location_id).first()
    if not location:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Location not found"
        )
    
    if not location.qr_code:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="QR code not generated for this location"
        )
    
    qr_file_path = os.path.join(settings.upload_dir, "qr_codes", location.qr_code)
    if not os.path.exists(qr_file_path):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="QR code file not found"
        )
    
    # Return file path for frontend to display
    return {"qr_code_url": f"/uploads/qr_codes/{location.qr_code}"}

# Create QR for login redirection
@router.post("/qr/generate")
async def create_qr_for_login(
    mode: str = "fixed",
    payload: str | None = None,
    current_user: User = Depends(require_manager_or_admin()),
):
    """
    mode: "fixed" -> QR chứa link login thuần: {frontend}/login
          "dynamic" -> QR chứa link {frontend}/login?next=/qr-scanner&ref={payload or timestamp}
    """
    base = settings.frontend_base_url.rstrip('/')
    if mode == "fixed":
        data = f"{base}/login"
    else:
        suffix = payload or str(int(get_vietnam_time().timestamp()))
        data = f"{base}/login?next=/qr-scanner&ref={suffix}"
    filename = generate_login_qr(data)
    return {"qr_code_url": f"/uploads/qr_codes/{filename}", "data": data}
