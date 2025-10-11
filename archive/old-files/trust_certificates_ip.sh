#!/bin/bash

echo "=== TRUST SSL CERTIFICATES CHO IP TĨNH ==="
echo "IP: 10.10.68.200"
echo ""

# Trust backend certificate
echo "🔒 Trusting backend certificate..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain cert.pem

# Trust frontend certificate  
echo "🔒 Trusting frontend certificate..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain frontend/cert.pem

echo ""
echo "✅ SSL certificates trusted!"
echo ""
echo "📱 Bây giờ bạn có thể truy cập:"
echo "   Backend: https://10.10.68.200:8000"
echo "   Frontend: https://10.10.68.200:5173"
echo ""
echo "⚠️  Nếu vẫn báo 'Không bảo mật', hãy:"
echo "   1. Refresh trang (Cmd+R)"
echo "   2. Clear browser cache"
echo "   3. Restart browser"
