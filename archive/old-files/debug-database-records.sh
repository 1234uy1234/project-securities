#!/bin/bash

# Script debug database và checkin records
# Sử dụng: ./debug-database-records.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 DEBUG DATABASE VÀ CHECKIN RECORDS${NC}"
echo "====================================="

# 1. Kiểm tra database file
echo -e "${BLUE}1️⃣ Kiểm tra database file...${NC}"
if [ -f "backend/app.db" ]; then
    echo -e "${GREEN}   ✅ Database file tồn tại${NC}"
    echo -e "${BLUE}   📁 Size: $(ls -lh backend/app.db | awk '{print $5}')${NC}"
    echo -e "${BLUE}   📁 Modified: $(ls -l backend/app.db | awk '{print $6, $7, $8}')${NC}"
else
    echo -e "${RED}   ❌ Database file không tồn tại${NC}"
fi

# 2. Kiểm tra tables trong database
echo -e "${BLUE}2️⃣ Kiểm tra tables trong database...${NC}"
if command -v sqlite3 >/dev/null 2>&1; then
    TABLES=$(sqlite3 backend/app.db ".tables" 2>/dev/null)
    if [ -n "$TABLES" ]; then
        echo -e "${GREEN}   ✅ Database có tables:${NC}"
        echo "$TABLES" | tr ' ' '\n' | while read table; do
            if [ -n "$table" ]; then
                COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM $table;" 2>/dev/null || echo "0")
                echo -e "${BLUE}     - $table: $COUNT records${NC}"
            fi
        done
    else
        echo -e "${RED}   ❌ Database không có tables${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️ sqlite3 không có sẵn${NC}"
fi

# 3. Tạo lại database từ đầu
echo -e "${BLUE}3️⃣ Tạo lại database từ đầu...${NC}"
cd backend

# Backup database cũ
if [ -f "app.db" ]; then
    cp app.db app.db.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${YELLOW}   💾 Đã backup database cũ${NC}"
fi

# Tạo database mới
cat > recreate_database.py << 'EOF'
#!/usr/bin/env python3
import sys
import os
sys.path.append('.')

from app.database import engine, Base
from app.models import *
from app.auth import get_password_hash
from datetime import datetime, timedelta
import random

