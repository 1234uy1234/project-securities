#!/bin/bash

# Script để cấu hình ngrok
echo "🔧 Cấu hình ngrok..."

# Kiểm tra ngrok đã cài đặt chưa
if ! command -v ngrok &> /dev/null; then
    echo "❌ Ngrok chưa được cài đặt!"
    echo "💡 Cài đặt ngrok:"
    echo "   - macOS: brew install ngrok"
    echo "   - Hoặc tải từ: https://ngrok.com/download"
    exit 1
fi

echo "✅ Ngrok đã được cài đặt"

# Kiểm tra authtoken
if ! ngrok config check &> /dev/null; then
    echo "🔑 Ngrok cần authentication token!"
    echo ""
    echo "📋 Hướng dẫn:"
    echo "1. Truy cập: https://dashboard.ngrok.com/signup"
    echo "2. Đăng ký tài khoản miễn phí"
    echo "3. Lấy authtoken từ: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "4. Chạy lệnh: ngrok config add-authtoken YOUR_TOKEN"
    echo ""
    echo "💡 Sau khi cấu hình xong, chạy lại script này"
    exit 1
fi

echo "✅ Ngrok đã được cấu hình"
echo "🚀 Bây giờ bạn có thể chạy: python start-with-ngrok.py"

