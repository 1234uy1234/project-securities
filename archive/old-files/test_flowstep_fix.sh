#!/bin/bash

echo "=== TEST FLOWSTEP FIX ==="
echo "1. Kiểm tra checkin record 29 (15:30) có photo_url không:"
curl -k -s "https://10.10.68.200:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 29) | {id, task_id, location_id, check_in_time, photo_url}'

echo ""
echo "2. Kiểm tra task 52 có stops không:"
curl -k -s "https://10.10.68.200:8000/api/patrol-tasks/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 52) | {id, title, stops}'

echo ""
echo "3. Kiểm tra stop của task 52 có completed không:"
sqlite3 backend/app.db "SELECT task_id, location_id, sequence, completed, completed_at, qr_code_name FROM patrol_task_stops WHERE task_id = 52;"

echo ""
echo "=== HƯỚNG DẪN TEST ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Đăng nhập với admin/admin123"
echo "3. Kiểm tra task 'Nhiệm vụ tự động - nhà xe'"
echo "4. FlowStep phải hiển thị 'Đã chấm công' thay vì 'Chờ chấm công'"
echo "5. Thời gian phải hiển thị '15:30' màu xanh"
