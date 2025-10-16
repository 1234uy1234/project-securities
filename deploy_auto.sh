#!/bin/bash

echo "🚀 DEPLOY TỰ ĐỘNG - VERCEL + RAILWAY"
echo "===================================="

# Dừng tất cả processes cũ
echo "🛑 Dừng processes cũ..."
pkill -f "uvicorn\|npm\|cloudflared" 2>/dev/null || true
sleep 2

# Kiểm tra Railway CLI
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI chưa cài đặt!"
    echo "🔧 Đang cài đặt Railway CLI..."
    curl -fsSL https://railway.app/install.sh | sh
    echo "✅ Railway CLI đã cài đặt!"
fi

# Kiểm tra Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI chưa cài đặt!"
    echo "🔧 Đang cài đặt Vercel CLI..."
    npm install -g vercel
    echo "✅ Vercel CLI đã cài đặt!"
fi

echo ""
echo "🎯 BƯỚC 1: DEPLOY BACKEND LÊN RAILWAY"
echo "====================================="

# Deploy backend
echo "🔧 Deploying backend to Railway..."
railway login
railway init --name "shopee-backend"
railway up

# Lấy URL backend
echo "🌐 Lấy URL backend..."
BACKEND_URL=$(railway domain)
echo "✅ Backend URL: $BACKEND_URL"

echo ""
echo "🎨 BƯỚC 2: DEPLOY FRONTEND LÊN VERCEL"
echo "====================================="

# Vào thư mục frontend
cd frontend

# Cập nhật API URL trong vercel.json
echo "🔧 Cập nhật API URL..."
sed -i '' "s|https://your-backend-url.railway.app|$BACKEND_URL|g" vercel.json

# Deploy frontend
echo "🎨 Deploying frontend to Vercel..."
vercel login
vercel --prod

# Lấy URL frontend
echo "🌐 Lấy URL frontend..."
FRONTEND_URL=$(vercel ls --json | jq -r '.[0].url' | head -n 1)
echo "✅ Frontend URL: https://$FRONTEND_URL"

echo ""
echo "🔗 BƯỚC 3: KẾT NỐI FRONTEND VÀ BACKEND"
echo "======================================"

# Cập nhật environment variable
echo "🔧 Cập nhật API URL trong Vercel..."
vercel env add VITE_API_URL
echo "$BACKEND_URL" | vercel env add VITE_API_URL

# Redeploy frontend
echo "🔄 Redeploying frontend..."
vercel --prod

echo ""
echo "✅ DEPLOY HOÀN TẤT!"
echo "=================="
echo "🌍 Frontend URL: https://$FRONTEND_URL"
echo "🔧 Backend URL: $BACKEND_URL"
echo "🔐 Login: admin/admin"
echo ""
echo "🎉 TRUY CẬP NGAY: https://$FRONTEND_URL"
echo "✅ URL này không bao giờ hết hạn!"
echo "✅ Truy cập từ mọi nơi trên thế giới!"
echo "✅ HTTPS tự động!"

# Quay lại thư mục gốc
cd ..

echo ""
echo "📱 Để truy cập lại sau này:"
echo "   Frontend: https://$FRONTEND_URL"
echo "   Backend: $BACKEND_URL"









