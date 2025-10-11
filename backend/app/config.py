from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    # Database - SQLite với backup tự động
    database_url: str = "sqlite:///./app.db"
    
    # JWT
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # File upload
    upload_dir: str = "/Users/maybe/Documents/shopee/backend/uploads"
    max_file_size: int = 5 * 1024 * 1024  # 5MB
    
    # CORS - Cho phép ngrok domain
    allowed_origins: list = [
        "https://*.ngrok-free.app",
        "https://*.ngrok.io",
        "http://localhost:5173",
        "http://127.0.0.1:5173"
    ]
    
    # Frontend base URL (for generating QR login links)
    frontend_base_url: str = "https://truongxuan1234.id.vn"
    
    class Config:
        env_file = None
        env_file_encoding = "utf-8"
        case_sensitive = False

settings = Settings()

# Tạo thư mục upload nếu chưa có
os.makedirs(settings.upload_dir, exist_ok=True)
