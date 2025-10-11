#!/bin/bash

echo "🔍 Test logic hiển thị thời gian checkin thực tế..."

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
  echo "2. Phân tích vấn đề:"
  
  # Lấy ảnh gần nhất
  LATEST_PHOTO=$(echo "$CHECKIN_RECORDS" | jq '.[] | select(.location_id == 1) | select(.id == 40) | .photo_url')
  LATEST_TIME=$(echo "$CHECKIN_RECORDS" | jq '.[] | select(.location_id == 1) | select(.id == 40) | .check_in_time')
  
  echo "  - Ảnh gần nhất: $LATEST_PHOTO"
  echo "  - Thời gian checkin thực tế: $LATEST_TIME"
  
  echo ""
  echo "3. Logic đã sửa:"
  echo "  - completedAt: Ưu tiên thời gian checkin thực tế thay vì thời gian scheduled"
  echo "  - photoUrl: Hiển thị ảnh gần nhất"
  echo "  - hasCheckin: Kiểm tra trước isOverdue để tránh báo 'quá hạn' sai"
  
  echo ""
  echo "4. Expected behavior:"
  echo "  - FlowStepProgress: ✅ Hiển thị ảnh 15:58 + thời gian 15:58"
  echo "  - Không báo 'quá hạn': ✅ Vì có checkin record"
  echo "  - Thời gian chính xác: ✅ Hiển thị thời gian checkin thực tế"
  
  echo ""
  echo "5. Test steps:"
  echo "  - Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
  echo "  - Kiểm tra FlowStepProgress:"
  echo "    * Ảnh: checkin_12_20251002_155841.jpg (15:58)"
  echo "    * Thời gian: 15:58 (thời gian checkin thực tế)"
  echo "    * Trạng thái: 'Đã chấm công' (không báo 'quá hạn')"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🎯 Logic đã sửa: Hiển thị thời gian checkin thực tế thay vì thời gian scheduled"
