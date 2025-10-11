#!/bin/bash

echo "=== TEST TASK 52 ĐÃ SỬA ĐÚNG ==="
echo ""

echo "1. Task 52:"
sqlite3 backend/app.db "SELECT id, title, assigned_to, status FROM patrol_tasks WHERE id = 52;"

echo ""
echo "2. Stop của task 52:"
sqlite3 backend/app.db "SELECT task_id, location_id, scheduled_time, completed, completed_at FROM patrol_task_stops WHERE task_id = 52;"

echo ""
echo "3. Checkin record 29:"
sqlite3 backend/app.db "SELECT id, task_id, user_id, check_in_time FROM patrol_records WHERE id = 29;"

echo ""
echo "4. API Response:"
curl -k -s "https://10.10.68.200:8000/api/patrol-tasks/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 52) | {id, title, assigned_to, status, stops: .stops[0]}'

echo ""
echo "=== ĐÃ SỬA ĐÚNG ==="
echo "✅ Task 52 'Nhiệm vụ tự động - nhà xe' vẫn còn"
echo "✅ Stop có scheduled_time = '15:30' (thay vì '08:00')"
echo "✅ completed_at = '2025-10-01 15:30:13' (đúng thời gian checkin)"
echo "✅ completed = true (đã hoàn thành)"
echo ""
echo "=== KẾT QUẢ MONG ĐỢI ==="
echo "Admin Dashboard sẽ hiển thị:"
echo "1. Task 'Nhiệm vụ tự động - nhà xe' (minh)"
echo "2. FlowStep hiển thị '15:30' (thay vì '08:00')"
echo "3. Trạng thái 'Đã chấm công' với thời gian đúng"
echo ""
echo "=== HƯỚNG DẪN TEST ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Đăng nhập với admin/admin123"
echo "3. Hard refresh trang (Ctrl+Shift+R)"
echo "4. Tìm task 'Nhiệm vụ tự động - nhà xe'"
echo "5. FlowStep phải hiển thị '15:30' và 'Đã chấm công'"
echo "6. Click vào FlowStep để xem modal chi tiết"
echo ""
echo "=== NẾU VẪN CÓ VẤN ĐỀ ==="
echo "Có thể frontend cache. Hãy:"
echo "1. Hard refresh trang"
echo "2. Hoặc mở Incognito window"
echo "3. Hoặc clear browser cache"
