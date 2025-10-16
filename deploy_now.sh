#!/bin/bash

echo "🚀 DEPLOY NHƯ NGROK - 1 LỆNH LÀ XONG!"
echo "====================================="

# Dừng tất cả
pkill -f "uvicorn\|npm\|cloudflared" 2>/dev/null || true

echo "🔧 Deploying backend..."
railway login && railway init --name "shopee-backend" --yes && railway up --detach

echo "🎨 Deploying frontend..."
cd frontend && vercel login && vercel --prod --yes

echo "✅ DONE! Check URLs above!"
echo "🔐 Login: admin/admin"









