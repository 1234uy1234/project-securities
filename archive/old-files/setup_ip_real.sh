#!/bin/bash

echo "=== SETUP VỚI IP THỰC (TẠM THỜI) ==="

# Lấy IP thực
IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
echo "IP thực của máy: $IP"

# Cập nhật config với IP thực
echo "Cập nhật config với IP: $IP"
python3 update_config.py http://$IP

# Restart services
echo "Restart services..."
./restart_services.sh

echo ""
echo "🎉 SETUP HOÀN TẤT!"
echo "Backend: http://$IP:8000"
echo "Frontend: http://$IP:5173"
echo ""
echo "📱 Truy cập từ điện thoại:"
echo "   http://$IP:5173"
echo ""
echo "⚠️  LƯU Ý: IP này có thể thay đổi khi restart router"
echo "💡 Để có URL cố định, hãy setup ngrok theo hướng dẫn trên"

