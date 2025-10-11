#!/bin/bash

# Script kiểm tra trạng thái toàn bộ hệ thống
# Sử dụng: ./check-system-status.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 KIỂM TRA TRẠNG THÁI HỆ THỐNG${NC}"
echo "=================================="

# Lấy IP hiện tại
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
echo -e "${YELLOW}📍 IP hiện tại: $CURRENT_IP${NC}"
echo ""

# 1. Kiểm tra processes
echo -e "${BLUE}1️⃣ Kiểm tra processes...${NC}"
BACKEND_PID=$(ps aux | grep "uvicorn.*app.main:app" | grep -v grep | awk '{print $2}')
FRONTEND_PID=$(ps aux | grep "vite.*--host localhost" | grep -v grep | awk '{print $2}')

if [ -n "$BACKEND_PID" ]; then
    echo -e "${GREEN}   ✅ Backend đang chạy (PID: $BACKEND_PID)${NC}"
else
    echo -e "${RED}   ❌ Backend không chạy${NC}"
fi

if [ -n "$FRONTEND_PID" ]; then
    echo -e "${GREEN}   ✅ Frontend đang chạy (PID: $FRONTEND_PID)${NC}"
else
    echo -e "${RED}   ❌ Frontend không chạy${NC}"
fi

# 2. Kiểm tra kết nối API
echo -e "${BLUE}2️⃣ Kiểm tra kết nối API...${NC}"
if curl -k -s "https://$CURRENT_IP:8000/health" >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Backend API hoạt động${NC}"
else
    echo -e "${RED}   ❌ Backend API không hoạt động${NC}"
fi

if curl -k -s "https://$CURRENT_IP:8000/api/health" >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ API endpoint hoạt động${NC}"
else
    echo -e "${RED}   ❌ API endpoint không hoạt động${NC}"
fi

# 3. Kiểm tra uploads
echo -e "${BLUE}3️⃣ Kiểm tra uploads...${NC}"
if [ -d "backend/uploads" ]; then
    echo -e "${GREEN}   ✅ Thư mục uploads tồn tại${NC}"
    UPLOAD_COUNT=$(ls -1 backend/uploads/ | wc -l)
    echo -e "${BLUE}   📁 Số file upload: $UPLOAD_COUNT${NC}"
else
    echo -e "${RED}   ❌ Thư mục uploads không tồn tại${NC}"
fi

if [ -d "backend/uploads/checkin_photos" ]; then
    echo -e "${GREEN}   ✅ Thư mục checkin_photos tồn tại${NC}"
    PHOTO_COUNT=$(ls -1 backend/uploads/checkin_photos/ | wc -l)
    echo -e "${BLUE}   📁 Số ảnh checkin: $PHOTO_COUNT${NC}"
else
    echo -e "${RED}   ❌ Thư mục checkin_photos không tồn tại${NC}"
fi

# 4. Kiểm tra QR codes
echo -e "${BLUE}4️⃣ Kiểm tra QR codes...${NC}"
if [ -d "uploads/qr_codes" ]; then
    echo -e "${GREEN}   ✅ Thư mục QR codes tồn tại${NC}"
    QR_COUNT=$(ls -1 uploads/qr_codes/ | wc -l)
    echo -e "${BLUE}   📁 Số QR codes: $QR_COUNT${NC}"
    echo -e "${BLUE}   📁 Danh sách QR codes gần nhất:${NC}"
    ls -la uploads/qr_codes/ | tail -5
else
    echo -e "${RED}   ❌ Thư mục QR codes không tồn tại${NC}"
fi

# 5. Kiểm tra cấu hình
echo -e "${BLUE}5️⃣ Kiểm tra cấu hình...${NC}"
if [ -f "frontend/src/utils/api.ts" ]; then
    API_URL=$(grep "baseURL" frontend/src/utils/api.ts | head -1)
    echo -e "${GREEN}   ✅ API config: $API_URL${NC}"
else
    echo -e "${RED}   ❌ File api.ts không tồn tại${NC}"
fi

