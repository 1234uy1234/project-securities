#!/bin/bash

# Script tạo task mới với checkin tự động
# Sử dụng: ./create_task_with_checkin.sh <title> <description> <assigned_to> <location_id>

TITLE=$1
DESCRIPTION=$2
ASSIGNED_TO=$3
LOCATION_ID=$4
SCHEDULED_TIME=$5

if [ -z "$TITLE" ] || [ -z "$DESCRIPTION" ] || [ -z "$ASSIGNED_TO" ] || [ -z "$LOCATION_ID" ]; then
    echo "Sử dụng: $0 <title> <description> <assigned_to> <location_id> [scheduled_time]"
    echo "Ví dụ: $0 'Nhiệm vụ mới' 'Mô tả' 1 1 '16:30'"
    exit 1
fi

if [ -z "$SCHEDULED_TIME" ]; then
    SCHEDULED_TIME="16:00"
fi

echo "Tạo task mới: $TITLE"

# Tạo task
sqlite3 backend/app.db "INSERT INTO patrol_tasks (title, description, assigned_to, location_id, status, created_at) VALUES ('$TITLE', '$DESCRIPTION', $ASSIGNED_TO, $LOCATION_ID, 'in_progress', '$(date +%Y-%m-%d\ %H:%M:%S)');"

# Lấy task_id vừa tạo
TASK_ID=$(sqlite3 backend/app.db "SELECT id FROM patrol_tasks ORDER BY id DESC LIMIT 1;")

# Tạo stop
sqlite3 backend/app.db "INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, created_at, qr_code_name) VALUES ($TASK_ID, $LOCATION_ID, 1, '$SCHEDULED_TIME', '$(date +%Y-%m-%d\ %H:%M:%S)', '$TITLE');"

echo "✅ Đã tạo task $TASK_ID: $TITLE"

# Tự động tạo checkin
echo "Tạo checkin tự động..."
./auto_create_checkin.sh $TASK_ID $ASSIGNED_TO $LOCATION_ID

echo "🎉 Hoàn thành! Task $TASK_ID đã sẵn sàng với FlowStep hiển thị đầy đủ"
