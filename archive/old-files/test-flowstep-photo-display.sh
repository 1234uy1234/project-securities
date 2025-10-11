#!/bin/bash

echo "🔍 Test FlowStepProgress hiển thị ảnh..."

# Test với user admin
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "1. Lấy checkin records..."
  CHECKIN_RECORDS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records)
  
  echo "Checkin records với photo_url:"
  echo "$CHECKIN_RECORDS" | jq '.[0:3] | .[] | {id, location_id, check_in_time, photo_url}'
  
  echo ""
  echo "2. Lấy patrol tasks..."
  PATROL_TASKS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  echo "Patrol tasks với stops:"
  echo "$PATROL_TASKS" | jq '.[0:2] | .[] | {id, title, status, location_id, stops: [.stops[] | {location_id, sequence, scheduled_time, completed}]}'
  
  echo ""
  echo "3. Kiểm tra logic matching..."
  
  # Lấy một checkin record
  FIRST_RECORD=$(echo "$CHECKIN_RECORDS" | jq '.[0]')
  if [ "$FIRST_RECORD" != "null" ]; then
    RECORD_LOCATION_ID=$(echo "$FIRST_RECORD" | jq -r '.location_id')
    RECORD_PHOTO_URL=$(echo "$FIRST_RECORD" | jq -r '.photo_url')
    
    echo "First checkin record:"
    echo "  Location ID: $RECORD_LOCATION_ID"
    echo "  Photo URL: $RECORD_PHOTO_URL"
    
    # Tìm task có location_id tương ứng
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
        echo "    ✅ Task status is completed - FlowStepProgress should show photo"
      else
        echo "    ❌ Task status is not completed - FlowStepProgress may not show photo"
      fi
    else
      echo "  ❌ No matching task found for location_id $RECORD_LOCATION_ID"
    fi
  fi
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🌐 Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
echo "🔍 Kiểm tra FlowStepProgress có hiển thị ảnh không"
