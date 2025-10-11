#!/bin/bash

# Script để khởi động frontend với ngrok URL
# Sử dụng: ./start-frontend-with-ngrok.sh

echo "🚀 Khởi động Frontend với ngrok URL..."

# Kiểm tra file .env
if [ ! -f ".env" ]; then
    echo "❌ File .env không tồn tại!"
    echo "💡 Tạo file .env từ template:"
    echo "   cp env-template.txt .env"
    exit 1
fi

# Đọc NGROK_URL từ .env
NGROK_URL=$(grep "NGROK_URL=" .env | cut -d'=' -f2)

if [ -z "$NGROK_URL" ] || [ "$NGROK_URL" = "https://placeholder.ngrok.io" ]; then
    echo "❌ NGROK_URL chưa được cập nhật trong .env!"
    echo "💡 Chạy script start-with-ngrok.py trước để tạo ngrok URL"
    exit 1
fi

echo "✅ Sử dụng ngrok URL: $NGROK_URL"

# Cập nhật VITE_API_URL trong .env
sed -i.bak "s|VITE_API_URL=.*|VITE_API_URL=$NGROK_URL|" .env

echo "✅ Đã cập nhật VITE_API_URL trong .env"

# Khởi động frontend
echo "🌐 Khởi động frontend..."
cd frontend
npm run dev

