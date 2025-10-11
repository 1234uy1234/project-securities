#!/bin/bash

echo "🔍 Test debug log để kiểm tra thời gian hiển thị..."

# Test với user admin
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "✅ Login thành công với admin"
  
  echo ""
  echo "1. Kiểm tra checkin records với location_id = 1..."
  
  CHECKIN_RECORDS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records)
  
  echo "Latest checkin record với location_id = 1:"
  echo "$CHECKIN_RECORDS" | jq '.[] | select(.location_id == 1) | select(.id == 40) | {id, location_id, check_in_time, photo_url, notes}'
  
  echo ""
  echo "2. Kiểm tra tasks với location_id = 1..."
  
  TASKS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  echo "Tasks với location_id = 1:"
  echo "$TASKS" | jq '.[] | select(.location_id == 1) | {id, title, location_id, status, created_at}'
  
  echo ""
  echo "3. Debug log sẽ hiển thị trong browser console:"
  echo "  - Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
  echo "  - Mở Developer Tools (F12)"
  echo "  - Xem Console tab"
  echo "  - Tìm log: '🔍 Stop X (1):'"
  echo "  - Kiểm tra:"
  echo "    * scheduled_time: Thời gian scheduled (15:30)"
  echo "    * completed_at: Thời gian completed (có thể null)"
  echo "    * latestCheckin_time: Thời gian checkin thực tế (15:58)"
  echo "    * latestCheckin_photo: Ảnh checkin (checkin_12_20251002_155841.jpg)"
  echo "    * final_completedAt: Thời gian cuối cùng được hiển thị"
  
  echo ""
  echo "4. Expected behavior:"
  echo "  - final_completedAt: 15:58 (thời gian checkin thực tế)"
  echo "  - latestCheckin_photo: checkin_12_20251002_155841.jpg"
  echo "  - FlowStepProgress: Hiển thị 15:58 thay vì 15:30"
  
  echo ""
  echo "5. Nếu vẫn hiển thị 15:30:"
  echo "  - Có thể do cache browser"
  echo "  - Refresh trang (Ctrl+F5)"
  echo "  - Hoặc logic completedAt chưa được áp dụng đúng"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🎯 Kiểm tra debug log trong browser console để xem thời gian hiển thị"