if [ -f "nginx-https.conf" ]; then
    echo -e "${GREEN}   ✅ Nginx config tồn tại${NC}"
    NGINX_IP=$(grep "server " nginx-https.conf | head -1)
    echo -e "${BLUE}   📋 Nginx upstream: $NGINX_IP${NC}"
else
    echo -e "${RED}   ❌ File nginx-https.conf không tồn tại${NC}"
fi

# 6. Kiểm tra database
echo -e "${BLUE}6️⃣ Kiểm tra database...${NC}"
if [ -f "backend/app.db" ]; then
    echo -e "${GREEN}   ✅ Database tồn tại${NC}"
    # Kiểm tra số bản ghi
    if command -v sqlite3 >/dev/null 2>&1; then
        USER_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
        TASK_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM patrol_tasks;" 2>/dev/null || echo "0")
        RECORD_COUNT=$(sqlite3 backend/app.db "SELECT COUNT(*) FROM patrol_records;" 2>/dev/null || echo "0")
        echo -e "${BLUE}   📊 Users: $USER_COUNT, Tasks: $TASK_COUNT, Records: $RECORD_COUNT${NC}"
    else
        echo -e "${YELLOW}   ⚠️ sqlite3 không có sẵn để kiểm tra chi tiết${NC}"
    fi
else
    echo -e "${RED}   ❌ Database không tồn tại${NC}"
fi

# 7. Test truy cập ảnh
echo -e "${BLUE}7️⃣ Test truy cập ảnh...${NC}"
if [ -d "backend/uploads/checkin_photos" ] && [ "$(ls -A backend/uploads/checkin_photos)" ]; then
    SAMPLE_PHOTO=$(ls backend/uploads/checkin_photos/ | head -1)
    if curl -k -s "https://$CURRENT_IP:8000/uploads/checkin_photos/$SAMPLE_PHOTO" >/dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Có thể truy cập ảnh qua API${NC}"
    else
        echo -e "${RED}   ❌ Không thể truy cập ảnh qua API${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️ Không có ảnh để test${NC}"
fi

# 8. Kiểm tra frontend
echo -e "${BLUE}8️⃣ Kiểm tra frontend...${NC}"
if curl -k -s "https://localhost:5173" >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Frontend có thể truy cập${NC}"
else
    echo -e "${RED}   ❌ Frontend không thể truy cập${NC}"
fi

echo ""
echo -e "${GREEN}🎯 TỔNG KẾT HỆ THỐNG${NC}"
echo "========================"
echo -e "${BLUE}📍 IP: $CURRENT_IP${NC}"
echo -e "${BLUE}🔗 Frontend: https://localhost:5173${NC}"
echo -e "${BLUE}🔗 Backend: https://$CURRENT_IP:8000${NC}"
echo -e "${BLUE}🔗 API Docs: https://$CURRENT_IP:8000/docs${NC}"
echo ""

if [ -n "$BACKEND_PID" ] && [ -n "$FRONTEND_PID" ]; then
    echo -e "${GREEN}✅ HỆ THỐNG HOẠT ĐỘNG BÌNH THƯỜNG!${NC}"
    echo ""
    echo -e "${YELLOW}📋 CÁCH SỬ DỤNG:${NC}"
    echo "1. Truy cập: https://localhost:5173"
    echo "2. Đăng nhập với tài khoản admin"
    echo "3. Quét QR code để checkin"
    echo "4. Xem báo cáo trong Admin Dashboard"
else
    echo -e "${RED}❌ HỆ THỐNG CÓ VẤN ĐỀ!${NC}"
    echo ""
    echo -e "${YELLOW}🔧 CÁCH SỬA LỖI:${NC}"
    echo "1. Khởi động lại hệ thống:"
    echo "   ./start-https-final.sh"
    echo ""
    echo "2. Kiểm tra logs:"
    echo "   tail -f backend/app.log"
    echo "   tail -f frontend/frontend.log"
fi

echo ""
echo -e "${GREEN}✅ Kiểm tra hoàn thành!${NC}"
