#!/bin/bash

# 🛑 DỪNG HỆ THỐNG
echo "🛑 DỪNG HỆ THỐNG"
echo "================"

echo "🛑 Dừng backend..."
pkill -f uvicorn

echo "🛑 Dừng frontend..."
pkill -f vite
pkill -f "npm run dev"

echo "🛑 Dừng ngrok..."
pkill -f ngrok

echo "⏳ Đợi các process dừng..."
sleep 3

echo "✅ Đã dừng tất cả services"
echo "💡 Để khởi động lại: ./start-system-network.sh"
