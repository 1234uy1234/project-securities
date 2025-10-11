#!/bin/bash

echo "🔄 Chuyển sang sử dụng localhost thay vì IP..."

# Cập nhật frontend config
if [ -f "frontend/config.js" ]; then
    sed -i.bak "s/API_BASE_URL: 'https:\/\/[^']*'/API_BASE_URL: 'https:\/\/localhost:8000'/g" frontend/config.js
    echo "✅ Đã cập nhật frontend/config.js -> localhost"
fi

# Cập nhật backend config
if [ -f "backend/app/config.py" ]; then
    sed -i.bak "s/frontend_base_url: str = \"https:\/\/[^\"]*\"/frontend_base_url: str = \"https:\/\/localhost:5173\"/g" backend/app/config.py
    echo "✅ Đã cập nhật backend/app/config.py -> localhost"
fi

# Cập nhật api.ts
if [ -f "frontend/src/utils/api.ts" ]; then
    sed -i.bak "s/baseURL: 'https:\/\/[^']*'/baseURL: 'https:\/\/localhost:8000\/api'/g" frontend/src/utils/api.ts
    echo "✅ Đã cập nhật frontend/src/utils/api.ts -> localhost"
fi

echo "🎉 Hoàn thành! Ứng dụng sẽ chạy trên localhost"
echo "Truy cập: https://localhost:5173"
echo "Khởi động lại: ./start-app.sh"
