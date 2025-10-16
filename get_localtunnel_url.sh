#!/bin/bash

echo "🔍 Đang lấy URL localtunnel..."

# Tìm process localtunnel
LOCALTUNNEL_PID=$(ps aux | grep "localtunnel.*5173" | grep -v grep | awk '{print $2}' | head -1)

if [ -z "$LOCALTUNNEL_PID" ]; then
    echo "❌ Không tìm thấy localtunnel process"
    exit 1
fi

echo "✅ Tìm thấy localtunnel process: $LOCALTUNNEL_PID"

# Lấy mật khẩu
PASSWORD=$(curl -s https://loca.lt/mytunnelpassword)
echo "🔑 Mật khẩu: $PASSWORD"

# Thử các URL có thể
echo "🌐 Thử các URL có thể:"

# Thử URL phổ biến
for url in "https://public-paths-hunt.loca.lt" "https://curvy-puma-61.loca.lt" "https://cfda2ee5d1c39a973951534659505344.serveo.net"; do
    echo "Thử: $url"
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|403"; then
        echo "✅ URL hoạt động: $url"
        echo "🔑 Mật khẩu: $PASSWORD"
        break
    fi
done

echo "💡 Nếu không tìm thấy URL, hãy kiểm tra terminal nơi chạy localtunnel"
