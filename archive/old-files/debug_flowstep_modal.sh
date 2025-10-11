#!/bin/bash

echo "=== DEBUG FLOWSTEP MODAL ISSUE ==="
echo ""

echo "1. Kiểm tra record 29 có tồn tại không:"
curl -k -s "https://10.10.68.200:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 29) | {id, task_id, location_id, check_in_time, user_name}'

echo ""
echo "2. Kiểm tra task 52 có stops không:"
curl -k -s "https://10.10.68.200:8000/api/patrol-tasks/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTc1OTMwOTQ4MH0.FsvT3xspBpWyVwupoEV3cSY1A2oKXO6yMdOLmX4zAkY" | \
  jq '.[] | select(.id == 52) | {id, title, stops: .stops[0]}'

echo ""
echo "3. Kiểm tra stop của task 52:"
sqlite3 backend/app.db "SELECT task_id, location_id, sequence, completed, completed_at FROM patrol_task_stops WHERE task_id = 52;"

echo ""
echo "=== VẤN ĐỀ CÓ THỂ LÀ ==="
echo "1. Frontend không load được records từ API"
echo "2. Logic findCheckinRecord không tìm thấy record"
echo "3. Modal hiển thị mock record thay vì real record"
echo ""
echo "=== HƯỚNG DẪN DEBUG ==="
echo "1. Mở Developer Tools (F12)"
echo "2. Vào Console tab"
echo "3. Click vào FlowStep của task 'Nhiệm vụ tự động - nhà xe'"
echo "4. Xem console logs để debug:"
echo "   - '🔍 Finding checkin record for task: 52 location: 1'"
echo "   - 'Available records: [...]'"
echo "   - 'Found record: ...'"
echo "5. Nếu 'Found record: null' thì có vấn đề với việc tìm record"
echo "6. Nếu 'Found record: {...}' thì có vấn đề với modal display"
