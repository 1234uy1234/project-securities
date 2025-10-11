#!/bin/bash

echo "=== TEST CUỐI CÙNG - FRONTEND MỚI ==="
echo ""

echo "1. Frontend mới đang chạy:"
ps aux | grep "npm run dev" | grep -v grep

echo ""
echo "2. Kiểm tra API vẫn hoạt động:"
curl -k -s "https://10.10.68.200:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 29) | {id, check_in_time, photo_url, task_title, location_name}' | head -10

echo ""
echo "=== HƯỚNG DẪN TEST CUỐI CÙNG ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Hard refresh: Ctrl+Shift+R (Windows) hoặc Cmd+Shift+R (Mac)"
echo "3. Đăng nhập với admin/admin123"
echo "4. Mở Developer Tools (F12) -> Console tab"
echo "5. Tìm task 'Nhiệm vụ tự động - nhà xe'"
echo "6. Click vào FlowStep (vòng tròn số 1)"
echo ""
echo "=== KẾT QUẢ MONG ĐỢI ==="
echo "✅ FlowStep: Hiển thị 'Đã chấm công' với thời gian 15:30 màu xanh"
echo "✅ Modal: Hiển thị 'Thời gian chấm công' với '01/10/2025, 15:30:13'"
echo "✅ Ảnh: Hiển thị ảnh thực tế thay vì placeholder đỏ"
echo "✅ Console: Hiển thị debug logs"
echo ""
echo "=== NẾU VẪN KHÔNG HOẠT ĐỘNG ==="
echo "Có thể vấn đề là:"
echo "1. Browser cache vẫn chưa clear hết"
echo "2. Service worker vẫn cache code cũ"
echo "3. Logic trong code có vấn đề"
echo ""
echo "Hãy thử:"
echo "- Mở Incognito/Private window"
echo "- Clear tất cả browser data"
echo "- Hoặc gửi console logs cho tôi debug"
