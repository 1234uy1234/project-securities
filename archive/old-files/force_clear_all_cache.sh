#!/bin/bash

echo "=== FORCE CLEAR ALL CACHE ==="
echo ""

echo "1. Kill tất cả frontend processes:"
pkill -f "npm run dev"
pkill -f "vite"
sleep 3

echo "2. Clear npm cache:"
cd frontend
npm cache clean --force

echo "3. Remove node_modules và reinstall:"
rm -rf node_modules package-lock.json
npm install

echo "4. Start frontend mới:"
npm run dev &

echo ""
echo "=== HƯỚNG DẪN CLEAR BROWSER CACHE ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Hard refresh: Ctrl+Shift+R (Windows) hoặc Cmd+Shift+R (Mac)"
echo "3. Hoặc mở Developer Tools (F12) -> Network tab -> Disable cache"
echo "4. Hoặc mở Incognito/Private window"
echo ""
echo "=== CLEAR SERVICE WORKER ==="
echo "1. Mở Developer Tools (F12)"
echo "2. Vào Application tab -> Service Workers"
echo "3. Click 'Unregister' cho tất cả service workers"
echo "4. Vào Storage tab -> Clear storage -> Clear site data"
echo ""
echo "=== TEST SAU KHI CLEAR ==="
echo "1. Đăng nhập với admin/admin123"
echo "2. Tìm task 'Nhiệm vụ tự động - nhà xe'"
echo "3. Click vào FlowStep"
echo "4. Modal phải hiển thị 'Thời gian chấm công' thay vì 'Chưa chấm công'"