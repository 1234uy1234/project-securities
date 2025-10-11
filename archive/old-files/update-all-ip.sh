#!/bin/bash

# Script cập nhật IP mới cho toàn bộ hệ thống
# Sử dụng: ./update-all-ip.sh [IP_MỚI]

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 SCRIPT CẬP NHẬT IP MỚI CHO TOÀN BỘ HỆ THỐNG${NC}"
echo "=================================================="

# Lấy IP mới từ tham số hoặc tự động phát hiện
if [ -n "$1" ]; then
    NEW_IP="$1"
    echo -e "${YELLOW}📍 Sử dụng IP được chỉ định: $NEW_IP${NC}"
else
    # Tự động phát hiện IP
    NEW_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
    echo -e "${YELLOW}📍 Tự động phát hiện IP: $NEW_IP${NC}"
fi

if [ -z "$NEW_IP" ]; then
    echo -e "${RED}❌ Không thể phát hiện IP. Vui lòng chỉ định IP thủ công:${NC}"
    echo "   ./update-all-ip.sh 192.168.1.100"
    exit 1
fi

echo -e "${GREEN}✅ IP mới: $NEW_IP${NC}"
echo ""

# Backup các file quan trọng
echo -e "${BLUE}💾 Tạo backup các file cấu hình...${NC}"
mkdir -p backups/$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

cp frontend/src/utils/api.ts "$BACKUP_DIR/api.ts.backup" 2>/dev/null
cp nginx-https.conf "$BACKUP_DIR/nginx-https.conf.backup" 2>/dev/null
cp backend/app/config.py "$BACKUP_DIR/config.py.backup" 2>/dev/null
cp start-https-final.sh "$BACKUP_DIR/start-https-final.sh.backup" 2>/dev/null
cp IP_CONFIG_LOCKED.txt "$BACKUP_DIR/IP_CONFIG_LOCKED.txt.backup" 2>/dev/null

echo -e "${GREEN}✅ Đã backup vào: $BACKUP_DIR${NC}"
echo ""

# 1. Cập nhật frontend API config
echo -e "${BLUE}1️⃣ Cập nhật Frontend API config...${NC}"
if [ -f "frontend/src/utils/api.ts" ]; then
    sed -i.bak "s|baseURL: 'https://[^:]*:8000/api'|baseURL: 'https://$NEW_IP:8000/api'|g" frontend/src/utils/api.ts
    echo -e "${GREEN}   ✅ frontend/src/utils/api.ts${NC}"
else
    echo -e "${RED}   ❌ Không tìm thấy frontend/src/utils/api.ts${NC}"
fi

# 2. Cập nhật nginx config
echo -e "${BLUE}2️⃣ Cập nhật Nginx config...${NC}"
if [ -f "nginx-https.conf" ]; then
    sed -i.bak "s|server [^:]*:8000;|server $NEW_IP:8000;|g" nginx-https.conf
    sed -i.bak "s|server_name [^ ]* localhost;|server_name $NEW_IP localhost;|g" nginx-https.conf
    sed -i.bak "s|proxy_pass https://[^:]*:8000/;|proxy_pass https://$NEW_IP:8000/;|g" nginx-https.conf
    sed -i.bak "s|proxy_pass https://[^:]*:8000/api/;|proxy_pass https://$NEW_IP:8000/api/;|g" nginx-https.conf
    echo -e "${GREEN}   ✅ nginx-https.conf${NC}"
else
    echo -e "${RED}   ❌ Không tìm thấy nginx-https.conf${NC}"
fi

# 3. Cập nhật backend config
echo -e "${BLUE}3️⃣ Cập nhật Backend config...${NC}"
if [ -f "backend/app/config.py" ]; then
    sed -i.bak "s|https://[^:]*:8000|https://$NEW_IP:8000|g" backend/app/config.py
    sed -i.bak "s|https://[^:]*:5173|https://$NEW_IP:5173|g" backend/app/config.py
    sed -i.bak "s|https://[^:]*:5174|https://$NEW_IP:5174|g" backend/app/config.py
    sed -i.bak "s|https://[^:]*:5175|https://$NEW_IP:5175|g" backend/app/config.py
    sed -i.bak "s|https://[^:]*\"|https://$NEW_IP\"|g" backend/app/config.py
    echo -e "${GREEN}   ✅ backend/app/config.py${NC}"
else
    echo -e "${RED}   ❌ Không tìm thấy backend/app/config.py${NC}"
fi

# 4. Cập nhật start script
echo -e "${BLUE}4️⃣ Cập nhật Start script...${NC}"
if [ -f "start-https-final.sh" ]; then
    sed -i.bak "s|CURRENT_IP=\"[^\"]*\"|CURRENT_IP=\"$NEW_IP\"|g" start-https-final.sh
    echo -e "${GREEN}   ✅ start-https-final.sh${NC}"
else
    echo -e "${RED}   ❌ Không tìm thấy start-https-final.sh${NC}"
