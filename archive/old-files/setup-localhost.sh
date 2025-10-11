#!/bin/bash

# Script setup localhost domain cho HTTPS
# Chạy: ./setup-localhost.sh

echo "🌐 Setup localhost domain cho HTTPS..."

# Thêm entry vào /etc/hosts
echo "📝 Thêm entry vào /etc/hosts..."
specific_ip="10.10.68.22"
sudo bash -c "echo \"127.0.0.1 localhost\" >> /etc/hosts"
sudo bash -c "echo \"${specific_ip} localhost\" >> /etc/hosts"

echo "✅ Đã thêm localhost vào /etc/hosts"

# Tạo certificate với localhost domain
echo "🔐 Tạo certificate với localhost domain..."
rm -f ssl/server.key ssl/server.crt ssl/backend.key ssl/backend.crt

# Tạo private key
openssl genrsa -out ssl/server.key 4096

# Tạo certificate với localhost
openssl req -new -x509 -key ssl/server.key -out ssl/server.crt -days 365 -subj "/C=VN/ST=HCM/L=Ho Chi Minh City/O=ManhToan Patrol/OU=IT Department/CN=localhost" -extensions v3_req -config <(cat <<EOF
[req]
distinguished_name = req
[v3_req]
keyUsage = digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
IP.2 = ${specific_ip}
IP.3 = ::1
DNS.1 = localhost
DNS.2 = *.localhost
EOF
)

# Copy cho backend
cp ssl/server.key ssl/backend.key
cp ssl/server.crt ssl/backend.crt

# Tự động trust certificate
echo "🔧 Tự động trust certificate..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ssl/server.crt

echo ""
echo "🎉 HOÀN THÀNH!"
echo ""
echo "📱 Truy cập bằng địa chỉ dev trên máy này:"
echo "   - https://localhost:5173 (frontend)"
echo "   - https://localhost:8000 (backend)"
echo ""
echo "🌐 Truy cập từ thiết bị khác trên mạng nội bộ:"
echo "   - https://${specific_ip}:5173 (frontend)"
echo "   - https://${specific_ip}:8000 (backend)"
echo ""
echo "✅ Không còn cảnh báo bảo mật!"
echo "✅ Browser sẽ tin tưởng localhost domain!"
