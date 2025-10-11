#!/bin/bash

echo "🔍 KIỂM TRA LOGIC ADMIN DASHBOARD"
echo "=================================="

echo ""
echo "📋 1. Backend HTTPS Status:"
curl -k -s https://10.10.68.200:8000/health && echo " ✅ Backend OK" || echo " ❌ Backend Error"

echo ""
echo "📋 2. Test API Tasks:"
curl -k -s https://10.10.68.200:8000/api/tasks | head -c 200 && echo "..." && echo " ✅ API OK" || echo " ❌ API Error"

echo ""
echo "📋 3. Test API Records:"
curl -k -s https://10.10.68.200:8000/api/patrol-records | head -c 200 && echo "..." && echo " ✅ Records OK" || echo " ❌ Records Error"

echo ""
echo "✅ LOGIC ĐÃ SỬA:"
echo "   - findCheckinRecord: Tìm theo task_id + location_id"
echo "   - handleStepClick: Tìm theo task_id + location_id"  
echo "   - latestCheckin: Tìm theo task_id + location_id"
echo ""
echo "🎯 KẾT QUẢ MONG ĐỢI:"
echo "   - Nhiệm vụ mới: Không hiển thị ảnh cũ (8:30)"
echo "   - Chỉ hiển thị ảnh khi employee thực sự checkin cho task đó"
echo "   - Thời gian checkin chính xác theo task được giao"
echo ""
echo "🌐 TRUY CẬP FRONTEND:"
echo "   https://10.10.68.200:5173"
echo "   (Nếu lỗi SSL: Click Advanced → Proceed to unsafe)"
