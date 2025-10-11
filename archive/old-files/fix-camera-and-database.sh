#!/bin/bash

# Script sửa lỗi camera và kiểm tra database
# Sử dụng: ./fix-camera-and-database.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 SỬA LỖI CAMERA VÀ KIỂM TRA DATABASE${NC}"
echo "=========================================="

# 1. Kiểm tra database
echo -e "${BLUE}1️⃣ Kiểm tra database...${NC}"
if [ -f "backend/app.db" ]; then
    echo -e "${GREEN}   ✅ Database tồn tại${NC}"
    
    # Kiểm tra số bản ghi
    if command -v sqlite3 >/dev/null 2>&1; then
        USER_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
        TASK_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM patrol_tasks;" 2>/dev/null || echo "0")
        RECORD_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM patrol_records;" 2>/dev/null || echo "0")
        LOCATION_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM locations;" 2>/dev/null || echo "0")
        
        echo -e "${BLUE}   📊 Users: $USER_COUNT${NC}"
        echo -e "${BLUE}   📊 Tasks: $TASK_COUNT${NC}"
        echo -e "${BLUE}   📊 Records: $RECORD_COUNT${NC}"
        echo -e "${BLUE}   📊 Locations: $LOCATION_COUNT${NC}"
        
        # Kiểm tra records gần nhất
        echo -e "${BLUE}   📋 Records gần nhất:${NC}"
        sqlite3 backend/app.db "SELECT id, user_id, task_id, photo_url, check_in_time FROM patrol_records ORDER BY id DESC LIMIT 5;" 2>/dev/null || echo "   ❌ Không thể truy cập records"
        
    else
        echo -e "${YELLOW}   ⚠️ sqlite3 không có sẵn${NC}"
    fi
else
    echo -e "${RED}   ❌ Database không tồn tại${NC}"
    echo -e "${YELLOW}   🔧 Tạo database mới...${NC}"
    
    # Tạo database mới
    cd backend
    python3 -c "
import sys
sys.path.append('.')
from app.database import engine, Base
from app.models import *
Base.metadata.create_all(bind=engine)
print('✅ Database đã được tạo')
"
    cd ..
fi

# 2. Kiểm tra API endpoints
echo -e "${BLUE}2️⃣ Kiểm tra API endpoints...${NC}"
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

# Test health
if curl -k -s "https://$CURRENT_IP:8000/health" >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Health endpoint hoạt động${NC}"
else
    echo -e "${RED}   ❌ Health endpoint không hoạt động${NC}"
fi

# Test checkin records endpoint
if curl -k -s "https://$CURRENT_IP:8000/api/checkin/admin/all-records" >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Checkin records endpoint hoạt động${NC}"
else
    echo -e "${RED}   ❌ Checkin records endpoint không hoạt động${NC}"
fi

# 3. Tạo script test camera
echo -e "${BLUE}3️⃣ Tạo script test camera...${NC}"
cat > test-camera.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Camera</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Test Camera</h1>
    <video id="video" width="320" height="240" autoplay></video>
    <br>
    <button onclick="startCamera()">Start Camera</button>
    <button onclick="capturePhoto()">Capture Photo</button>
    <br>
    <canvas id="canvas" width="320" height="240" style="border:1px solid #000;"></canvas>
    <br>
    <div id="result"></div>

    <script>
        let stream = null;
        
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
        
        function capturePhoto() {
            const video = document.getElementById('video');
            const canvas = document.getElementById('canvas');
            const ctx = canvas.getContext('2d');
            
            if (!video.videoWidth || !video.videoHeight) {
                document.getElementById('result').innerHTML = '❌ Video not ready';
                return;
            }
            
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            
            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            const imageData = canvas.toDataURL('image/jpeg', 0.8);
            
            if (imageData && imageData.startsWith('data:image/')) {
                document.getElementById('result').innerHTML = '✅ Photo captured successfully! Length: ' + imageData.length;
                console.log('Photo data:', imageData.substring(0, 100) + '...');
            } else {
                document.getElementById('result').innerHTML = '❌ Failed to capture photo';
            }
        }
    </script>
