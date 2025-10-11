#!/bin/bash

echo "🔍 Test logic mới: Tìm ảnh đúng với thời gian scheduled..."

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
  
  echo "Tất cả checkin records với location_id = 1:"
  echo "$CHECKIN_RECORDS" | jq '.[] | select(.location_id == 1) | {id, location_id, check_in_time, photo_url, notes}' | head -10
  
  echo ""
  echo "2. Phân tích logic mới:"
  
  # Lấy thời gian 16:01
  RECORD_16_01=$(echo "$CHECKIN_RECORDS" | jq '.[] | select(.check_in_time | contains("16:01")) | {id, check_in_time, photo_url}')
  echo "  - Record 16:01: $RECORD_16_01"
  
  # Lấy thời gian 15:58
  RECORD_15_58=$(echo "$CHECKIN_RECORDS" | jq '.[] | select(.check_in_time | contains("15:58")) | {id, check_in_time, photo_url}')
  echo "  - Record 15:58: $RECORD_15_58"
  
  echo ""
  echo "3. Logic mới:"
  echo "  - Tìm checkin record có thời gian GẦN NHẤT với scheduled_time"
  echo "  - Nếu scheduled_time = 16:01 → Chọn Record 16:01"
  echo "  - Nếu scheduled_time = 15:58 → Chọn Record 15:58"
  echo "  - Không còn lấy ảnh gần nhất theo thời gian"
  
  echo ""
  echo "4. Expected behavior:"
  echo "  - Task với scheduled_time = 16:01 → Hiển thị ảnh 16:01"
  echo "  - Task với scheduled_time = 15:58 → Hiển thị ảnh 15:58"
  echo "  - Không còn hiển thị ảnh sai"
  
  echo ""
  echo "5. Test steps:"
  echo "  - Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
  echo "  - Kiểm tra debug log trong console:"
  echo "    * Tìm log: '🔍 Stop X (1):'"
  echo "    * Kiểm tra: latestCheckin_time phải khớp với scheduled_time"
  echo "    * Kiểm tra: latestCheckin_photo phải đúng với thời gian"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🎯 Logic mới: Tìm ảnh đúng với thời gian scheduled thay vì ảnh gần nhất"

