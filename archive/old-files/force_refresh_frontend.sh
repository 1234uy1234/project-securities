#!/bin/bash

echo "🔄 FORCE REFRESH FRONTEND - SỬA LỖI FLOWSTEP KHÔNG NHẬN CHECKIN"
echo "=============================================================="

echo "📋 Kiểm tra dữ liệu hiện tại:"
echo "----------------------------------------"

echo "🔍 Task bjsucd:"
sqlite3 backend/app.db "SELECT pt.id, pt.title, pt.status, pts.completed, pts.completed_at FROM patrol_tasks pt LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id WHERE pt.title LIKE '%bjsucd%';"

echo ""
echo "🔍 Checkin records cho task bjsucd:"
sqlite3 backend/app.db "SELECT pr.id, pr.task_id, pr.check_in_time, pr.photo_path FROM patrol_records pr WHERE pr.task_id = 67;"

echo ""
echo "🔍 Tất cả checkin records gần đây:"
sqlite3 backend/app.db "SELECT pr.id, pr.task_id, pr.check_in_time, pr.photo_path, pt.title FROM patrol_records pr LEFT JOIN patrol_tasks pt ON pr.task_id = pt.id ORDER BY pr.check_in_time DESC LIMIT 5;"

echo ""
echo "🎯 Hướng dẫn sửa lỗi FlowStep:"
echo "1. Mở Admin Dashboard trong browser"
echo "2. Nhấn F12 để mở Developer Tools"
echo "3. Vào tab Console"
echo "4. Nhấn F5 để refresh trang"
echo "5. Kiểm tra console logs để xem logic getLocationStatus"
echo ""
echo "6. Nếu vẫn không hiển thị, thử:"
echo "   - Xóa cache browser (Ctrl+Shift+Delete)"
echo "   - Hard refresh (Ctrl+F5)"
echo "   - Restart backend server"

echo ""
echo "✅ Script hoàn thành!"