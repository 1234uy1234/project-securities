#!/bin/bash

echo "🚀 DEPLOY 1 LỆNH - NHƯ NGROK!"
echo "============================="

# Dừng processes cũ
pkill -f "uvicorn\|npm\|cloudflared" 2>/dev/null || true

echo "🔧 Đang deploy backend lên Railway..."
railway login
railway init --name "shopee-backend" --yes
railway up --detach

echo "🎨 Đang deploy frontend lên Vercel..."
cd frontend
vercel login
vercel --prod --yes

echo "✅ HOÀN TẤT! URL sẽ hiển thị bên dưới:"
echo "🌍 Truy cập ngay: [URL sẽ hiển thị]"
echo "🔐 Login: admin/admin"









