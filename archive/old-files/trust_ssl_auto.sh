#!/bin/bash

echo "=== TRUST SSL CERTIFICATE TỰ ĐỘNG ==="
echo ""

# Trust backend certificate
echo "🔒 Trusting backend certificate..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain cert.pem

if [ $? -eq 0 ]; then
    echo "✅ Backend certificate trusted successfully"
else
    echo "❌ Failed to trust backend certificate"
fi

echo ""
echo "🎉 SSL certificate trusted!"
echo ""
echo "📱 Bây giờ bạn có thể truy cập:"
echo "   Backend: https://10.10.68.200:8000"
echo "   Frontend: https://10.10.68.200:5173"
echo ""
echo "⚠️  Nếu vẫn báo 'Không bảo mật', hãy:"
echo "   1. Refresh trang (Cmd+R)"
echo "   2. Clear browser cache (Cmd+Shift+R)"
echo "   3. Restart browser"
echo ""
echo "🔧 Hoặc trust thủ công:"
echo "   1. Truy cập https://10.10.68.200:8000"
echo "   2. Click 'Advanced' → 'Proceed to 10.10.68.200 (unsafe)'"
echo "   3. Làm tương tự với https://10.10.68.200:5173"
