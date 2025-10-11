#!/bin/bash

echo "🌐 SETUP NGROK VỚI AUTH TOKEN - URL CỐ ĐỊNH"
echo "==========================================="

# Cài đặt ngrok
echo "🔧 Cài đặt ngrok..."
brew install ngrok/ngrok/ngrok

# Đăng ký ngrok (miễn phí)
echo "📝 Đăng ký ngrok:"
echo "1. Truy cập: https://dashboard.ngrok.com/signup"
echo "2. Đăng ký tài khoản miễn phí"
echo "3. Lấy Auth Token từ: https://dashboard.ngrok.com/get-started/your-authtoken"
echo "4. Chạy: ngrok config add-authtoken YOUR_TOKEN"
echo ""
echo "✅ Sau khi setup xong, chạy: ./start_ngrok_fixed.sh"
echo "🌍 URL sẽ cố định: https://your-app.ngrok-free.app"

