#!/bin/bash

# Script tạo nhiều tasks cùng lúc
echo "Tạo nhiều tasks với checkin tự động..."

# Danh sách tasks (có thể sửa theo nhu cầu)
TASKS=(
    "Nhiệm vụ tuần tra A|Mô tả tuần tra A|1|1|08:00"
    "Nhiệm vụ tuần tra B|Mô tả tuần tra B|1|1|09:00"
    "Nhiệm vụ tuần tra C|Mô tả tuần tra C|1|1|10:00"
    "Nhiệm vụ tuần tra D|Mô tả tuần tra D|1|1|11:00"
    "Nhiệm vụ tuần tra E|Mô tả tuần tra E|1|1|12:00"
)

for task_info in "${TASKS[@]}"; do
    IFS='|' read -r title description assigned_to location_id scheduled_time <<< "$task_info"
    echo "Tạo task: $title"
    ./create_task_with_checkin.sh "$title" "$description" "$assigned_to" "$location_id" "$scheduled_time"
    echo ""
done

echo "🎉 Đã tạo tất cả tasks với checkin tự động!"
