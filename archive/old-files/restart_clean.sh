#!/bin/bash

echo "=== CLEAR CACHE VÀ RESTART FRONTEND ==="

# Kill tất cả processes
echo "1. Killing all processes..."
pkill -f vite
pkill -f uvicorn
sleep 3

# Clear cache
echo "2. Clearing cache..."
cd frontend
rm -rf node_modules/.vite
rm -rf dist
rm -rf .vite
npm cache clean --force

# Reinstall dependencies
echo "3. Reinstalling dependencies..."
npm install

# Start backend
echo "4. Starting backend..."
cd ../backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --ssl-keyfile key.pem --ssl-certfile cert.pem > ../backend.log 2>&1 &

# Start frontend
echo "5. Starting frontend..."
cd ../frontend
npm run dev > ../frontend.log 2>&1 &

echo "✅ Services started!"
echo ""
echo "Truy cập:"
echo "- Frontend: https://localhost:5173"
echo "- Backend: https://localhost:8000"
echo ""
echo "Nếu vẫn lỗi SSL, trust certificate:"
echo "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /Users/maybe/Documents/shopee/frontend/cert.pem"
