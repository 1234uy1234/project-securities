#!/bin/bash

# 🛑 STOP - Dừng toàn bộ dự án
echo "🛑 DỪNG TOÀN BỘ DỰ ÁN"
echo "======================"

# Dừng tất cả processes
echo "🛑 Dừng backend..."
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true

echo "🛑 Dừng frontend..."
pkill -f "npm.*dev" 2>/dev/null || true

echo "🛑 Dừng ngrok..."
pkill -f "ngrok" 2>/dev/null || true

sleep 2

echo "✅ ĐÃ DỪNG TẤT CẢ PROCESSES!"
echo "============================="
echo "🔧 Backend: Đã dừng"
echo "🎨 Frontend: Đã dừng"
echo "🌍 Ngrok: Đã dừng"
echo ""
echo "Khởi động lại: ./start.sh"
