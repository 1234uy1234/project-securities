#!/bin/bash

echo "🔍 Test logic đơn giản như Report page..."

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
  echo "2. Logic đơn giản như Report page:"
  echo "  - FlowStepProgress: Hiển thị ảnh gần nhất cho location_id = 1"
  echo "  - CheckinDetailModal: Hiển thị ảnh gần nhất + thông tin checkin"
  echo "  - Không phức tạp hóa: Chỉ cần có checkin = hiển thị ảnh"
  
  echo ""
  echo "3. Expected behavior:"
  echo "  - FlowStepProgress: ✅ Hiển thị green circle + ảnh gần nhất"
  echo "  - CheckinDetailModal: ✅ Hiển thị 'Đã chấm công' + ảnh"
  echo "  - Không lỗi: ✅ Không còn ReferenceError"
  
  echo ""
  echo "4. Test steps:"
  echo "  - Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
  echo "  - Kiểm tra console: Không còn lỗi ReferenceError"
  echo "  - Kiểm tra FlowStepProgress: Hiển thị ảnh gần nhất"
  echo "  - Click vào step: Hiển thị 'Đã chấm công' + ảnh"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🎯 Logic đơn giản như Report page: Có checkin = hiển thị ảnh + hoàn thành"