fi

# 5. Cập nhật QR code scripts
echo -e "${BLUE}5️⃣ Cập nhật QR code scripts...${NC}"
if [ -f "create-location-qr-codes.py" ]; then
    sed -i.bak "s|base_url: str = \"https://[^:]*:8000\"|base_url: str = \"https://$NEW_IP:8000\"|g" create-location-qr-codes.py
    echo -e "${GREEN}   ✅ create-location-qr-codes.py${NC}"
fi

if [ -f "backend/create_fixed_qr_codes.py" ]; then
    sed -i.bak "s|https://[^:]*:5173|https://$NEW_IP:5173|g" backend/create_fixed_qr_codes.py
    echo -e "${GREEN}   ✅ backend/create_fixed_qr_codes.py${NC}"
fi

# 6. Cập nhật IP_CONFIG_LOCKED.txt
echo -e "${BLUE}6️⃣ Cập nhật IP config lock file...${NC}"
if [ -f "IP_CONFIG_LOCKED.txt" ]; then
    sed -i.bak "s|IP CỐ ĐỊNH: [^[:space:]]*|IP CỐ ĐỊNH: $NEW_IP|g" IP_CONFIG_LOCKED.txt
    sed -i.bak "s|CURRENT_IP=\"[^\"]*\"|CURRENT_IP=\"$NEW_IP\"|g" IP_CONFIG_LOCKED.txt
    sed -i.bak "s|server [^:]*:8000;|server $NEW_IP:8000;|g" IP_CONFIG_LOCKED.txt
    sed -i.bak "s|server_name [^ ]* localhost;|server_name $NEW_IP localhost;|g" IP_CONFIG_LOCKED.txt
    sed -i.bak "s|baseURL: 'https://[^:]*:8000/api'|baseURL: 'https://$NEW_IP:8000/api'|g" IP_CONFIG_LOCKED.txt
    echo -e "${GREEN}   ✅ IP_CONFIG_LOCKED.txt${NC}"
fi

# 7. Tìm và cập nhật các file khác có chứa IP cũ
echo -e "${BLUE}7️⃣ Tìm và cập nhật các file khác...${NC}"

# Tìm các file .sh có chứa IP cũ
find . -name "*.sh" -type f -exec grep -l "10\.10\.68\." {} \; | while read file; do
    if [ "$file" != "./update-all-ip.sh" ]; then
        echo -e "${YELLOW}   🔍 Cập nhật: $file${NC}"
        sed -i.bak "s|10\.10\.68\.[0-9]*|$NEW_IP|g" "$file"
    fi
done

# Tìm các file .py có chứa IP cũ
find . -name "*.py" -type f -exec grep -l "10\.10\.68\." {} \; | while read file; do
    echo -e "${YELLOW}   🔍 Cập nhật: $file${NC}"
    sed -i.bak "s|10\.10\.68\.[0-9]*|$NEW_IP|g" "$file"
done

# Tìm các file .ts có chứa IP cũ
find . -name "*.ts" -type f -exec grep -l "10\.10\.68\." {} \; | while read file; do
    echo -e "${YELLOW}   🔍 Cập nhật: $file${NC}"
    sed -i.bak "s|10\.10\.68\.[0-9]*|$NEW_IP|g" "$file"
done

# Tìm các file .tsx có chứa IP cũ
find . -name "*.tsx" -type f -exec grep -l "10\.10\.68\." {} \; | while read file; do
    echo -e "${YELLOW}   🔍 Cập nhật: $file${NC}"
    sed -i.bak "s|10\.10\.68\.[0-9]*|$NEW_IP|g" "$file"
done

# Tìm các file .conf có chứa IP cũ
find . -name "*.conf" -type f -exec grep -l "10\.10\.68\." {} \; | while read file; do
    echo -e "${YELLOW}   🔍 Cập nhật: $file${NC}"
    sed -i.bak "s|10\.10\.68\.[0-9]*|$NEW_IP|g" "$file"
done

echo ""
echo -e "${GREEN}🎉 HOÀN THÀNH CẬP NHẬT IP!${NC}"
echo "=================================="
echo -e "${BLUE}📍 IP mới: $NEW_IP${NC}"
echo -e "${BLUE}💾 Backup: $BACKUP_DIR${NC}"
echo ""
echo -e "${YELLOW}📋 CÁC BƯỚC TIẾP THEO:${NC}"
echo "1. Khởi động lại hệ thống:"
echo "   ./start-https-final.sh"
echo ""
echo "2. Kiểm tra kết nối:"
echo "   curl -k https://$NEW_IP:8000/health"
echo ""
echo "3. Truy cập ứng dụng:"
echo "   Frontend: https://localhost:5173"
echo "   Backend:  https://$NEW_IP:8000"
echo ""
echo -e "${GREEN}✅ Tất cả file đã được cập nhật với IP mới!${NC}"
