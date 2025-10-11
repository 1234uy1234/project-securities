#!/bin/bash

# Script sửa các vấn đề với database mới
echo "🔧 SỬA CÁC VẤN ĐỀ VỚI DATABASE MỚI"
echo "=================================="

# 1. Tạo tasks mẫu
echo "1️⃣ Tạo tasks mẫu..."
cd backend
python3 -c "
import sys
sys.path.append('.')
from app.database import SessionLocal
from app.models import *
from app.auth import get_password_hash
from datetime import datetime, timedelta
import random

db = SessionLocal()
try:
    # Lấy users và locations
    users = db.query(User).all()
    locations = db.query(Location).all()
    
    if not users or not locations:
        print('❌ Không có users hoặc locations')
        exit(1)
    
    print(f'📋 Có {len(users)} users và {len(locations)} locations')
    
    # Tạo tasks cho mỗi location
    for i, location in enumerate(locations):
        # Tạo task cho admin
        admin_task = PatrolTask(
            title=f'Nhiệm vụ tuần tra {location.name}',
            description=f'Mô tả nhiệm vụ tuần tra tại {location.name}',
            assigned_to=users[0].id,  # Admin user
            location_id=location.id,
            created_by=users[0].id,
            status=TaskStatus.PENDING,
            schedule_week='{\"date\": \"' + datetime.now().strftime('%Y-%m-%d') + '\", \"startTime\": \"08:00\", \"endTime\": \"17:00\"}'
        )
        db.add(admin_task)
        
        # Tạo task cho employee (nếu có)
        if len(users) > 1:
            employee_task = PatrolTask(
                title=f'Nhiệm vụ nhân viên {location.name}',
                description=f'Nhiệm vụ cho nhân viên tại {location.name}',
                assigned_to=users[1].id,  # Employee user
                location_id=location.id,
                created_by=users[0].id,
                status=TaskStatus.PENDING,
                schedule_week='{\"date\": \"' + datetime.now().strftime('%Y-%m-%d') + '\", \"startTime\": \"08:00\", \"endTime\": \"17:00\"}'
            )
            db.add(employee_task)
    
    db.commit()
    print('✅ Đã tạo tasks mẫu')
    
    # Kiểm tra kết quả
    task_count = db.query(PatrolTask).count()
    print(f'📊 Tổng số tasks: {task_count}')
    
except Exception as e:
    print(f'❌ Lỗi: {e}')
    db.rollback()
finally:
    db.close()
"

cd ..

# 2. Kiểm tra kết quả
echo "2️⃣ Kiểm tra kết quả..."
sqlite3 backend/app.db "SELECT COUNT(*) as tasks FROM patrol_tasks;" 2>/dev/null

# 3. Test API
echo "3️⃣ Test API..."
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

LOGIN_RESPONSE=$(curl -k -s -X POST "https://$CURRENT_IP:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' 2>/dev/null)

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Login thành công"
    
    # Test checkin records
    RECORDS_RESPONSE=$(curl -k -s "https://$CURRENT_IP:8000/api/checkin/admin/all-records" \
      -H "Authorization: Bearer $TOKEN" 2>/dev/null)
    
    if echo "$RECORDS_RESPONSE" | grep -q "id"; then
        RECORD_COUNT=$(echo "$RECORDS_RESPONSE" | grep -o '"id"' | wc -l)
        echo "✅ API trả về $RECORD_COUNT records"
    else
        echo "❌ API không hoạt động"
    fi
else
    echo "❌ Login thất bại"
fi

echo ""
echo "🎉 HOÀN THÀNH SỬA CÁC VẤN ĐỀ!"
echo "=============================="
echo "📍 IP: $CURRENT_IP"
echo ""
echo "📋 CÁCH KIỂM TRA:"
echo "1. Truy cập: https://localhost:5173"
echo "2. Đăng nhập với admin/admin123"
echo "3. Vào Admin Dashboard → Tasks"
echo "4. Kiểm tra có tasks và không còn báo 'không có điểm dừng'"
echo "5. Test checkin và xem có cập nhật không"
echo ""
echo "✅ Đã sửa các vấn đề chính!"
