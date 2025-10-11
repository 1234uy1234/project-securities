#!/bin/bash

echo "=== TEST MODAL FIX ==="
echo ""

echo "1. Kiểm tra record 29 có đầy đủ thông tin không:"
curl -k -s "https://10.10.68.200:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 29) | {id, task_id, location_id, check_in_time, photo_url, user_name, task_title}'

echo ""
echo "2. Kiểm tra task 52 có stops không:"
curl -k -s "https://10.10.68.200:8000/api/patrol-tasks/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 52) | {id, title, stops: .stops[0]}'

echo ""
echo "=== ĐÃ SỬA ==="
echo "✅ Logic handleStepClick đã được cập nhật"
echo "✅ Nếu không tìm thấy record trong local state, sẽ fetch từ API"
echo "✅ Modal sẽ hiển thị record thực tế thay vì mock record"
echo ""
echo "=== HƯỚNG DẪN TEST ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Đăng nhập với admin/admin123"
echo "3. Tìm task 'Nhiệm vụ tự động - nhà xe'"
echo "4. Click vào FlowStep (vòng tròn số 1)"
echo "5. Modal sẽ hiển thị:"
echo "   - ✅ 'Thời gian chấm công' (thay vì 'Trạng thái chấm công')"
echo "   - ✅ Thời gian: '01/10/2025, 15:30:13' (thay vì 'Chưa chấm công')"
echo "   - ✅ Ảnh: Hiển thị ảnh thực tế (thay vì 'Chưa chấm công')"
echo "   - ✅ Ghi chú: Thông tin thực tế (thay vì mock notes)"
echo ""
echo "=== DEBUG CONSOLE ==="
echo "Mở Developer Tools (F12) và xem Console logs:"
echo "- 'Record not found in local state, fetching from API...'"
echo "- 'Found record from API: {...}'"
echo "- 'Showing real checkin record'"
