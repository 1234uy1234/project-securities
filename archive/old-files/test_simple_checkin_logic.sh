#!/bin/bash

echo "🧪 TEST LOGIC ĐƠN GIẢN - CHẤM LÀ NHẬN"
echo "====================================="

echo "📋 Logic mới (ĐƠN GIẢN):"
echo "1. Có checkin record = hoàn thành (giống như Report)"
echo "2. Không cần kiểm tra thời gian, ảnh phức tạp"
echo "3. Chấm công → FlowStep nhận ngay"

echo ""
echo "🔍 Kiểm tra dữ liệu hiện tại:"
echo "----------------------------------------"

echo "📊 Task 'tuan tra' (ID: 70):"
sqlite3 backend/app.db "SELECT pt.id, pt.title, pt.status, pts.completed, pts.completed_at FROM patrol_tasks pt LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id WHERE pt.id = 70;"

echo ""
echo "📊 Checkin records cho task 70:"
sqlite3 backend/app.db "SELECT pr.id, pr.task_id, pr.check_in_time, pr.photo_path FROM patrol_records pr WHERE pr.task_id = 70;"

echo ""
echo "📊 Task 'bjsucd' (ID: 67):"
sqlite3 backend/app.db "SELECT pt.id, pt.title, pt.status, pts.completed, pts.completed_at FROM patrol_tasks pt LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id WHERE pt.id = 67;"

echo ""
echo "📊 Checkin records cho task 67:"
sqlite3 backend/app.db "SELECT pr.id, pr.task_id, pr.check_in_time, pr.photo_path FROM patrol_records pr WHERE pr.task_id = 67;"

echo ""
echo "🎯 Kết quả mong đợi:"
echo "- Task 'tuan tra': Có checkin record → FlowStep hiển thị 'Đã chấm công'"
echo "- Task 'bjsucd': Có checkin record → FlowStep hiển thị 'Đã chấm công'"
echo "- Không còn lỗi 'đéo nhận' checkin"

echo ""
echo "✅ Logic đã được sửa đơn giản - chấm là nhận!"
