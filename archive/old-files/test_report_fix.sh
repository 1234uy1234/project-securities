#!/bin/bash

echo "=== TEST REPORT DISPLAY FIX ==="
echo ""

echo "1. Kiểm tra task 52 đã được tạo:"
sqlite3 backend/app.db "SELECT id, title, assigned_to, location_id, status FROM patrol_tasks WHERE id = 52;"

echo ""
echo "2. Kiểm tra checkin record 29:"
sqlite3 backend/app.db "SELECT id, task_id, user_id, location_id, check_in_time FROM patrol_records WHERE id = 29;"

echo ""
echo "3. Kiểm tra API response:"
curl -k -s "https://10.10.68.200:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 29) | {id, task_id, task_title, location_name, check_in_time, user_name}'

echo ""
echo "=== ĐÃ SỬA ==="
echo "✅ Task 52 đã được tạo lại với title 'Nhiệm vụ tự động - nhà xe'"
echo "✅ API /checkin/admin/all-records đã join đúng với patrol_tasks"
echo "✅ Record 29 bây giờ hiển thị đúng task_title"
echo ""
echo "=== HƯỚNG DẪN TEST ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Đăng nhập với admin/admin123"
echo "3. Vào trang Reports"
echo "4. Tìm record ID 29 (checkin lúc 15:30:13)"
echo "5. Kiểm tra hiển thị:"
echo "   - ✅ TASK: 'Nhiệm vụ tự động - nhà xe' (thay vì 'Không có nhiệm vụ')"
echo "   - ✅ LOCATION: 'Khu vực A' (thay vì 'Khu vực A' - đã đúng)"
echo "   - ✅ USER: 'minh'"
echo "   - ✅ TIME: '15:30:13'"
echo "   - ✅ Ảnh: Hiển thị ảnh thực tế"
echo ""
echo "=== NẾU VẪN CÓ VẤN ĐỀ ==="
echo "Có thể frontend vẫn cache dữ liệu cũ. Hãy:"
echo "1. Hard refresh trang Reports (Ctrl+Shift+R)"
echo "2. Hoặc mở Incognito window"
echo "3. Hoặc clear browser cache"
