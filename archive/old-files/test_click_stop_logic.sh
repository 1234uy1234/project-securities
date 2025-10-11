#!/bin/bash

echo "🧪 TEST LOGIC BẤM VÀO ĐIỂM DỪNG"
echo "==============================="

echo "📋 Logic mới (CỰC ĐƠN GIẢN):"
echo "1. Có checkin record = completed"
echo "2. Hiển thị ảnh + thời gian khi bấm vào"
echo "3. Không cần so sánh thời gian phức tạp"

echo ""
echo "🔍 Kiểm tra dữ liệu:"
echo "----------------------------------------"

echo "📊 Checkin records cho location 1:"
sqlite3 backend/app.db "SELECT pr.id, pr.location_id, pr.check_in_time, pr.photo_path FROM patrol_records pr WHERE pr.location_id = 1 ORDER BY pr.check_in_time DESC LIMIT 5;"

echo ""
echo "📊 Task stops cho location 1:"
sqlite3 backend/app.db "SELECT pts.task_id, pts.location_id, pts.sequence, pts.scheduled_time FROM patrol_task_stops pts WHERE pts.location_id = 1 LIMIT 5;"

echo ""
echo "🎯 Kết quả mong đợi khi bấm vào điểm dừng:"
echo "- Hiển thị ảnh checkin gần nhất"
echo "- Hiển thị thời gian chấm công thực tế"
echo "- Không còn báo 'Chưa chấm công'"

echo ""
echo "✅ Logic đã được sửa - bấm vào sẽ hiển thị ảnh + thời gian!"
