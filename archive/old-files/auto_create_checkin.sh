#!/bin/bash

# Script tự động tạo checkin record cho task mới
# Sử dụng: ./auto_create_checkin.sh <task_id> <user_id> <location_id>

TASK_ID=$1
USER_ID=$2
LOCATION_ID=$3

if [ -z "$TASK_ID" ] || [ -z "$USER_ID" ] || [ -z "$LOCATION_ID" ]; then
    echo "Sử dụng: $0 <task_id> <user_id> <location_id>"
    echo "Ví dụ: $0 58 1 1"
    exit 1
fi

echo "Tạo checkin record cho task $TASK_ID..."

# Lấy thông tin task
TASK_INFO=$(sqlite3 backend/app.db "SELECT title, assigned_to FROM patrol_tasks WHERE id = $TASK_ID;")
if [ -z "$TASK_INFO" ]; then
    echo "❌ Không tìm thấy task $TASK_ID"
    exit 1
fi

# Lấy thông tin stop
STOP_INFO=$(sqlite3 backend/app.db "SELECT scheduled_time, qr_code_name FROM patrol_task_stops WHERE task_id = $TASK_ID LIMIT 1;")
SCHEDULED_TIME=$(echo "$STOP_INFO" | cut -d'|' -f1)
QR_CODE_NAME=$(echo "$STOP_INFO" | cut -d'|' -f2)

# Tạo thời gian checkin (scheduled_time + 5 phút)
if [ -n "$SCHEDULED_TIME" ]; then
    # Parse scheduled_time (HH:MM)
    HOUR=$(echo "$SCHEDULED_TIME" | cut -d':' -f1)
    MINUTE=$(echo "$SCHEDULED_TIME" | cut -d':' -f2)
    
    # Thêm 5 phút
    MINUTE=$((MINUTE + 5))
    if [ $MINUTE -ge 60 ]; then
        MINUTE=$((MINUTE - 60))
        HOUR=$((HOUR + 1))
    fi
    
    CHECKIN_TIME="2025-10-01 $(printf "%02d:%02d:00" $HOUR $MINUTE)"
else
    CHECKIN_TIME="2025-10-01 16:00:00"
fi

# Tạo tên file ảnh
PHOTO_NAME="checkin_${TASK_ID}_$(date +%Y%m%d_%H%M%S).jpg"

# Tạo checkin record
sqlite3 backend/app.db "INSERT INTO patrol_records (task_id, user_id, location_id, check_in_time, photo_path, notes) VALUES ($TASK_ID, $USER_ID, $LOCATION_ID, '$CHECKIN_TIME', '$PHOTO_NAME', 'Auto checkin cho task $TASK_ID');"

# Cập nhật stop
sqlite3 backend/app.db "UPDATE patrol_task_stops SET completed = 1, completed_at = '$CHECKIN_TIME' WHERE task_id = $TASK_ID;"

echo "✅ Đã tạo checkin record cho task $TASK_ID"
echo "   - Thời gian: $CHECKIN_TIME"
echo "   - Ảnh: $PHOTO_NAME"
echo "   - Stop: completed = 1"
