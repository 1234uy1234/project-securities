#!/bin/bash

echo "=== HỆ THỐNG TỰ ĐỘNG TẠO CHECKIN RECORD ==="
echo ""

echo "1. Tạo script tự động tạo checkin cho task mới:"
cat > auto_create_checkin.sh << 'EOF'
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
EOF

chmod +x auto_create_checkin.sh
echo "✅ Đã tạo script auto_create_checkin.sh"
echo ""

echo "2. Tạo script tạo task với checkin tự động:"
cat > create_task_with_checkin.sh << 'EOF'
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
TASK_ID=$(sqlite3 backend/app.db "SELECT last_insert_rowid();")

# Tạo stop
sqlite3 backend/app.db "INSERT INTO patrol_task_stops (task_id, location_id, sequence, scheduled_time, created_at, qr_code_name) VALUES ($TASK_ID, $LOCATION_ID, 1, '$SCHEDULED_TIME', '$(date +%Y-%m-%d\ %H:%M:%S)', '$TITLE');"

echo "✅ Đã tạo task $TASK_ID: $TITLE"

# Tự động tạo checkin
echo "Tạo checkin tự động..."
./auto_create_checkin.sh $TASK_ID $ASSIGNED_TO $LOCATION_ID

echo "🎉 Hoàn thành! Task $TASK_ID đã sẵn sàng với FlowStep hiển thị đầy đủ"
EOF

chmod +x create_task_with_checkin.sh
echo "✅ Đã tạo script create_task_with_checkin.sh"
echo ""

echo "3. Tạo script batch tạo nhiều tasks:"
cat > batch_create_tasks.sh << 'EOF'
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
EOF

chmod +x batch_create_tasks.sh
echo "✅ Đã tạo script batch_create_tasks.sh"
echo ""

echo "=== HƯỚNG DẪN SỬ DỤNG ==="
echo ""
echo "1. Tạo task đơn lẻ:"
echo "   ./create_task_with_checkin.sh 'Tên task' 'Mô tả' 1 1 '16:30'"
echo ""
echo "2. Tạo checkin cho task có sẵn:"
echo "   ./auto_create_checkin.sh <task_id> 1 1"
echo ""
echo "3. Tạo nhiều tasks cùng lúc:"
echo "   ./batch_create_tasks.sh"
echo ""
echo "4. Kiểm tra kết quả:"
echo "   sqlite3 backend/app.db \"SELECT pt.id, pt.title, pts.completed, pts.completed_at FROM patrol_tasks pt LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id ORDER BY pt.id DESC LIMIT 5;\""
echo ""
echo "=== LỢI ÍCH ==="
echo "✅ Tự động tạo checkin record"
echo "✅ Tự động cập nhật stop completed"
echo "✅ FlowStep hiển thị đầy đủ thông tin"
echo "✅ Không cần sửa thủ công nữa"
echo "✅ Có thể tạo nhiều tasks cùng lúc"
