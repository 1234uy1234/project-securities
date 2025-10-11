from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..auth import get_current_user, require_manager_or_admin, require_admin, get_password_hash
from ..models import User, UserRole
from ..schemas import UserCreate, UserUpdate, User as UserSchema

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/", response_model=List[UserSchema])
async def get_users(
    skip: int = 0,
    limit: int = 100,
    include_inactive: bool = False,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    query = db.query(User)
    
    # Nếu không phải admin và không yêu cầu xem inactive users
    if not include_inactive and str(current_user.role).lower() != "admin":
        query = query.filter(User.is_active == True)
    
    users = query.offset(skip).limit(limit).all()
    return users

@router.get("/{user_id}", response_model=UserSchema)
async def get_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Users can only see their own info, managers/admins can see all
    current_role = str(current_user.role).lower()
    if current_user.id != user_id and current_role not in ["manager", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@router.post("/", response_model=UserSchema)
async def create_user(
    user_data: UserCreate,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    # Check if username already exists
    existing_user = db.query(User).filter(User.username == user_data.username).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Check if email already exists
    existing_email = db.query(User).filter(User.email == user_data.email).first()
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Normalize roles to string
    requested_role = str(user_data.role).lower()
    current_role = str(current_user.role).lower()

    # Only admins can create managers
    if requested_role == "manager" and current_role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can create manager accounts"
        )
    
    hashed_password = get_password_hash(user_data.password)
    db_user = User(
        username=user_data.username,
        email=user_data.email,
        password_hash=hashed_password,
        role=requested_role,
        full_name=user_data.full_name,
        phone=user_data.phone
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@router.put("/{user_id}", response_model=UserSchema)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    current_user: User = Depends(require_manager_or_admin()),
    db: Session = Depends(get_db)
):
    # Only admins can modify other admins
    target_user = db.query(User).filter(User.id == user_id).first()
    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    target_role = str(target_user.role).lower()
    current_role = str(current_user.role).lower()
    if target_role == "admin" and current_role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can modify admin accounts"
        )
    
    # Update fields
    update_data = user_data.dict(exclude_unset=True)
    
    # Prevent self-deactivation
    if "is_active" in update_data and target_user.id == current_user.id and update_data["is_active"] is False:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot deactivate your own account"
        )
    
    # Handle password update separately
    if "password" in update_data and update_data["password"]:
        from ..auth import get_password_hash
        target_user.password_hash = get_password_hash(update_data["password"])
        # Remove password from update_data to avoid setting it directly
        del update_data["password"]
    
    # Normalize role if provided
    if "role" in update_data and update_data["role"] is not None:
        role_value = update_data["role"]
        try:
            from ..models import UserRole as _UR
            if isinstance(role_value, _UR):
                update_data["role"] = role_value.value
            else:
                update_data["role"] = str(role_value).lower()
        except Exception:
            update_data["role"] = str(role_value).lower()
    
    # Update other fields
    for field, value in update_data.items():
        setattr(target_user, field, value)
    
    db.commit()
    db.refresh(target_user)
    return target_user

@router.delete("/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(require_admin()),
    db: Session = Depends(get_db)
):
    if current_user.id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Soft delete - just deactivate
    user.is_active = False
    db.commit()
    
    return {"message": "User deactivated successfully"}

@router.delete("/{user_id}/hard-delete")
async def hard_delete_user(
    user_id: int,
    current_user: User = Depends(require_admin()),
    db: Session = Depends(get_db)
):
    if current_user.id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Hard delete - completely remove from database using raw SQL
    try:
        from sqlalchemy import text
        db.execute(text("DELETE FROM users WHERE id = :user_id"), {"user_id": user_id})
        db.commit()
        
        return {"message": "User permanently deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
