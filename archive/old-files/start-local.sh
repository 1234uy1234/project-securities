#!/bin/bash

echo "🚀 Khởi động hệ thống local (không cần ngrok)"
echo "============================================="

# Dừng các process cũ
echo "🛑 Dừng các process cũ..."
pkill -f "uvicorn.*app.main:app" 2>/dev/null
pkill -f "npm run dev" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 2

# Khởi động backend
echo "🐍 Khởi động backend..."
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
cd ..

echo "⏳ Đợi backend khởi động..."
sleep 3

# Khởi động frontend
echo "🌐 Khởi động frontend..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo "⏳ Đợi frontend khởi động..."
sleep 5

echo ""
echo "🎉 Hệ thống đã khởi động!"
echo "🌐 Frontend: http://localhost:5173"
echo "🐍 Backend: http://localhost:8000"
echo ""
echo "💡 Để dừng hệ thống, nhấn Ctrl+C"

# Function để cleanup khi dừng
cleanup() {
    echo ""
    echo "🛑 Đang dừng hệ thống..."
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    pkill -f "uvicorn.*app.main:app" 2>/dev/null
    pkill -f "npm run dev" 2>/dev/null
    pkill -f "vite" 2>/dev/null
    echo "✅ Đã dừng hệ thống"
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT

# Giữ script chạy
wait

