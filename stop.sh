#!/bin/bash

echo "🛑 DỪNG TOÀN BỘ HỆ THỐNG"
echo "========================"

echo "🛑 Đang dừng tất cả services..."
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "npm.*dev" 2>/dev/null || true
pkill -f "ngrok" 2>/dev/null || true
lsof -ti:5173,5174,8000 | xargs kill -9 2>/dev/null || true
sleep 3

echo "✅ TẤT CẢ SERVICES ĐÃ ĐƯỢC DỪNG!"
echo "==============================="
echo "🔧 Backend đã dừng"
echo "🎨 Frontend đã dừng"
echo "🌐 Ngrok tunnel đã tắt"
echo ""
echo "💡 Để khởi động lại, chạy: ./start.sh"