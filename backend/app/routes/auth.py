from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from datetime import timedelta
from ..database import get_db
from ..auth import authenticate_user, create_access_token, get_current_user, get_password_hash
from ..schemas import LoginRequest, Token, User, ForgotPasswordRequest, ResetPasswordRequest
from ..models import User as UserModel
from datetime import datetime, timedelta, timezone
import secrets
from ..config import settings

router = APIRouter(prefix="/auth", tags=["authentication"])

@router.post("/login", response_model=Token)
async def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    user = authenticate_user(db, login_data.username, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@router.post("/refresh", response_model=Token)
async def refresh_token(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": current_user.username}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": current_user
    }

@router.get("/me", response_model=User)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    return current_user

# Password reset flow (email delivery to be integrated later)
@router.post("/forgot-password")
async def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user: UserModel | None = db.query(UserModel).filter(UserModel.email == payload.email).first()
    if not user:
        # Do not reveal whether email exists
        return {"message": "If that email exists, a reset link was sent"}

    token = secrets.token_urlsafe(32)
    user.reset_token = token
    user.reset_expires = datetime.now(timezone(timedelta(hours=7))) + timedelta(hours=1)
    db.commit()

    # In production, send email with link containing token. For now, return token for testing
    return {"message": "Reset token generated", "token": token}

@router.post("/reset-password")
async def reset_password(payload: ResetPasswordRequest, db: Session = Depends(get_db)):
    user: UserModel | None = db.query(UserModel).filter(UserModel.reset_token == payload.token).first()
    if not user or not user.reset_expires or user.reset_expires < datetime.now(timezone(timedelta(hours=7))):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired token")

    user.password_hash = get_password_hash(payload.new_password)
    user.reset_token = None
    user.reset_expires = None
    db.commit()
    return {"message": "Password updated successfully"}
