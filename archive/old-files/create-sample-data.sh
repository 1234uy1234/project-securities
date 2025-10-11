#!/bin/bash

# Script tạo dữ liệu mẫu và test hệ thống
# Sử dụng: ./create-sample-data.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 TẠO DỮ LIỆU MẪU VÀ TEST HỆ THỐNG${NC}"
echo "======================================="

# 1. Tạo dữ liệu mẫu
echo -e "${BLUE}1️⃣ Tạo dữ liệu mẫu...${NC}"
cd backend

# Tạo script Python để tạo dữ liệu mẫu
cat > create_sample_data.py << 'EOF'
#!/usr/bin/env python3
import sys
import os
sys.path.append('.')

from app.database import SessionLocal
from app.models import User, Location, PatrolTask, PatrolRecord, TaskStatus
from app.auth import get_password_hash
from datetime import datetime, timedelta
import random

def create_sample_data():
    db = SessionLocal()
    
    try:
        # Tạo users
        print("Creating users...")
        users_data = [
            {"username": "admin", "email": "admin@example.com", "full_name": "Administrator", "role": "admin"},
            {"username": "hung", "email": "hung@example.com", "full_name": "Nguyễn Văn Hùng", "role": "employee"},
            {"username": "manager", "email": "manager@example.com", "full_name": "Manager", "role": "manager"},
        ]
        
        for user_data in users_data:
            existing_user = db.query(User).filter(User.username == user_data["username"]).first()
            if not existing_user:
                user = User(
                    username=user_data["username"],
                    email=user_data["email"],
                    full_name=user_data["full_name"],
                    hashed_password=get_password_hash("admin123"),
                    role=user_data["role"],
                    is_active=True
                )
                db.add(user)
                print(f"Created user: {user_data['username']}")
        
        # Tạo locations
        print("Creating locations...")
        locations_data = [
            {"name": "Cổng chính", "description": "Vị trí cổng chính vào nhà máy"},
            {"name": "Nhà ăn", "description": "Khu vực nhà ăn"},
            {"name": "Kho hàng", "description": "Kho chứa hàng hóa"},
            {"name": "Văn phòng", "description": "Khu vực văn phòng"},
            {"name": "Xưởng sản xuất", "description": "Xưởng sản xuất chính"},
        ]
        
        for location_data in locations_data:
            existing_location = db.query(Location).filter(Location.name == location_data["name"]).first()
            if not existing_location:
                location = Location(
                    name=location_data["name"],
                    description=location_data["description"],
                    address=f"Địa chỉ {location_data['name']}",
                    latitude=10.762622 + random.uniform(-0.01, 0.01),
                    longitude=106.660172 + random.uniform(-0.01, 0.01)
                )
                db.add(location)
                print(f"Created location: {location_data['name']}")
        
        db.commit()
        
        # Tạo tasks
        print("Creating tasks...")
        locations = db.query(Location).all()
        users = db.query(User).filter(User.role == "employee").all()
        
        if locations and users:
            for i in range(5):
                task = PatrolTask(
                    title=f"Nhiệm vụ tuần tra {i+1}",
                    description=f"Mô tả nhiệm vụ tuần tra {i+1}",
                    assigned_to=users[0].id,
                    location_id=locations[i % len(locations)].id,
                    status=TaskStatus.PENDING,
                    schedule_week='{"date": "' + datetime.now().strftime('%Y-%m-%d') + '", "startTime": "08:00", "endTime": "17:00"}'
                )
                db.add(task)
                print(f"Created task: {task.title}")
        
        db.commit()
        
        # Tạo sample checkin records
        print("Creating sample checkin records...")
        tasks = db.query(PatrolTask).all()
        
        if tasks:
            for i in range(3):
                task = tasks[i % len(tasks)]
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
                print(f"Created checkin record: {record.id}")
        
        db.commit()
        print("✅ Sample data created successfully!")
        
    except Exception as e:
        print(f"❌ Error creating sample data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_sample_data()
EOF

python3 create_sample_data.py
rm create_sample_data.py

cd ..

# 2. Kiểm tra dữ liệu đã tạo
echo -e "${BLUE}2️⃣ Kiểm tra dữ liệu đã tạo...${NC}"
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
else
    echo -e "${YELLOW}   ⚠️ sqlite3 không có sẵn${NC}"
fi

# 3. Test API endpoints
echo -e "${BLUE}3️⃣ Test API endpoints...${NC}"
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

# Test login
echo -e "${BLUE}   🔐 Testing login...${NC}"
LOGIN_RESPONSE=$(curl -k -s -X POST "https://$CURRENT_IP:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' 2>/dev/null)

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    echo -e "${GREEN}   ✅ Login successful${NC}"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    echo -e "${BLUE}   📋 Token: ${TOKEN:0:20}...${NC}"
else
    echo -e "${RED}   ❌ Login failed${NC}"
    echo -e "${RED}   Response: $LOGIN_RESPONSE${NC}"
fi

# Test checkin records endpoint
if [ -n "$TOKEN" ]; then
    echo -e "${BLUE}   📊 Testing checkin records...${NC}"
    RECORDS_RESPONSE=$(curl -k -s "https://$CURRENT_IP:8000/api/checkin/admin/all-records" \
      -H "Authorization: Bearer $TOKEN" 2>/dev/null)
    
    if echo "$RECORDS_RESPONSE" | grep -q "id"; then
        echo -e "${GREEN}   ✅ Checkin records endpoint working${NC}"
        RECORD_COUNT_API=$(echo "$RECORDS_RESPONSE" | grep -o '"id"' | wc -l)
        echo -e "${BLUE}   📋 API returned $RECORD_COUNT_API records${NC}"
    else
        echo -e "${RED}   ❌ Checkin records endpoint failed${NC}"
        echo -e "${RED}   Response: $RECORDS_RESPONSE${NC}"
    fi
fi

# 4. Tạo file test checkin với token thật
echo -e "${BLUE}4️⃣ Tạo file test checkin...${NC}"
if [ -n "$TOKEN" ]; then
    cat > test-checkin-with-token.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Test Checkin với Token thật</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Test Checkin với Token thật</h1>
    <video id="video" width="320" height="240" autoplay></video>
    <br>
    <button onclick="startCamera()">Start Camera</button>
    <button onclick="captureAndCheckin()">Capture & Checkin</button>
    <br>
    <canvas id="canvas" width="320" height="240" style="border:1px solid #000;"></canvas>
    <br>
    <div id="result"></div>

    <script>
        let stream = null;
        let capturedPhoto = null;
        
        async function startCamera() {
            try {
                stream = await navigator.mediaDevices.getUserMedia({
                    video: {
                        facingMode: 'environment',
                        width: { ideal: 1280 },
                        height: { ideal: 720 }
                    }
                });
                
                const video = document.getElementById('video');
                video.srcObject = stream;
                
                document.getElementById('result').innerHTML = '✅ Camera started successfully';
            } catch (err) {
                document.getElementById('result').innerHTML = '❌ Camera error: ' + err.message;
                console.error('Camera error:', err);
            }
        }
        
        async function captureAndCheckin() {
            const video = document.getElementById('video');
            const canvas = document.getElementById('canvas');
            const ctx = canvas.getContext('2d');
            
            if (!video.videoWidth || !video.videoHeight) {
                document.getElementById('result').innerHTML = '❌ Video not ready';
                return;
            }
            
            // Capture photo
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            
            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            const imageData = canvas.toDataURL('image/jpeg', 0.8);
            
            if (!imageData || !imageData.startsWith('data:image/')) {
                document.getElementById('result').innerHTML = '❌ Failed to capture photo';
                return;
            }
            
            capturedPhoto = imageData;
            document.getElementById('result').innerHTML = '✅ Photo captured! Length: ' + imageData.length;
            
            // Test checkin
            try {
                const formData = new FormData();
                formData.append('qr_data', 'test_sample_data');
                formData.append('notes', 'Test với dữ liệu mẫu');
                
                // Convert base64 to blob
                const response = await fetch(imageData);
                const blob = await response.blob();
                
                if (blob.size > 0) {
                    formData.append('photo', blob, 'photo.jpg');
                    
                    console.log('📤 FormData entries:');
                    for (let [key, value] of formData.entries()) {
                        console.log(\`  \${key}:\`, value);
                    }
                    
                    const checkinResponse = await fetch('https://$CURRENT_IP:8000/api/checkin/simple', {
                        method: 'POST',
                        headers: {
                            'Authorization': 'Bearer $TOKEN'
                        },
                        body: formData
                    });
                    
                    const data = await checkinResponse.json();
                    
                    if (data.photo_url) {
                        document.getElementById('result').innerHTML = '✅ Checkin successful! Photo URL: ' + data.photo_url;
                    } else {
                        document.getElementById('result').innerHTML = '❌ Checkin failed: ' + JSON.stringify(data);
                    }
                } else {
                    document.getElementById('result').innerHTML = '❌ Blob is empty';
                }
            } catch (error) {
                document.getElementById('result').innerHTML = '❌ Checkin error: ' + error.message;
                console.error('Checkin error:', error);
            }
        }
    </script>
</body>
</html>
EOF
    echo -e "${GREEN}   ✅ Đã tạo test-checkin-with-token.html${NC}"
else
    echo -e "${RED}   ❌ Không thể tạo test file vì không có token${NC}"
fi

echo ""
echo -e "${GREEN}🎉 HOÀN THÀNH TẠO DỮ LIỆU MẪU!${NC}"
echo "=================================="
echo -e "${BLUE}📍 IP: $CURRENT_IP${NC}"
echo ""
echo -e "${YELLOW}📋 THÔNG TIN ĐĂNG NHẬP:${NC}"
echo "Username: admin"
echo "Password: admin123"
echo ""
echo -e "${YELLOW}📋 CÁCH TEST:${NC}"
echo "1. Truy cập: https://localhost:5173"
echo "2. Đăng nhập với admin/admin123"
echo "3. Vào Admin Dashboard để xem dữ liệu"
echo "4. Test checkin với test-checkin-with-token.html"
echo ""
echo -e "${GREEN}✅ Dữ liệu mẫu đã được tạo thành công!${NC}"
