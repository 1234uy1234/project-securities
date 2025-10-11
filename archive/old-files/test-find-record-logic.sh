#!/bin/bash

echo "🔍 Test logic tìm checkin record sau khi sửa..."

# Test với user admin
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "✅ Login thành công với admin"
  
  echo ""
  echo "1. Kiểm tra checkin records..."
  
  CHECKIN_RECORDS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records)
  
  echo "Checkin records:"
  echo "$CHECKIN_RECORDS" | jq '.[0:3] | .[] | {id, location_id, check_in_time, photo_url, notes}'
  
  echo ""
  echo "2. Kiểm tra tasks với location_id = 1..."
  
  PATROL_TASKS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  echo "Tasks với location_id = 1:"
  echo "$PATROL_TASKS" | jq '.[] | select(.location_id == 1) | {id, title, status, location_id}'
  
  echo ""
  echo "3. Test logic tìm record:"
  
  # Lấy record với location_id = 1
  RECORD_LOCATION_1=$(echo "$CHECKIN_RECORDS" | jq '.[] | select(.location_id == 1) | select(.id == 40)')
  
  if [ "$RECORD_LOCATION_1" != "null" ] && [ "$RECORD_LOCATION_1" != "" ]; then
    echo "✅ Tìm thấy record với location_id = 1:"
    echo "$RECORD_LOCATION_1" | jq '{id, location_id, check_in_time, photo_url, notes}'
    
    # Lấy photo_url
    PHOTO_URL=$(echo "$RECORD_LOCATION_1" | jq -r '.photo_url')
    if [ "$PHOTO_URL" != "null" ] && [ "$PHOTO_URL" != "" ]; then
      echo "✅ Photo URL: $PHOTO_URL"
      
      # Test download ảnh
      PHOTO_RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" \
        "https://10.10.68.200:8000/uploads/$PHOTO_URL")
      
      if [ "$PHOTO_RESPONSE" = "200" ]; then
        echo "✅ Ảnh tồn tại và có thể tải được (HTTP $PHOTO_RESPONSE)"
      else
        echo "❌ Ảnh không tồn tại hoặc không thể tải (HTTP $PHOTO_RESPONSE)"
      fi
    else
      echo "❌ Không có photo_url"
    fi
  else
    echo "❌ Không tìm thấy record với location_id = 1"
  fi
  
  echo ""
  echo "4. Expected behavior sau khi sửa:"
  echo "  - findCheckinRecord: Tìm theo location_id thay vì task_id + location_id"
  echo "  - handleStepClick: Tìm record từ API theo location_id"
  echo "  - CheckinDetailModal: Nhận được record với photo_url"
  echo "  - Hiển thị: 'Đã chấm công' với ảnh thay vì 'Chưa chấm công'"
  
  echo ""
  echo "5. Test steps:"
  echo "  - Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
  echo "  - Click vào step có checkin (nhà xe)"
  echo "  - Kiểm tra console log để xem:"
  echo "    * 'Found record:' có giá trị không"
  echo "    * 'Enhanced record for modal:' có photo_url không"
  echo "  - Kiểm tra CheckinDetailModal:"
  echo "    * Status: 'Đã chấm công' (màu xanh)"
  echo "    * Photo: Hiển thị ảnh checkin"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
