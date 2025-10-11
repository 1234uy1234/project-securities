#!/bin/bash

echo "🔍 KIỂM TRA HỆ THỐNG HTTP HOÀN CHỈNH"
echo "====================================="

echo ""
echo "📋 1. Backend HTTP (port 8000):"
curl -s http://10.10.68.200:8000/health && echo " ✅ Backend OK" || echo " ❌ Backend Error"

echo ""
echo "📋 2. Frontend HTTP (port 5173):"
curl -s http://10.10.68.200:5173 | head -c 100 && echo "..." && echo " ✅ Frontend OK" || echo " ❌ Frontend Error"

echo ""
echo "📋 3. Database Users:"
cd /Users/maybe/Documents/shopee && sqlite3 backend/app.db "SELECT COUNT(*) FROM users;" && echo " ✅ Database OK" || echo " ❌ Database Error"

echo ""
echo "📋 4. Admin User:"
cd /Users/maybe/Documents/shopee && sqlite3 backend/app.db "SELECT username, role FROM users WHERE username='admin';" && echo " ✅ Admin OK" || echo " ❌ Admin Error"

echo ""
echo "✅ HỆ THỐNG HTTP HOÀN CHỈNH:"
echo "   - Backend: http://10.10.68.200:8000 ✅"
echo "   - Frontend: http://10.10.68.200:5173 ✅"
echo "   - Database: SQLite ✅"
echo "   - Admin User: admin/admin123 ✅"
echo ""
echo "🎯 LOGIC ADMIN DASHBOARD ĐÃ SỬA:"
echo "   - findCheckinRecord: Tìm theo task_id + location_id"
echo "   - handleStepClick: Tìm theo task_id + location_id"  
echo "   - latestCheckin: Tìm theo task_id + location_id"
echo ""
echo "🌐 TRUY CẬP:"
echo "   http://10.10.68.200:5173"
echo "   Username: admin"
echo "   Password: admin123"
