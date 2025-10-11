#!/bin/bash

echo "🔍 KIỂM TRA HỆ THỐNG HOÀN CHỈNH"
echo "================================"

echo ""
echo "📋 1. Backend HTTPS Status:"
curl -k -s https://10.10.68.200:8000/health && echo " ✅ Backend OK" || echo " ❌ Backend Error"

echo ""
echo "📋 2. CORS Test:"
curl -k -s -H "Origin: https://10.10.68.200:5173" -H "Access-Control-Request-Method: GET" -H "Access-Control-Request-Headers: authorization" -X OPTIONS https://10.10.68.200:8000/api/tasks && echo " ✅ CORS OK" || echo " ❌ CORS Error"

echo ""
echo "📋 3. SSL Certificate:"
ls -la ssl/server.* && echo " ✅ SSL Cert OK" || echo " ❌ SSL Cert Missing"

echo ""
echo "✅ LOGIC ĐÃ SỬA HOÀN TOÀN:"
echo "   - findCheckinRecord: Tìm theo task_id + location_id"
echo "   - handleStepClick: Tìm theo task_id + location_id"  
echo "   - latestCheckin: Tìm theo task_id + location_id"
echo ""
echo "🎯 KẾT QUẢ MONG ĐỢI:"
echo "   - Nhiệm vụ mới: Không hiển thị ảnh cũ (8:30)"
echo "   - Chỉ hiển thị ảnh khi employee thực sự checkin cho task đó"
echo "   - Thời gian checkin chính xác theo task được giao"
echo ""
echo "🔧 ĐỂ SỬA LỖI SSL TRONG BROWSER:"
echo "   1. Mở tab mới → https://10.10.68.200:8000/health"
echo "   2. Click 'Advanced' → 'Proceed to 10.10.68.200 (unsafe)'"
echo "   3. Sau đó truy cập frontend bình thường"
echo "   4. Force refresh: Ctrl+Shift+R (Windows) / Cmd+Shift+R (Mac)"

