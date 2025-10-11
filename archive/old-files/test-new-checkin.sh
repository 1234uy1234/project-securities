#!/bin/bash

# Script test checkin mới và kiểm tra report
# Sử dụng: ./test-new-checkin.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 TEST CHECKIN MỚI VÀ KIỂM TRA REPORT${NC}"
echo "====================================="

# 1. Lấy token
echo -e "${BLUE}1️⃣ Lấy token...${NC}"
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

LOGIN_RESPONSE=$(curl -k -s -X POST "https://$CURRENT_IP:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' 2>/dev/null)

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}   ✅ Token: ${TOKEN:0:20}...${NC}"
else
    echo -e "${RED}   ❌ Login failed${NC}"
    exit 1
fi

# 2. Kiểm tra records hiện tại
echo -e "${BLUE}2️⃣ Kiểm tra records hiện tại...${NC}"
RECORDS_RESPONSE=$(curl -k -s "https://$CURRENT_IP:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer $TOKEN" 2>/dev/null)

if echo "$RECORDS_RESPONSE" | grep -q "id"; then
    RECORD_COUNT_BEFORE=$(echo "$RECORDS_RESPONSE" | grep -o '"id"' | wc -l)
    echo -e "${GREEN}   ✅ Hiện có $RECORD_COUNT_BEFORE records${NC}"
else
    echo -e "${RED}   ❌ Không thể lấy records${NC}"
    exit 1
fi

# 3. Tạo ảnh test từ base64
echo -e "${BLUE}3️⃣ Tạo ảnh test...${NC}"
cat > test_image_base64.txt << 'EOF'
data:image/jpeg;base64,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YPhwhfiB4xR/9az2jDPdPKwPwzmjwIQ0vieSPmF9cuChHQ8ICR+Oau674M0/Xr+O/a5v7G9WPyjcWE/lO6Zztbg5FamkaRZaFpcOnafF5dvEPlGckknJJPck0JO4nJWL1FFFUQFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH/9k=
EOF

echo -e "${GREEN}   ✅ Đã tạo ảnh test${NC}"

# 4. Test checkin mới
echo -e "${BLUE}4️⃣ Test checkin mới...${NC}"
cat > test_new_checkin.py << 'EOF'
#!/usr/bin/env python3
import requests
import json
import base64
import io
from PIL import Image

# Đọc base64 từ file
with open('test_image_base64.txt', 'r') as f:
    base64_data = f.read().strip()

# Loại bỏ data:image/jpeg;base64, prefix
if base64_data.startswith('data:image/jpeg;base64,'):
    base64_data = base64_data[23:]

# Decode base64 thành bytes
image_bytes = base64.b64decode(base64_data)

# Tạo FormData
files = {
    'photo': ('test_image.jpg', image_bytes, 'image/jpeg')
}

data = {
    'qr_data': 'test_new_checkin_' + str(int(__import__('time').time())),
    'notes': 'Test checkin mới từ script'
}

# Gửi request
url = 'https://localhost:8000/api/checkin/simple'
headers = {
    'Authorization': 'Bearer ' + 'TOKEN_PLACEHOLDER'
}

print('📤 Sending checkin request...')
print(f'   QR Data: {data["qr_data"]}')
print(f'   Photo size: {len(image_bytes)} bytes')

try:
    response = requests.post(url, files=files, data=data, headers=headers, verify=False)
    
    print(f'📤 Response status: {response.status_code}')
    
    if response.status_code == 200:
        result = response.json()
        print('✅ Checkin successful!')
        print(f'   Photo URL: {result.get("photo_url", "N/A")}')
        print(f'   Message: {result.get("message", "N/A")}')
    else:
        print(f'❌ Checkin failed: {response.text}')
        
except Exception as e:
    print(f'❌ Error: {e}')
EOF

# Thay thế token trong script
sed "s/TOKEN_PLACEHOLDER/$TOKEN/g" test_new_checkin.py > test_new_checkin_final.py

# Chạy test
python3 test_new_checkin_final.py

# Cleanup
rm test_image_base64.txt test_new_checkin.py test_new_checkin_final.py

# 5. Kiểm tra records sau checkin
echo -e "${BLUE}5️⃣ Kiểm tra records sau checkin...${NC}"
RECORDS_RESPONSE_AFTER=$(curl -k -s "https://$CURRENT_IP:8000/api/checkin/admin/all-records" \
  -H "Authorization: Bearer $TOKEN" 2>/dev/null)

if echo "$RECORDS_RESPONSE_AFTER" | grep -q "id"; then
    RECORD_COUNT_AFTER=$(echo "$RECORDS_RESPONSE_AFTER" | grep -o '"id"' | wc -l)
    echo -e "${GREEN}   ✅ Sau checkin có $RECORD_COUNT_AFTER records${NC}"
    
    if [ "$RECORD_COUNT_AFTER" -gt "$RECORD_COUNT_BEFORE" ]; then
        echo -e "${GREEN}   🎉 CHECKIN MỚI ĐÃ ĐƯỢC LƯU!${NC}"
        echo -e "${BLUE}   📈 Tăng từ $RECORD_COUNT_BEFORE lên $RECORD_COUNT_AFTER records${NC}"
    else
        echo -e "${YELLOW}   ⚠️ Số records không thay đổi${NC}"
    fi
else
    echo -e "${RED}   ❌ Không thể lấy records sau checkin${NC}"
fi

echo ""
echo -e "${GREEN}🎉 TEST HOÀN THÀNH!${NC}"
echo "======================"
echo -e "${BLUE}📍 IP: $CURRENT_IP${NC}"
echo ""
echo -e "${YELLOW}📋 CÁCH KIỂM TRA TRONG BROWSER:${NC}"
echo "1. Truy cập: https://localhost:5173"
echo "2. Đăng nhập với admin/admin123"
echo "3. Vào Admin Dashboard"
echo "4. Kiểm tra danh sách checkin records"
echo ""
echo -e "${GREEN}✅ Test checkin mới hoàn thành!${NC}"