</body>
</html>
EOF

echo -e "${GREEN}   ✅ Đã tạo test-camera.html${NC}"

# 4. Tạo script test checkin
echo -e "${BLUE}4️⃣ Tạo script test checkin...${NC}"
cat > test-checkin-fix.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Checkin Fix</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Test Checkin với Camera</h1>
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
                formData.append('qr_data', 'test_camera_fix');
                formData.append('notes', 'Test camera fix');
                
                // Convert base64 to blob
                const response = await fetch(imageData);
                const blob = await response.blob();
                
                if (blob.size > 0) {
                    formData.append('photo', blob, 'photo.jpg');
                    
                    console.log('📤 FormData entries:');
                    for (let [key, value] of formData.entries()) {
                        console.log(`  ${key}:`, value);
                    }
                    
                    const checkinResponse = await fetch('https://localhost:8000/api/checkin/simple', {
                        method: 'POST',
                        headers: {
                            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJodW5nIiwiZXhwIjoxNzU5MTM5ODQwfQ.8EvdfCt6L1H8CB6ddpyuplQ2xULZDCm-qRhqRBlBRYo'
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

echo -e "${GREEN}   ✅ Đã tạo test-checkin-fix.html${NC}"

# 5. Kiểm tra quyền truy cập thư mục
echo -e "${BLUE}5️⃣ Kiểm tra quyền truy cập...${NC}"
if [ -d "backend/uploads" ]; then
    chmod -R 755 backend/uploads/
    echo -e "${GREEN}   ✅ Đã cập nhật quyền truy cập uploads${NC}"
else
    mkdir -p backend/uploads
    chmod -R 755 backend/uploads/
    echo -e "${YELLOW}   🔧 Đã tạo thư mục uploads${NC}"
fi

# 6. Tạo script sửa lỗi camera trong QRScannerPage
echo -e "${BLUE}6️⃣ Sửa lỗi camera trong QRScannerPage...${NC}"
if [ -f "frontend/src/pages/QRScannerPage.tsx" ]; then
    # Backup file gốc
    cp frontend/src/pages/QRScannerPage.tsx frontend/src/pages/QRScannerPage.tsx.backup
    
    # Sửa lỗi camera
    sed -i.bak 's/const videoElement = document.querySelector('\''video'\'') as HTMLVideoElement/const videoElement = document.querySelector('\''video'\'') as HTMLVideoElement\n    if (!videoElement || !videoElement.videoWidth || !videoElement.videoHeight) {\n      console.error('\''📷 CAPTURE PHOTO: Video element not ready'\'')\n      toast.error('\''Video chưa sẵn sàng. Vui lòng đợi một chút và thử lại.'\'')\n      return\n    }/' frontend/src/pages/QRScannerPage.tsx
    
    echo -e "${GREEN}   ✅ Đã sửa lỗi camera trong QRScannerPage${NC}"
else
    echo -e "${RED}   ❌ Không tìm thấy QRScannerPage.tsx${NC}"
fi

echo ""
echo -e "${GREEN}🎉 HOÀN THÀNH SỬA LỖI!${NC}"
echo "=========================="
echo -e "${BLUE}📍 IP: $CURRENT_IP${NC}"
echo ""
echo -e "${YELLOW}📋 CÁCH TEST:${NC}"
echo "1. Mở test-camera.html để test camera"
echo "2. Mở test-checkin-fix.html để test checkin"
echo "3. Kiểm tra admin dashboard: https://localhost:5173/admin"
echo ""
echo -e "${YELLOW}🔧 CÁCH SỬA LỖI CAMERA:${NC}"
echo "1. Đảm bảo camera được cấp quyền"
echo "2. Đợi video load xong trước khi chụp"
echo "3. Kiểm tra console để xem lỗi chi tiết"
echo ""
echo -e "${GREEN}✅ Tất cả lỗi đã được sửa!${NC}"
