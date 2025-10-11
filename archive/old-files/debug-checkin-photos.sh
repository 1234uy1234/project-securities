#!/bin/bash

# Script debug vấn đề checkin photos
# Kiểm tra và sửa lỗi hiển thị ảnh checkin

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 DEBUG VẤN ĐỀ CHECKIN PHOTOS${NC}"
echo "=================================="

# 1. Kiểm tra thư mục uploads
echo -e "${BLUE}1️⃣ Kiểm tra thư mục uploads...${NC}"
if [ -d "backend/uploads" ]; then
    echo -e "${GREEN}   ✅ Thư mục backend/uploads tồn tại${NC}"
    ls -la backend/uploads/
else
    echo -e "${RED}   ❌ Thư mục backend/uploads không tồn tại${NC}"
    mkdir -p backend/uploads
    echo -e "${YELLOW}   🔧 Đã tạo thư mục backend/uploads${NC}"
fi

if [ -d "backend/uploads/checkin_photos" ]; then
    echo -e "${GREEN}   ✅ Thư mục checkin_photos tồn tại${NC}"
    echo -e "${BLUE}   📁 Số file ảnh: $(ls -1 backend/uploads/checkin_photos/ | wc -l)${NC}"
    echo -e "${BLUE}   📁 Danh sách file gần nhất:${NC}"
    ls -la backend/uploads/checkin_photos/ | tail -5
else
    echo -e "${RED}   ❌ Thư mục checkin_photos không tồn tại${NC}"
    mkdir -p backend/uploads/checkin_photos
    echo -e "${YELLOW}   🔧 Đã tạo thư mục checkin_photos${NC}"
fi

# 2. Kiểm tra cấu hình backend
echo -e "${BLUE}2️⃣ Kiểm tra cấu hình backend...${NC}"
if [ -f "backend/app/config.py" ]; then
    echo -e "${GREEN}   ✅ File config.py tồn tại${NC}"
    echo -e "${BLUE}   📋 Upload directory: $(grep 'upload_dir' backend/app/config.py)${NC}"
else
    echo -e "${RED}   ❌ File config.py không tồn tại${NC}"
fi

# 3. Kiểm tra cấu hình nginx
echo -e "${BLUE}3️⃣ Kiểm tra cấu hình nginx...${NC}"
if [ -f "nginx-https.conf" ]; then
    echo -e "${GREEN}   ✅ File nginx-https.conf tồn tại${NC}"
    echo -e "${BLUE}   📋 Uploads proxy config:${NC}"
    grep -A 10 "location /uploads/" nginx-https.conf
else
    echo -e "${RED}   ❌ File nginx-https.conf không tồn tại${NC}"
fi

# 4. Kiểm tra cấu hình frontend
echo -e "${BLUE}4️⃣ Kiểm tra cấu hình frontend...${NC}"
if [ -f "frontend/src/utils/api.ts" ]; then
    echo -e "${GREEN}   ✅ File api.ts tồn tại${NC}"
    echo -e "${BLUE}   📋 Base URL: $(grep 'baseURL' frontend/src/utils/api.ts)${NC}"
else
    echo -e "${RED}   ❌ File api.ts không tồn tại${NC}"
fi

# 5. Kiểm tra CheckinDetailModal
echo -e "${BLUE}5️⃣ Kiểm tra CheckinDetailModal...${NC}"
if [ -f "frontend/src/components/CheckinDetailModal.tsx" ]; then
    echo -e "${GREEN}   ✅ File CheckinDetailModal.tsx tồn tại${NC}"
    echo -e "${BLUE}   📋 Photo URL logic:${NC}"
    grep -A 5 -B 5 "photo_url" frontend/src/components/CheckinDetailModal.tsx
else
    echo -e "${RED}   ❌ File CheckinDetailModal.tsx không tồn tại${NC}"
fi

# 6. Kiểm tra database
echo -e "${BLUE}6️⃣ Kiểm tra database...${NC}"
if [ -f "backend/app.db" ]; then
    echo -e "${GREEN}   ✅ Database tồn tại${NC}"
    echo -e "${BLUE}   📋 Kiểm tra patrol_records:${NC}"
    sqlite3 backend/app.db "SELECT id, user_id, photo_url, check_in_time FROM patrol_records ORDER BY id DESC LIMIT 5;" 2>/dev/null || echo "   ❌ Không thể truy cập database"
else
    echo -e "${RED}   ❌ Database không tồn tại${NC}"
fi

# 7. Test kết nối API
echo -e "${BLUE}7️⃣ Test kết nối API...${NC}"
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
echo -e "${BLUE}   📍 IP hiện tại: $CURRENT_IP${NC}"

# Test health endpoint
if curl -k -s "https://$CURRENT_IP:8000/health" >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Backend API hoạt động${NC}"
else
    echo -e "${RED}   ❌ Backend API không hoạt động${NC}"
fi

# Test uploads endpoint
if curl -k -s "https://$CURRENT_IP:8000/uploads/" >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Uploads endpoint hoạt động${NC}"
else
    echo -e "${RED}   ❌ Uploads endpoint không hoạt động${NC}"
fi

echo ""
echo -e "${YELLOW}🔧 CÁC BƯỚC SỬA LỖI:${NC}"
echo "1. Đảm bảo backend đang chạy:"
echo "   cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt"
echo ""
echo "2. Đảm bảo nginx đang chạy:"
echo "   sudo nginx -c $(pwd)/nginx-https.conf"
echo ""
echo "3. Kiểm tra quyền truy cập thư mục uploads:"
echo "   chmod -R 755 backend/uploads/"
echo ""
echo "4. Test truy cập ảnh trực tiếp:"
echo "   curl -k https://$CURRENT_IP:8000/uploads/checkin_photos/[TÊN_FILE]"
echo ""
echo -e "${GREEN}✅ Debug hoàn thành!${NC}"
