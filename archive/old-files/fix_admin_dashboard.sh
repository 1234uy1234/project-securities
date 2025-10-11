#!/bin/bash

echo "🔧 SỬA LỖI ADMIN DASHBOARD ĐEN MÀN HÌNH"
echo "========================================"

echo "1. Dọn dẹp frontend processes..."
pkill -f "npm run dev" 2>/dev/null
pkill -f "vite" 2>/dev/null
pkill -f "esbuild" 2>/dev/null
sleep 2

echo "2. Clear npm cache..."
cd frontend
npm cache clean --force

echo "3. Clear node_modules và reinstall..."
rm -rf node_modules package-lock.json
npm install

echo "4. Restart frontend..."
npm run dev &

echo "5. Hướng dẫn clear browser cache:"
echo "   - Mở Chrome DevTools (F12)"
echo "   - Right-click vào refresh button"
echo "   - Chọn 'Empty Cache and Hard Reload'"
echo "   - Hoặc Ctrl+Shift+R (hard refresh)"

echo "6. Nếu vẫn đen, thử:"
echo "   - Mở Incognito mode"
echo "   - Clear service worker: DevTools > Application > Service Workers > Unregister"
echo "   - Clear storage: DevTools > Application > Storage > Clear storage"

echo ""
echo "✅ Hoàn thành! Frontend đang restart..."
echo "🌐 Truy cập: https://10.10.68.200:5173/admin-dashboard"
