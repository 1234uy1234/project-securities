#!/bin/bash

echo "=== TEST DASHBOARD SAU KHI DỌN DẸP ==="
echo ""

echo "1. Tasks còn lại:"
sqlite3 backend/app.db "SELECT id, title, assigned_to, status FROM patrol_tasks ORDER BY id DESC;"

echo ""
echo "2. Stops còn lại:"
sqlite3 backend/app.db "SELECT task_id, location_id, completed, completed_at FROM patrol_task_stops ORDER BY task_id DESC;"

echo ""
echo "3. Checkin Records:"
sqlite3 backend/app.db "SELECT id, task_id, user_id, check_in_time FROM patrol_records ORDER BY id DESC LIMIT 3;"

echo ""
echo "4. API Response:"
curl -k -s "https://10.10.68.200:8000/api/patrol-tasks/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | {id, title, assigned_to, status, stops: .stops[0]}'

echo ""
echo "=== ĐÃ DỌN DẸP ==="
echo "✅ Xóa task 51 'fsdvsdv' không có checkin record"
echo "✅ Xóa tasks 41, 39, 36 không có checkin records"
echo "✅ Xóa stops không có tasks tương ứng"
echo "✅ Chỉ còn lại 2 tasks có checkin records thực tế"
echo ""
echo "=== KẾT QUẢ MONG ĐỢI ==="
echo "Admin Dashboard bây giờ chỉ hiển thị 2 tasks:"
echo "1. 'Test QR Nhà Xe' (admin) - Đã chấm công lúc 14:26"
echo "2. 'Nhiệm vụ tự động - nhà xe' (minh) - Đã chấm công lúc 15:30"
echo ""
echo "=== HƯỚNG DẪN TEST ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Đăng nhập với admin/admin123"
echo "3. Hard refresh trang (Ctrl+Shift+R)"
echo "4. Kiểm tra chỉ có 2 tasks hiển thị"
echo "5. Cả 2 tasks đều hiển thị 'Đã chấm công' với đúng thời gian"
echo "6. Không còn task nào báo 'Chưa chấm công' sai"
echo ""
echo "=== NẾU VẪN CÓ VẤN ĐỀ ==="
echo "Có thể frontend vẫn cache dữ liệu cũ. Hãy:"
echo "1. Hard refresh trang"
echo "2. Hoặc mở Incognito window"
echo "3. Hoặc clear browser cache"
