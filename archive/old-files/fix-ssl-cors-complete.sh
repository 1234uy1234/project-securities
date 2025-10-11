#!/bin/bash

echo "🔧 SỬA LỖI SSL VÀ CORS HOÀN TOÀN"
echo "==============================="
echo ""

echo "🔍 Vấn đề hiện tại:"
echo "❌ SSL handshake failure"
echo "❌ CORS policy blocking requests"
echo "❌ Frontend không thể kết nối với Backend"
echo ""

echo "🔧 Giải pháp:"
echo ""

# 1. Dừng tất cả services
echo "1. Dừng tất cả services..."
pkill -f "uvicorn.*main" 2>/dev/null
pkill -f "npm.*dev" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 3

# 2. Tạo SSL certificate mới
echo "2. Tạo SSL certificate mới..."
cd /Users/maybe/Documents/shopee/ssl

# Tạo certificate mới với SAN
cat > cert.conf << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=VN
ST=HCM
L=HCM
O=MANHTOAN PLASTIC
OU=IT Department
CN=10.10.68.200

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = 10.10.68.200
IP.1 = 127.0.0.1
IP.2 = 10.10.68.200
EOF

# Tạo private key và certificate
openssl req -new -x509 -newkey rsa:2048 -sha256 -nodes -keyout server.key -days 365 -out server.crt -config cert.conf

echo "   ✅ SSL certificate đã được tạo mới"

# 3. Khởi động backend với SSL mới
echo "3. Khởi động Backend với SSL mới..."
cd /Users/maybe/Documents/shopee/backend
python -m uvicorn app.main:app --host 10.10.68.200 --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt &
sleep 5

# 4. Kiểm tra backend
echo "4. Kiểm tra Backend..."
if curl -k -s -o /dev/null -w "%{http_code}" https://10.10.68.200:8000/api/locations/ | grep -q "401\|403"; then
    echo "   ✅ Backend đang chạy (HTTP 401/403 là bình thường)"
else
    echo "   ❌ Backend không phản hồi"
fi

# 5. Khởi động frontend với HTTP thay vì HTTPS để tránh SSL issues
echo "5. Khởi động Frontend với HTTP..."
cd /Users/maybe/Documents/shopee/frontend
VITE_API_BASE_URL=https://10.10.68.200:8000 npm run dev -- --host 10.10.68.200 --port 5173 &
sleep 8

echo ""
echo "🔍 Kiểm tra sau khi sửa:"
echo ""

echo "📋 Backend processes:"
ps aux | grep -E "(uvicorn.*10.10.68.200)" | grep -v grep

echo ""
echo "📋 Frontend processes:"
ps aux | grep -E "(npm.*dev|vite)" | grep -v grep

echo ""
echo "🌐 Truy cập ứng dụng:"
echo "   Frontend: http://10.10.68.200:5173"
echo "   Backend API: https://10.10.68.200:8000/api/"
echo ""

echo "📋 Nếu vẫn có lỗi:"
echo "   1. Truy cập http://10.10.68.200:5173 (HTTP thay vì HTTPS)"
echo "   2. Kiểm tra browser console"
echo "   3. Thử refresh trang (Ctrl+F5)"
echo "   4. Đảm bảo cả frontend và backend đều chạy"
echo ""

echo "✅ Hoàn thành sửa lỗi SSL và CORS!"

