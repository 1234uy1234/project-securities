#!/bin/bash

echo "🔐 SỬA SSL CHO FRONTEND HTTPS"
echo "============================"
echo ""

echo "🔍 Vấn đề: SSL handshake failure cho frontend"
echo "🔧 Giải pháp: Tạo SSL certificate cho frontend"
echo ""

# Dừng frontend
echo "1. Dừng frontend..."
pkill -f "npm.*dev" 2>/dev/null
pkill -f "vite" 2>/dev/null
sleep 3

# Tạo SSL certificate cho frontend
echo "2. Tạo SSL certificate cho frontend..."
cd /Users/maybe/Documents/shopee/frontend

# Tạo thư mục ssl nếu chưa có
mkdir -p ssl

# Tạo certificate cho frontend
cat > ssl/cert.conf << EOF
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

# Tạo private key và certificate cho frontend
openssl req -new -x509 -newkey rsa:2048 -sha256 -nodes -keyout ssl/server.key -days 365 -out ssl/server.crt -config ssl/cert.conf

echo "   ✅ SSL certificate cho frontend đã được tạo"

# Khởi động frontend với HTTPS
echo "3. Khởi động Frontend với HTTPS..."
VITE_API_BASE_URL=https://10.10.68.200:8000 npm run dev -- --host 10.10.68.200 --port 5173 --https &
sleep 8

echo ""
echo "🔍 Kiểm tra sau khi sửa:"
echo ""

echo "📋 Frontend processes:"
ps aux | grep -E "(npm.*dev|vite)" | grep -v grep

echo ""
echo "📋 Backend processes:"
ps aux | grep -E "(uvicorn.*10.10.68.200)" | grep -v grep

echo ""
echo "🌐 Truy cập ứng dụng:"
echo "   Frontend: https://10.10.68.200:5173"
echo "   Backend API: https://10.10.68.200:8000/api/"
echo ""

echo "📋 Nếu vẫn có lỗi SSL:"
echo "   1. Truy cập https://10.10.68.200:5173"
echo "   2. Click 'Advanced' và 'Proceed to 10.10.68.200 (unsafe)'"
echo "   3. Kiểm tra browser console"
echo "   4. Thử refresh trang (Ctrl+F5)"
echo ""

echo "✅ Hoàn thành sửa SSL cho frontend!"

