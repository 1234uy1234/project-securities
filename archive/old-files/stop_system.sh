#!/bin/bash

echo "🛑 Dừng hệ thống MANHTOAN PLASTIC - Hệ thống Tuần tra"
echo "=================================================="

# Dừng các process theo PIDs
if [ -f .backend.pid ]; then
    BACKEND_PID=$(cat .backend.pid)
    echo "🛑 Dừng Backend (PID: $BACKEND_PID)..."
    kill $BACKEND_PID 2>/dev/null
    rm .backend.pid
fi

if [ -f .frontend.pid ]; then
    FRONTEND_PID=$(cat .frontend.pid)
    echo "🛑 Dừng Frontend (PID: $FRONTEND_PID)..."
    kill $FRONTEND_PID 2>/dev/null
    rm .frontend.pid
fi

if [ -f .nginx.pid ]; then
    NGINX_PID=$(cat .nginx.pid)
    echo "🛑 Dừng Nginx (PID: $NGINX_PID)..."
    kill $NGINX_PID 2>/dev/null
    rm .nginx.pid
fi

if [ -f .ngrok.pid ]; then
    NGROK_PID=$(cat .ngrok.pid)
    echo "🛑 Dừng Ngrok (PID: $NGROK_PID)..."
    kill $NGROK_PID 2>/dev/null
    rm .ngrok.pid
fi

# Dừng tất cả process còn lại
echo "🛑 Dừng tất cả process còn lại..."
pkill -f "npm run dev" 2>/dev/null
pkill -f "uvicorn" 2>/dev/null
pkill -f "nginx" 2>/dev/null
pkill -f "ngrok" 2>/dev/null

echo "✅ Hệ thống đã dừng hoàn toàn!"
