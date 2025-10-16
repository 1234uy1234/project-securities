#!/bin/bash

echo "🚀 KHỞI ĐỘNG HỆ THỐNG - PHIÊN BẢN CUỐI CÙNG"
echo "============================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng tất cả processes cũ..."
pkill -f "uvicorn\|npm\|vite\|ssh.*serveo" 2>/dev/null || true
lsof -ti:5173,8000 | xargs kill -9 2>/dev/null || true
sleep 5

# Khởi động backend
echo "🔧 Khởi động Backend..."
cd /Users/maybe/Documents/shopee
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 8

# Khởi động frontend
echo "🎨 Khởi động Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev &
FRONTEND_PID=$!
sleep 8

# Kiểm tra frontend đã chạy chưa
echo "🔍 Kiểm tra frontend..."
if curl -s http://localhost:5173 > /dev/null; then
    echo "✅ Frontend đã sẵn sàng"
else
    echo "❌ Frontend chưa sẵn sàng, đợi thêm..."
    sleep 5
fi

# Khởi động Serveo với subdomain cố định
echo "🌐 Khởi động Serveo Tunnel..."
cd /Users/maybe/Documents/shopee

# Tạo SSH key nếu chưa có
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔑 Tạo SSH key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q
fi

# Khởi động Serveo
ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R manhtoan-patrol:80:localhost:5173 serveo.net &
SERVEO_PID=$!
sleep 10

# Kiểm tra Serveo
echo "🔍 Kiểm tra Serveo tunnel..."
if curl -s https://manhtoan-patrol.serveo.net > /dev/null; then
    echo "✅ Serveo tunnel hoạt động"
else
    echo "⚠️ Serveo tunnel đang khởi động, đợi thêm..."
    sleep 10
fi

# Cập nhật cấu hình
echo "🔄 Cập nhật cấu hình..."
SERVEO_URL="https://manhtoan-patrol.serveo.net"

# Cập nhật frontend config
cat > /Users/maybe/Documents/shopee/frontend/config.js << EOF
// Cấu hình động cho frontend
export const config = {
  API_BASE_URL: '$SERVEO_URL',
  API_TIMEOUT: 10000,
  SSL_VERIFY: false
}

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
    
    frontend_base_url: str = "$SERVEO_URL"
    
    class Config:
        env_file = None
        env_file_encoding = "utf-8"
        case_sensitive = False

settings = Settings()
os.makedirs(settings.upload_dir, exist_ok=True)
EOF

echo "✅ Cấu hình đã được cập nhật"

# Khởi động lại backend để áp dụng cấu hình mới
echo "🔄 Khởi động lại Backend để áp dụng cấu hình mới..."
kill $BACKEND_PID 2>/dev/null
sleep 3
python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
sleep 8

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
echo "🔄 URL này sẽ KHÔNG THAY ĐỔI!"

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