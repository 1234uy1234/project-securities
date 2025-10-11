#!/bin/bash

echo "🔍 Test checkin mới và consistency giữa FlowStepProgress và CheckinDetailModal..."

# Test với user admin để chấm công
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "✅ Login thành công với admin"
  
  echo ""
  echo "1. Test checkin mới..."
  
  # Tạo file ảnh giả để test
  echo "fake image data" > /tmp/test_image.jpg
  
  CHECKIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/checkin/simple \
    -H "Authorization: Bearer $TOKEN" \
    -F "qr_content=nhà xe" \
    -F "notes=Test checkin mới $(date)" \
    -F "photo=@/tmp/test_image.jpg")
  
  echo "Checkin response: $CHECKIN_RESPONSE"
  
  echo ""
  echo "2. Kiểm tra checkin records sau khi chấm công..."
  
  CHECKIN_RECORDS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records)
  
  echo "Latest checkin records:"
  echo "$CHECKIN_RECORDS" | jq '.[0:2] | .[] | {id, location_id, check_in_time, photo_url, notes}'
  
  echo ""
  echo "3. Kiểm tra tasks..."
  
  PATROL_TASKS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  echo "Tasks với location_id = 1:"
  echo "$PATROL_TASKS" | jq '.[] | select(.location_id == 1) | {id, title, status, location_id}'
  
  echo ""
  echo "4. Test consistency..."
  
  # Lấy checkin record mới nhất
  LATEST_RECORD=$(echo "$CHECKIN_RECORDS" | jq '.[0]')
  if [ "$LATEST_RECORD" != "null" ]; then
    RECORD_LOCATION_ID=$(echo "$LATEST_RECORD" | jq -r '.location_id')
    RECORD_PHOTO_URL=$(echo "$LATEST_RECORD" | jq -r '.photo_url')
    RECORD_CHECKIN_TIME=$(echo "$LATEST_RECORD" | jq -r '.check_in_time')
    
    echo "Latest checkin record:"
    echo "  Location ID: $RECORD_LOCATION_ID"
    echo "  Photo URL: $RECORD_PHOTO_URL"
    echo "  Check-in time: $RECORD_CHECKIN_TIME"
    
    # Tìm task tương ứng
    MATCHING_TASK=$(echo "$PATROL_TASKS" | jq ".[] | select(.location_id == $RECORD_LOCATION_ID)")
    if [ "$MATCHING_TASK" != "null" ]; then
      TASK_ID=$(echo "$MATCHING_TASK" | jq -r '.id')
      TASK_TITLE=$(echo "$MATCHING_TASK" | jq -r '.title')
      TASK_STATUS=$(echo "$MATCHING_TASK" | jq -r '.status')
      
      echo "  Matching task:"
      echo "    Task ID: $TASK_ID"
      echo "    Title: $TASK_TITLE"
      echo "    Status: $TASK_STATUS"
      
      if [ "$TASK_STATUS" = "completed" ]; then
        echo "    ✅ Task status is completed - FlowStepProgress should show completed"
      else
        echo "    ⚠️ Task status is $TASK_STATUS - FlowStepProgress may show pending"
      fi
      
      echo ""
      echo "5. Expected behavior:"
      echo "  - FlowStepProgress: Should show green circle with checkmark"
      echo "  - CheckinDetailModal: Should show 'Đã chấm công' instead of 'Chưa chấm công'"
      echo "  - Photo: Should display checkin photo"
      
    else
      echo "  ❌ No matching task found for location_id $RECORD_LOCATION_ID"
    fi
  fi
  
  # Cleanup
  rm -f /tmp/test_image.jpg
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🌐 Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
echo "🔍 Kiểm tra:"
echo "  1. FlowStepProgress có hiển thị ảnh checkin không"
echo "  2. Click vào step có hiển thị 'Đã chấm công' trong modal không"
echo "  3. Nhiệm vụ tiếp theo có nhận checkin không"
