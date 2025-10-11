#!/bin/bash
# Script chạy HTTP mode cho PWA (dễ cài đặt hơn)

echo "🌐 Starting HTTP mode for PWA..."

# Kill existing processes
echo "🛑 Stopping existing services..."
pkill -f vite
pkill -f uvicorn
sleep 2

# Start backend with HTTP
echo "🚀 Starting backend (HTTP)..."
cd backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 3

# Start frontend with HTTP
echo "🚀 Starting frontend (HTTP)..."
cd frontend
npm run dev -- --host 0.0.0.0 --port 5174 &
FRONTEND_PID=$!
cd ..

# Wait for frontend to start
sleep 5

echo ""
echo "✅ Services started successfully!"
echo "🌐 Backend: http://localhost:8000"
echo "📱 Frontend: http://localhost:5174"
echo "📱 PWA Install: http://localhost:5174"
echo ""
echo "📋 PWA Installation (HTTP mode - EASY):"
echo "1. Open http://localhost:5174 on mobile"
echo "2. Tap 'Install App' or browser menu"
echo "3. App will be installed on home screen"
echo ""
echo "⚠️ Note: HTTP mode is less secure but much easier to install"
echo "📱 QR Code: pwa_install_http_5174.png"
echo ""
echo "⌨️ Press Ctrl+C to stop services"

# Handle Ctrl+C
trap 'echo ""; echo "🛑 Stopping services..."; kill $BACKEND_PID $FRONTEND_PID; exit' INT

# Keep running
wait