def recreate_database():
    print("🗑️ Dropping all tables...")
    Base.metadata.drop_all(bind=engine)
    
    print("🏗️ Creating all tables...")
    Base.metadata.create_all(bind=engine)
    
    print("👥 Creating users...")
    db = SessionLocal()
    
    try:
        # Tạo admin user
        admin_user = User(
            username="admin",
            email="admin@example.com",
            full_name="Administrator",
            password_hash=get_password_hash("admin123"),
            role="admin",
            is_active=True
        )
        db.add(admin_user)
        
        # Tạo employee user
        employee_user = User(
            username="hung",
            email="hung@example.com",
            full_name="Nguyễn Văn Hùng",
            password_hash=get_password_hash("admin123"),
            role="employee",
            is_active=True
        )
        db.add(employee_user)
        
        db.commit()
        print("✅ Users created")
        
        # Tạo locations
        print("📍 Creating locations...")
        locations_data = [
            {"name": "Cổng chính", "description": "Vị trí cổng chính", "qr_code": "qr_cong_chinh_001"},
            {"name": "Nhà ăn", "description": "Khu vực nhà ăn", "qr_code": "qr_nha_an_002"},
            {"name": "Kho hàng", "description": "Kho chứa hàng", "qr_code": "qr_kho_hang_003"},
        ]
        
        for location_data in locations_data:
            location = Location(
                name=location_data["name"],
                description=location_data["description"],
                qr_code=location_data["qr_code"],
                address=f"Địa chỉ {location_data['name']}",
                gps_latitude=10.762622 + random.uniform(-0.01, 0.01),
                gps_longitude=106.660172 + random.uniform(-0.01, 0.01)
            )
            db.add(location)
        
        db.commit()
        print("✅ Locations created")
        
        # Tạo tasks
        print("📋 Creating tasks...")
        locations = db.query(Location).all()
        
        for i, location in enumerate(locations):
            task = PatrolTask(
                title=f"Nhiệm vụ tuần tra {i+1}",
                description=f"Mô tả nhiệm vụ {i+1}",
                assigned_to=employee_user.id,
                location_id=location.id,
                created_by=admin_user.id,
                status=TaskStatus.PENDING,
                schedule_week='{"date": "' + datetime.now().strftime('%Y-%m-%d') + '", "startTime": "08:00", "endTime": "17:00"}'
            )
            db.add(task)
        
        db.commit()
        print("✅ Tasks created")
        
        # Tạo sample records
        print("📊 Creating sample records...")
        tasks = db.query(PatrolTask).all()
        
        for i, task in enumerate(tasks):
            record = PatrolRecord(
                task_id=task.id,
                user_id=task.assigned_to,
                location_id=task.location_id,
                check_in_time=datetime.now() - timedelta(hours=i),
                photo_url=f"checkin_{task.assigned_to}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg",
                notes=f"Checkin mẫu {i+1}",
                gps_latitude=10.762622 + random.uniform(-0.01, 0.01),
                gps_longitude=106.660172 + random.uniform(-0.01, 0.01),
                created_at=datetime.now() - timedelta(hours=i)
            )
            db.add(record)
        
        db.commit()
        print("✅ Sample records created")
        
        # Kiểm tra kết quả
        user_count = db.query(User).count()
        location_count = db.query(Location).count()
        task_count = db.query(PatrolTask).count()
        record_count = db.query(PatrolRecord).count()
        
        print(f"📊 Final counts:")
        print(f"   - Users: {user_count}")
        print(f"   - Locations: {location_count}")
        print(f"   - Tasks: {task_count}")
        print(f"   - Records: {record_count}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    recreate_database()
EOF

python3 recreate_database.py
rm recreate_database.py

cd ..

# 4. Kiểm tra kết quả
echo -e "${BLUE}4️⃣ Kiểm tra kết quả...${NC}"
if command -v sqlite3 >/dev/null 2>&1; then
    USER_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
    TASK_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM patrol_tasks;" 2>/dev/null || echo "0")
    RECORD_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM patrol_records;" 2>/dev/null || echo "0")
    LOCATION_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM locations;" 2>/dev/null || echo "0")
    
    echo -e "${GREEN}   ✅ Users: $USER_COUNT${NC}"
    echo -e "${GREEN}   ✅ Tasks: $TASK_COUNT${NC}"
    echo -e "${GREEN}   ✅ Records: $RECORD_COUNT${NC}"
    echo -e "${GREEN}   ✅ Locations: $LOCATION_COUNT${NC}"
    
    # Hiển thị records gần nhất
    echo -e "${BLUE}   📋 Records gần nhất:${NC}"
    sqlite3 backend/app.db "SELECT id, user_id, task_id, photo_url, check_in_time FROM patrol_records ORDER BY id DESC LIMIT 5;" 2>/dev/null || echo "   ❌ Không thể truy cập records"
fi

# 5. Test API
echo -e "${BLUE}5️⃣ Test API...${NC}"
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

# Test login
LOGIN_RESPONSE=$(curl -k -s -X POST "https://$CURRENT_IP:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' 2>/dev/null)

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    echo -e "${GREEN}   ✅ Login successful${NC}"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    
    # Test checkin records
    RECORDS_RESPONSE=$(curl -k -s "https://$CURRENT_IP:8000/api/checkin/admin/all-records" \
      -H "Authorization: Bearer $TOKEN" 2>/dev/null)
    
    if echo "$RECORDS_RESPONSE" | grep -q "id"; then
        echo -e "${GREEN}   ✅ Checkin records API working${NC}"
        RECORD_COUNT_API=$(echo "$RECORDS_RESPONSE" | grep -o '"id"' | wc -l)
        echo -e "${BLUE}   📋 API returned $RECORD_COUNT_API records${NC}"
    else
        echo -e "${RED}   ❌ Checkin records API failed${NC}"
    fi
else
    echo -e "${RED}   ❌ Login failed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 DEBUG HOÀN THÀNH!${NC}"
echo "======================"
echo -e "${BLUE}📍 IP: $CURRENT_IP${NC}"
echo ""
echo -e "${YELLOW}📋 CÁCH KIỂM TRA:${NC}"
echo "1. Truy cập: https://localhost:5173"
echo "2. Đăng nhập với admin/admin123"
echo "3. Vào Admin Dashboard"
echo "4. Kiểm tra danh sách checkin records"
echo ""
echo -e "${GREEN}✅ Database đã được tạo lại hoàn toàn!${NC}"
