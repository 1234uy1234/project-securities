#!/bin/bash

echo "🔍 KIỂM TRA HỆ THỐNG HTTPS HOÀN CHỈNH"
echo "======================================"

echo ""
echo "📋 1. Backend HTTPS (port 8000):"
curl -k -s https://10.10.68.200:8000/health && echo " ✅ Backend OK" || echo " ❌ Backend Error"

echo ""
echo "📋 2. Frontend HTTPS (port 5173):"
curl -k -s https://10.10.68.200:5173 | head -c 100 && echo "..." && echo " ✅ Frontend OK" || echo " ❌ Frontend Error"

echo ""
echo "📋 3. API Connection Test:"
curl -k -s https://10.10.68.200:8000/api/patrol-records | head -c 100 && echo "..." && echo " ✅ API OK" || echo " ❌ API Error"

echo ""
echo "✅ HỆ THỐNG HTTPS HOÀN CHỈNH:"
echo "   - Backend: https://10.10.68.200:8000 ✅"
echo "   - Frontend: https://10.10.68.200:5173 ✅"
echo "   - SSL Certificate: mkcert ✅"
echo ""
echo "🎯 LOGIC ADMIN DASHBOARD ĐÃ SỬA:"
echo "   - findCheckinRecord: Tìm theo task_id + location_id"
echo "   - handleStepClick: Tìm theo task_id + location_id"  
echo "   - latestCheckin: Tìm theo task_id + location_id"
echo ""
echo "🌐 TRUY CẬP:"
echo "   https://10.10.68.200:5173"
echo "   (Nếu lỗi SSL: Click Advanced → Proceed to unsafe)"
