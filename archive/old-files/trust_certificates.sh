#!/bin/bash

# 🔒 Script trust SSL certificates cho localhost

echo "=== TRUST SSL CERTIFICATES CHO LOCALHOST ==="

# Trust backend certificate
echo "1. Trusting backend certificate..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /Users/maybe/Documents/shopee/backend/cert.pem

# Trust frontend certificate  
echo "2. Trusting frontend certificate..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /Users/maybe/Documents/shopee/frontend/cert.pem

echo "✅ Đã trust cả 2 certificates!"
echo ""
echo "Bây giờ bạn có thể truy cập:"
echo "- Frontend: https://localhost:5173"
echo "- Backend: https://localhost:8000"
echo ""
echo "Không còn lỗi SSL nữa!"
