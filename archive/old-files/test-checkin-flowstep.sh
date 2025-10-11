#!/bin/bash

echo "🔍 Test checkin mới và FlowStepProgress nhận ngay..."

# Test với user employee để chấm công
echo "1. Login với user employee..."
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "hung", "password": "hung123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "✅ Login thành công với user hung"
  
  echo ""
  echo "2. Test checkin mới..."
  
  # Tạo FormData cho checkin
  CHECKIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/checkin/simple \
    -H "Authorization: Bearer $TOKEN" \
    -F "qr_content=nhà xe" \
    -F "notes=Test checkin mới" \
    -F "photo=@/dev/null")
  
  echo "Checkin response: $CHECKIN_RESPONSE"
  
  echo ""
  echo "3. Kiểm tra checkin records sau khi chấm công..."
  
  # Login với admin để xem records
  ADMIN_LOGIN=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "admin123"}')
  
  ADMIN_TOKEN=$(echo $ADMIN_LOGIN | jq -r '.access_token' 2>/dev/null)
  
  if [ "$ADMIN_TOKEN" != "null" ] && [ "$ADMIN_TOKEN" != "" ]; then
    CHECKIN_RECORDS=$(curl -k -s -H "Authorization: Bearer $ADMIN_TOKEN" \
      https://10.10.68.200:8000/api/checkin/admin/all-records)
    
    echo "Latest checkin records:"
    echo "$CHECKIN_RECORDS" | jq '.[0:2] | .[] | {id, location_id, check_in_time, photo_url}'
    
    echo ""
    echo "4. Kiểm tra FlowStepProgress có nhận checkin không..."
    
    # Lấy tasks để xem FlowStepProgress
    PATROL_TASKS=$(curl -k -s -H "Authorization: Bearer $ADMIN_TOKEN" \
      https://10.10.68.200:8000/api/patrol-tasks/)
    
    echo "Tasks với location_id = 1:"
    echo "$PATROL_TASKS" | jq '.[] | select(.location_id == 1) | {id, title, status, location_id}'
    
  else
    echo "❌ Không thể lấy admin token!"
  fi
  
else
  echo "❌ Không thể login với user hung!"
  echo "Thử với user khác..."
  
  # Thử với user admin
  ADMIN_LOGIN=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "admin123"}')
  
  ADMIN_TOKEN=$(echo $ADMIN_LOGIN | jq -r '.access_token' 2>/dev/null)
  
  if [ "$ADMIN_TOKEN" != "null" ] && [ "$ADMIN_TOKEN" != "" ]; then
    echo "✅ Login thành công với admin"
    
    echo ""
    echo "2. Test checkin với admin..."
    
    CHECKIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/checkin/simple \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -F "qr_content=nhà xe" \
      -F "notes=Test checkin admin" \
      -F "photo=@/dev/null")
    
    echo "Checkin response: $CHECKIN_RESPONSE"
  fi
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🌐 Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
echo "🔍 Kiểm tra FlowStepProgress có hiển thị ảnh checkin mới không"