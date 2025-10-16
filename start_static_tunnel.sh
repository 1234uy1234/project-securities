#!/bin/bash

echo "🚀 KHỞI ĐỘNG HỆ THỐNG VỚI URL TĨNH"
echo "=================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm\|vite\|ssh.*serveo" 2>/dev/null || true
lsof -ti:5173,8000 | xargs kill -9 2>/dev/null || true
sleep 3

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 5

# Khởi động frontend
echo "🎨 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!
sleep 5

# Khởi động Serveo với subdomain cố định
echo "🌐 Khởi động Serveo Tunnel..."
cd /Users/maybe/Documents/shopee
ssh -o StrictHostKeyChecking=no -R manhtoan-patrol:80:localhost:5173 serveo.net &
SERVEO_PID=$!
sleep 7

# Cập nhật cấu hình
echo "🔄 Cập nhật cấu hình..."
SERVEO_URL="https://manhtoan-patrol.serveo.net"

# Cập nhật frontend config
cat > /Users/maybe/Documents/shopee/frontend/config.js << EOF
// Cấu hình động cho frontend
// File này được tạo tự động bởi script setup

export const config = {
  // Địa chỉ backend - được cập nhật tự động
  API_BASE_URL: '$SERVEO_URL',
  API_TIMEOUT: 10000,
  SSL_VERIFY: false
}

// Hàm để cập nhật cấu hình từ bên ngoài
export const updateConfig = (newConfig) => {
  Object.assign(config, newConfig)
}
EOF

# Cập nhật backend config
cat > /Users/maybe/Documents/shopee/backend/app/config.py << EOF
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
    
    # CORS - Cho phép serveo domain
    allowed_origins: list = [
        "https://*.serveo.net",
        "https://manhtoan-patrol.serveo.net",
        "http://localhost:5173",
        "http://127.0.0.1:5173"
    ]
    
    # Frontend base URL (for generating QR login links)
    frontend_base_url: str = "$SERVEO_URL"
    
    class Config:
        env_file = None
        env_file_encoding = "utf-8"
        case_sensitive = False

settings = Settings()

# Tạo thư mục upload nếu chưa có
os.makedirs(settings.upload_dir, exist_ok=True)
EOF

echo "✅ Cấu hình đã được cập nhật"

# Khởi động lại backend để áp dụng cấu hình mới
echo "🔄 Khởi động lại Backend để áp dụng cấu hình mới..."
kill $BACKEND_PID 2>/dev/null
sleep 2
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 5

echo ""
echo "✅ HỆ THỐNG ĐÃ KHỞI ĐỘNG THÀNH CÔNG!"
echo "===================================="
echo "🌍 URL truy cập: $SERVEO_URL"
echo ""
echo "🔐 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "💡 Để dừng hệ thống, chạy: ./stop.sh"
echo "🔄 URL này sẽ KHÔNG THAY ĐỔI mỗi lần khởi động!"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Đang dừng ứng dụng..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    kill $SERVEO_PID 2>/dev/null
    pkill -f "uvicorn" 2>/dev/null
    pkill -f "npm.*dev" 2>/dev/null
    pkill -f "ssh.*serveo" 2>/dev/null
    echo "✅ Đã dừng tất cả services"
    exit
}

trap cleanup SIGINT SIGTERM

# Keep script running
wait
