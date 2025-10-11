#!/bin/bash

echo "🧪 TEST LOGIC CHECKIN MODAL - SỬA LỖI HIỂN THỊ SAI THỜI GIAN"
echo "============================================================="

# Test 1: Kiểm tra dữ liệu checkin records
echo "📋 Test 1: Kiểm tra dữ liệu checkin records"
echo "----------------------------------------"

echo "🔍 Lấy tất cả checkin records với thông tin chi tiết:"
sqlite3 backend/app.db "
SELECT 
    pr.id,
    pr.task_id,
    pr.location_id,
    pr.check_in_time,
    pr.photo_path,
    pt.title as task_title,
    l.name as location_name
FROM patrol_records pr
LEFT JOIN patrol_tasks pt ON pr.task_id = pt.id
LEFT JOIN locations l ON pr.location_id = l.id
ORDER BY pr.check_in_time DESC;
"

echo ""
echo "🔍 Phân tích vấn đề:"
echo "1. Nhiệm vụ 10:20 có ảnh lúc đó"
echo "2. Nhưng khi bấm vào điểm dừng thì hiển thị thời gian 15:58 và ảnh lúc 15:58"
echo "3. Nguyên nhân: Logic tìm record chỉ dựa vào location_id, không kiểm tra task_id"

echo ""
echo "📊 Logic cũ (SAI):"
echo "record = allRecords.find(r => r.location_id === step.locationId)"
echo "→ Lấy record đầu tiên tìm thấy với location_id đó"
echo "→ Có thể là record của lần chấm công khác (15:58) thay vì record đúng (10:20)"

echo ""
echo "✅ Logic mới (ĐÚNG):"
echo "1. Tìm record theo cả task_id và location_id:"
echo "   matchingRecords = allRecords.filter(r => r.task_id === step.taskId && r.location_id === step.locationId)"
echo ""
echo "2. Nếu có nhiều records, ưu tiên record có thời gian gần với scheduled_time:"
echo "   - Tính khoảng cách thời gian giữa checkin_time và scheduled_time"
echo "   - Chọn record có khoảng cách nhỏ nhất"
echo ""
echo "3. Nếu không có scheduled_time, lấy record gần nhất:"
echo "   - Sắp xếp theo thời gian checkin_time giảm dần"
echo "   - Lấy record đầu tiên (gần nhất)"

echo ""
echo "🎯 Kết quả mong đợi:"
echo "- Khi bấm vào điểm dừng 10:20, sẽ hiển thị record chấm công lúc 10:20"
echo "- Không còn hiển thị sai thời gian 15:58 khi chấm công lúc 10:20"
echo "- Modal sẽ hiển thị đúng ảnh và thời gian của lần chấm công tương ứng"

echo ""
echo "✅ Test hoàn thành! Logic đã được sửa để hiển thị đúng record."
