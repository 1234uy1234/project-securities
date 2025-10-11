#!/bin/bash

echo "=== DEBUG MODAL ISSUE ==="
echo ""

echo "1. Kiểm tra frontend có đang chạy không:"
ps aux | grep "npm run dev" | grep -v grep

echo ""
echo "2. Kiểm tra record 29 từ API:"
curl -k -s "https://10.10.68.200:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 29) | {id, check_in_time, photo_url, task_title, location_name}'

echo ""
echo "3. Kiểm tra task 52 có stops không:"
curl -k -s "https://10.10.68.200:8000/api/patrol-tasks/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 52) | {id, title, stops: .stops[0]}'

echo ""
echo "=== HƯỚNG DẪN DEBUG ==="
echo "1. Mở https://10.10.68.200:5173/admin-dashboard"
echo "2. Đăng nhập với admin/admin123"
echo "3. Mở Developer Tools (F12) -> Console tab"
echo "4. Click vào FlowStep của task 'Nhiệm vụ tự động - nhà xe'"
echo "5. Xem console logs:"
echo "   - '🔍 CheckinDetailModal - Record: {...}'"
echo "   - 'Record not found in local state, fetching from API...'"
echo "   - 'Found record from API: {...}'"
echo ""
echo "6. Nếu record.check_in_time là null/undefined:"
echo "   - Có vấn đề với API response"
echo "   - Hoặc logic fetch record có vấn đề"
echo ""
echo "7. Nếu record.check_in_time có giá trị:"
echo "   - Có vấn đề với logic hiển thị trong modal"
