from pydantic_settings import BaseSettings
from typing import Optional
import os

class Settings(BaseSettings):
    database_url: str = "sqlite:///./app.db"
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    upload_dir: str = "/Users/maybe/Documents/shopee/backend/uploads"
    max_file_size: int = 5 * 1024 * 1024
    
    allowed_origins: list = [
        "https://*.serveo.net",
        "https://manhtoan-patrol.serveo.net",
        "http://localhost:5173",
        "http://127.0.0.1:5173"
    ]
    
    frontend_base_url: str = "https://manhtoan-patrol.serveo.net"
    
    class Config:
        env_file = None
        env_file_encoding = "utf-8"
        case_sensitive = False

settings = Settings()
os.makedirs(settings.upload_dir, exist_ok=True)
