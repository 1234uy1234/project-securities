import warnings
from datetime import datetime, timedelta, timezone
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from .database import get_db
from .models import User, UserRole
from .schemas import TokenData
from .config import settings

# Suppress bcrypt warnings
warnings.filterwarnings("ignore", message=".*bcrypt.*")

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT Bearer
security = HTTPBearer()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception:
        # Nếu hash không nhận diện được -> coi như sai mật khẩu (tránh 500)
        return False

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def authenticate_user(db: Session, username: str, password: str) -> Optional[User]:
    user = db.query(User).filter(User.username == username).first()
    if not user:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone(timedelta(hours=7))) + expires_delta
    else:
        expire = datetime.now(timezone(timedelta(hours=7))) + timedelta(minutes=settings.access_token_expire_minutes)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
    return encoded_jwt

def verify_token(token: str) -> Optional[TokenData]:
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        username: str = payload.get("sub")
        if username is None:
            return None
        token_data = TokenData(username=username)
        return token_data
    except JWTError:
        return None

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    token = credentials.credentials
    token_data = verify_token(token)
    if token_data is None:
        raise credentials_exception
    
    user = db.query(User).filter(User.username == token_data.username).first()
    if user is None:
        raise credentials_exception
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    return user

async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False)),
    db: Session = Depends(get_db)
) -> Optional[User]:
    """
    Lấy user hiện tại nếu có token, trả về None nếu không có token
    """
    if not credentials:
        return None
    
    try:
        token = credentials.credentials
        token_data = verify_token(token)
        if token_data is None:
            return None
        
        user = db.query(User).filter(User.username == token_data.username).first()
        if user is None or not user.is_active:
            return None
        
        return user
    except Exception:
        return None

def require_role(required_role: UserRole):
    def role_checker(current_user: User = Depends(get_current_user)):
            # current_user.role may be stored as string in DB
        current_role = (
            current_user.role.value if isinstance(current_user.role, UserRole) else str(current_user.role)
        )
        required = required_role.value if isinstance(required_role, UserRole) else str(required_role)
        if current_role != required and current_role != UserRole.ADMIN.value:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions"
            )
        return current_user
    return role_checker

def require_manager_or_admin():
    def role_checker(current_user: User = Depends(get_current_user)):
        current_role = (
            current_user.role.value if isinstance(current_user.role, UserRole) else str(current_user.role)
        )
        if current_role not in [UserRole.MANAGER.value, UserRole.ADMIN.value]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Manager or Admin access required"
            )
        return current_user
    return role_checker

def require_admin():
    return require_role(UserRole.ADMIN)
#cd /Users/maybe/Documents/shopee
#./quick_start.sh

#cd /Users/maybe/Documents/shopee
#./stop_system.sh