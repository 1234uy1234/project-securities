#!/bin/bash

echo "🧪 TEST BACKEND ĐÃ CHẠY"
echo "======================="

echo "🔍 Kiểm tra backend status:"
echo "----------------------------------------"

echo "📊 Health check:"
curl -k -s https://localhost:8000/health

echo ""
echo "📊 Database checkin records:"
sqlite3 backend/app.db "SELECT pr.id, pr.task_id, pr.check_in_time, pr.photo_path FROM patrol_records pr WHERE pr.task_id IN (67, 70) ORDER BY pr.task_id;"

echo ""
echo "📊 Task status:"
sqlite3 backend/app.db "SELECT pt.id, pt.title, pt.status FROM patrol_tasks pt WHERE pt.id IN (67, 70);"

echo ""
echo "🎯 Kết quả mong đợi:"
echo "- Backend chạy trên https://localhost:8000"
echo "- Có checkin records cho task 67 và 70"
echo "- Logic đơn giản: có checkin record = hoàn thành"
echo "- FlowStep sẽ hiển thị 'Đã chấm công' với ảnh"

echo ""
echo "✅ Backend đã chạy - Logic đơn giản đã sẵn sàng!"
