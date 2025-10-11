#!/bin/bash

echo "🚀 MANHTOAN PLASTIC - Hệ thống Tuần tra Setup"
echo "================================================"

# Kiểm tra Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 không được cài đặt. Vui lòng cài đặt Python 3.8+"
    exit 1
fi

# Kiểm tra Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js không được cài đặt. Vui lòng cài đặt Node.js 16+"
    exit 1
fi

# Kiểm tra PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL không được cài đặt. Vui lòng cài đặt PostgreSQL"
    exit 1
fi

echo "✅ Tất cả dependencies đã được cài đặt"

# Tạo database
echo "🗄️  Tạo database..."
psql -U postgres -c "CREATE DATABASE patrol_system;" 2>/dev/null || echo "Database đã tồn tại"

# Cài đặt backend
echo "🐍 Cài đặt backend Python..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd ..

# Cài đặt frontend
echo "⚛️  Cài đặt frontend React..."
cd frontend
npm install
cd ..

echo ""
echo "🎉 Cài đặt hoàn tất!"
echo ""
echo "📋 Để chạy hệ thống:"
echo ""
echo "1. Chạy backend:"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   uvicorn app.main:app --reload"
echo ""
echo "2. Chạy frontend (terminal mới):"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo "3. Hoặc sử dụng Docker:"
echo "   docker-compose up -d"
echo ""
echo "🌐 Backend: https://10.10.68.22:8000"
echo "🌐 Frontend: https://10.10.68.22:5173"
echo "📚 API Docs: https://10.10.68.22:8000/docs"
