#!/bin/bash

echo "🔍 KIỂM TRA LOGIC TASK CHÍNH XÁC"
echo "================================="

echo ""
echo "📋 1. Kiểm tra tasks hiện tại:"
sqlite3 database/patrol_system.db "
SELECT 
    pt.id as task_id,
    pt.name as task_name,
    pt.assigned_user,
    pt.created_at,
    COUNT(pts.id) as total_stops
FROM patrol_tasks pt
LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id
GROUP BY pt.id
ORDER BY pt.created_at DESC
LIMIT 5;
"

echo ""
echo "📋 2. Kiểm tra checkin records theo task_id:"
sqlite3 database/patrol_system.db "
SELECT 
    pr.id as record_id,
    pr.task_id,
    pr.location_id,
    pr.check_in_time,
    pr.photo_path,
    pt.name as task_name
FROM patrol_records pr
JOIN patrol_tasks pt ON pr.task_id = pt.id
ORDER BY pr.check_in_time DESC
LIMIT 10;
"

echo ""
echo "📋 3. Kiểm tra task mới nhất và checkin records của nó:"
sqlite3 database/patrol_system.db "
SELECT 
    pt.id as task_id,
    pt.name as task_name,
    pt.created_at,
    COUNT(pr.id) as checkin_count,
    GROUP_CONCAT(pr.check_in_time) as checkin_times
FROM patrol_tasks pt
LEFT JOIN patrol_records pr ON pt.id = pr.task_id
GROUP BY pt.id
ORDER BY pt.created_at DESC
LIMIT 3;
"

echo ""
echo "📋 4. Kiểm tra checkin records theo location_id (có thể gây nhầm lẫn):"
sqlite3 database/patrol_system.db "
SELECT 
    pr.location_id,
    COUNT(pr.id) as total_checkins,
    GROUP_CONCAT(DISTINCT pr.task_id) as task_ids,
    GROUP_CONCAT(pr.check_in_time) as checkin_times
FROM patrol_records pr
GROUP BY pr.location_id
ORDER BY pr.location_id;
"

echo ""
echo "✅ LOGIC MỚI: Chỉ lấy checkin record của task hiện tại"
echo "   - findCheckinRecord: record.task_id === taskId && record.location_id === locationId"
echo "   - handleStepClick: r.task_id === step.taskId && r.location_id === step.locationId"
echo "   - latestCheckin: record.task_id === task.id && record.location_id === stop.location_id"
