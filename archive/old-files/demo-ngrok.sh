#!/bin/bash

# Script demo ngrok
echo "🎯 Demo hệ thống với ngrok"
echo "=========================="

# Kiểm tra ngrok
echo "1️⃣ Kiểm tra ngrok..."
if ! command -v ngrok &> /dev/null; then
    echo "❌ Ngrok chưa cài đặt!"
    echo "💡 Chạy: brew install ngrok"
    exit 1
fi

if ! ngrok config check &> /dev/null; then
    echo "❌ Ngrok chưa cấu hình authtoken!"
    echo "💡 Chạy: ./setup-ngrok.sh"
    exit 1
fi

echo "✅ Ngrok đã sẵn sàng"

# Kiểm tra file .env
echo "2️⃣ Kiểm tra file .env..."
if [ ! -f ".env" ]; then
    echo "📝 Tạo file .env..."
    cp env-template.txt .env
fi
echo "✅ File .env đã sẵn sàng"

# Kiểm tra backend
echo "3️⃣ Kiểm tra backend..."
if [ ! -f "backend/app/main.py" ]; then
    echo "❌ Không tìm thấy backend!"
    exit 1
fi
echo "✅ Backend đã sẵn sàng"

# Kiểm tra frontend
echo "4️⃣ Kiểm tra frontend..."
if [ ! -d "frontend" ]; then
    echo "❌ Không tìm thấy frontend!"
    exit 1
fi
echo "✅ Frontend đã sẵn sàng"

echo ""
echo "🎉 Hệ thống đã sẵn sàng!"
echo ""
echo "📋 Để khởi động:"
echo "1. Chạy: python start-with-ngrok.py"
echo "2. Đợi ngrok URL xuất hiện"
echo "3. Chạy: ./start-frontend-with-ngrok.sh"
echo "4. Mở trình duyệt và truy cập ngrok URL"
echo ""
echo "📱 Để test từ điện thoại:"
echo "1. Lấy ngrok URL từ terminal"
echo "2. Mở trình duyệt điện thoại"
echo "3. Truy cập ngrok URL"
echo "4. Hệ thống sẽ hoạt động bình thường!"

