#!/bin/bash

echo "🔍 Test checkin mới và debug CheckinDetailModal..."

# Test với user admin để chấm công
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "✅ Login thành công với admin"
  
  echo ""
  echo "1. Test checkin mới với QR content..."
  
  # Tạo file ảnh giả để test
  echo "fake image data" > /tmp/test_image.jpg
  
  CHECKIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/checkin/simple \
    -H "Authorization: Bearer $TOKEN" \
    -F "qr_content=nhà xe" \
    -F "notes=Test checkin mới $(date)" \
    -F "photo=@/tmp/test_image.jpg")
  
  echo "Checkin response: $CHECKIN_RESPONSE"
  
  echo ""
  echo "2. Kiểm tra checkin records mới nhất..."
  
  CHECKIN_RECORDS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records)
  
  echo "Latest checkin record:"
  echo "$CHECKIN_RECORDS" | jq '.[0] | {id, location_id, check_in_time, photo_url, photo_path, notes}'
  
  echo ""
  echo "3. Kiểm tra tasks với location_id = 1..."
  
  PATROL_TASKS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  echo "Tasks với location_id = 1:"
  echo "$PATROL_TASKS" | jq '.[] | select(.location_id == 1) | {id, title, status, location_id}'
  
  echo ""
  echo "4. Expected behavior:"
  echo "  - FlowStepProgress: Should show green circle with checkmark"
  echo "  - CheckinDetailModal: Should show 'Đã chấm công' with photo"
  echo "  - Photo: Should display checkin photo from photo_url"
  
  echo ""
  echo "5. Debug steps:"
  echo "  - Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
  echo "  - Click vào step có checkin"
  echo "  - Kiểm tra console log để xem enhanced record"
  echo "  - Kiểm tra CheckinDetailModal có hiển thị ảnh không"
  
  # Cleanup
  rm -f /tmp/test_image.jpg
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
