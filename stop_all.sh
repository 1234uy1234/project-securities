#!/bin/bash

# 🛑 STOP ALL - Dừng toàn bộ hệ thống
echo "🛑 DỪNG TOÀN BỘ HỆ THỐNG"
echo "========================="

echo "🛑 Dừng backend..."
pkill -f "uvicorn" 2>/dev/null || true

echo "🛑 Dừng frontend..."
pkill -f "npm.*dev" 2>/dev/null || true

echo "🛑 Dừng ngrok..."
pkill -f "ngrok" 2>/dev/null || true

sleep 2

echo "✅ Đã dừng tất cả services"
echo "🚀 Để khởi động lại: ./start_all.sh"
