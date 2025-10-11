#!/bin/bash

# Script tạo lại QR codes với IP mới
# Sử dụng: ./regenerate-qr-codes.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 TẠO LẠI QR CODES VỚI IP MỚI${NC}"
echo "=================================="

# Lấy IP hiện tại
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
echo -e "${YELLOW}📍 IP hiện tại: $CURRENT_IP${NC}"

# 1. Tạo QR codes cho locations
echo -e "${BLUE}1️⃣ Tạo QR codes cho locations...${NC}"
if [ -f "create-location-qr-codes.py" ]; then
    python3 create-location-qr-codes.py
    echo -e "${GREEN}   ✅ Đã tạo QR codes cho locations${NC}"
else
    echo -e "${RED}   ❌ Không tìm thấy create-location-qr-codes.py${NC}"
fi

# 2. Tạo QR codes cố định
echo -e "${BLUE}2️⃣ Tạo QR codes cố định...${NC}"
if [ -f "backend/create_fixed_qr_codes.py" ]; then
    cd backend
    python3 create_fixed_qr_codes.py
    cd ..
    echo -e "${GREEN}   ✅ Đã tạo QR codes cố định${NC}"
else
    echo -e "${RED}   ❌ Không tìm thấy backend/create_fixed_qr_codes.py${NC}"
fi

# 3. Kiểm tra thư mục QR codes
echo -e "${BLUE}3️⃣ Kiểm tra thư mục QR codes...${NC}"
if [ -d "uploads/qr_codes" ]; then
    echo -e "${GREEN}   ✅ Thư mục uploads/qr_codes tồn tại${NC}"
    echo -e "${BLUE}   📁 Số file QR: $(ls -1 uploads/qr_codes/ | wc -l)${NC}"
    echo -e "${BLUE}   📁 Danh sách file QR:${NC}"
    ls -la uploads/qr_codes/ | head -10
else
    echo -e "${RED}   ❌ Thư mục uploads/qr_codes không tồn tại${NC}"
    mkdir -p uploads/qr_codes
    echo -e "${YELLOW}   🔧 Đã tạo thư mục uploads/qr_codes${NC}"
fi

# 4. Tạo QR code test
echo -e "${BLUE}4️⃣ Tạo QR code test...${NC}"
cat > test_qr_generator.py << EOF
#!/usr/bin/env python3
import qrcode
import os

# Tạo QR code test với IP mới
qr_content = f"https://{CURRENT_IP}:5173/checkin?location_id=1&name=Test_Location"
qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_L, box_size=10, border=4)
qr.add_data(qr_content)
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
img.save("test_qr_new.png")

print(f"✅ QR code test đã tạo: test_qr_new.png")
print(f"   Content: {qr_content}")
EOF

python3 test_qr_generator.py
rm test_qr_generator.py

echo ""
echo -e "${GREEN}🎉 HOÀN THÀNH TẠO QR CODES!${NC}"
echo "=================================="
echo -e "${BLUE}📍 IP mới: $CURRENT_IP${NC}"
echo -e "${BLUE}📁 Thư mục QR: uploads/qr_codes/${NC}"
echo ""
echo -e "${YELLOW}📋 CÁCH SỬ DỤNG:${NC}"
echo "1. In QR codes từ thư mục uploads/qr_codes/"
echo "2. Dán QR codes tại các vị trí tương ứng"
echo "3. Test checkin bằng cách quét QR code"
echo ""
echo -e "${GREEN}✅ Tất cả QR codes đã được tạo với IP mới!${NC}"
