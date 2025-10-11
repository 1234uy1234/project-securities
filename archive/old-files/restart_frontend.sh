#!/bin/bash

echo "🔄 Restart Frontend hoàn toàn..."

# Dừng frontend
pkill -f "npm run dev" 2>/dev/null
sleep 3

# Clear cache
cd /Users/maybe/Documents/shopee/frontend
rm -rf node_modules/.vite
rm -rf dist
rm -rf .vite

# Restart
echo "🚀 Khởi động lại frontend..."
npm run dev -- --host 0.0.0.0 --port 5173 &

echo "✅ Frontend đã restart!"
