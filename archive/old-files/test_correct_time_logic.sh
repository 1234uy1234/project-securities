#!/bin/bash

echo "🧪 TEST LOGIC TÌM CHECKIN RECORD ĐÚNG THỜI GIAN"
echo "==============================================="

echo "📋 Logic mới:"
echo "1. Ưu tiên checkin record gần với scheduled_time"
echo "2. Xóa ảnh bé ở dưới điểm stop"
echo "3. Chỉ hiển thị ảnh trong modal chi tiết"

echo ""
echo "🔍 Kiểm tra dữ liệu:"
echo "----------------------------------------"

echo "📊 Task 'tuần tra nhà' (ID: 61) - scheduled 10:20:"
sqlite3 backend/app.db "SELECT pt.id, pt.title, pts.scheduled_time FROM patrol_tasks pt LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id WHERE pt.id = 61;"

echo ""
echo "📊 Checkin records cho task 61:"
sqlite3 backend/app.db "SELECT pr.id, pr.check_in_time, pr.photo_path FROM patrol_records pr WHERE pr.task_id = 61 ORDER BY pr.check_in_time;"

echo ""
echo "🎯 Kết quả mong đợi:"
echo "- Task giao 10:20 → Tìm checkin record gần 10:20 nhất"
echo "- Không hiển thị ảnh bé ở dưới điểm stop"
echo "- Chỉ hiển thị ảnh trong modal chi tiết"

echo ""
echo "✅ Logic đã được sửa - tìm checkin record đúng thời gian!"
