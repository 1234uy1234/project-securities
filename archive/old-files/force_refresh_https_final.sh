#!/bin/bash

echo "🔄 FORCE REFRESH - HTTPS FINAL"
echo "==============================="

echo ""
echo "📋 1. Backend status:"
curl -k -s https://10.10.68.200:8000/health && echo " ✅ Backend OK" || echo " ❌ Backend Error"

echo ""
echo "📋 2. Force refresh browser:"
echo "   - Mở Developer Tools (F12)"
echo "   - Right-click vào Refresh button"
echo "   - Chọn 'Empty Cache and Hard Reload'"
echo "   - Hoặc Ctrl+Shift+R (Windows) / Cmd+Shift+R (Mac)"

echo ""
echo "📋 3. Nếu vẫn lỗi SSL:"
echo "   - Truy cập: https://10.10.68.200:8000/health"
echo "   - Click 'Advanced' -> 'Proceed to 10.10.68.200 (unsafe)'"
echo "   - Sau đó truy cập frontend bình thường"

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

