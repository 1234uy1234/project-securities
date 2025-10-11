#!/bin/bash

echo "🔑 Cấu hình ngrok authtoken"
echo "=========================="

echo "📋 Hướng dẫn:"
echo "1. Truy cập: https://dashboard.ngrok.com/signup"
echo "2. Đăng ký tài khoản miễn phí"
echo "3. Xác thực email"
echo "4. Truy cập: https://dashboard.ngrok.com/get-started/your-authtoken"
echo "5. Copy authtoken"
echo ""

read -p "Nhập authtoken của bạn: " AUTHTOKEN

if [ -z "$AUTHTOKEN" ]; then
    echo "❌ Authtoken không được để trống!"
    exit 1
fi

echo "🔧 Đang cấu hình ngrok..."
ngrok config add-authtoken $AUTHTOKEN

if [ $? -eq 0 ]; then
    echo "✅ Đã cấu hình ngrok thành công!"
    echo ""
    echo "🚀 Bây giờ bạn có thể chạy:"
    echo "   ./start-with-ngrok-https.sh"
else
    echo "❌ Lỗi cấu hình ngrok!"
    exit 1
fi

