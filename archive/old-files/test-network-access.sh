#!/bin/bash

# 🧪 TEST TRUY CẬP MẠNG
# Kiểm tra hệ thống có thể truy cập từ thiết bị khác

echo "🧪 TEST TRUY CẬP MẠNG"
echo "====================="

IP="10.10.68.200"

# 1. Test backend
echo "1. Test backend:"
echo "   🔧 Backend: http://$IP:8000"
if curl -s -o /dev/null -w "%{http_code}" http://$IP:8000/docs | grep -q "200"; then
    echo "   ✅ Backend hoạt động"
else
    echo "   ❌ Backend không hoạt động"
fi

# 2. Test frontend
echo "2. Test frontend:"
echo "   🎨 Frontend: https://$IP:3000"
if curl -k -s -o /dev/null -w "%{http_code}" https://$IP:3000 | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 3. Test ảnh
echo "3. Test ảnh:"
echo "   📸 Ảnh: http://$IP:8000/uploads/"
if curl -s -o /dev/null -w "%{http_code}" http://$IP:8000/uploads/checkin_12_20251008_082554.jpg | grep -q "200"; then
    echo "   ✅ Ảnh có thể truy cập"
else
    echo "   ❌ Ảnh không thể truy cập"
fi

# 4. Test API
echo "4. Test API:"
echo "   🔗 API: http://$IP:8000/api/patrol-records/report"
if curl -s -o /dev/null -w "%{http_code}" http://$IP:8000/api/patrol-records/report | grep -q "200"; then
    echo "   ✅ API hoạt động"
else
    echo "   ❌ API không hoạt động"
fi

echo ""
echo "📱 HƯỚNG DẪN TRUY CẬP TỪ THIẾT BỊ KHÁC:"
echo "======================================="
echo "• Điện thoại: https://$IP:3000"
echo "• Máy khác: https://$IP:3000"
echo "• QR Scanner: https://$IP:3000/qr-scan"
echo "• Reports: https://$IP:3000/reports"
echo "• Admin Dashboard: https://$IP:3000/admin-dashboard"
echo "• Employee Dashboard: https://$IP:3000/employee-dashboard"
echo ""
echo "🔍 LƯU Ý:"
echo "========="
echo "• Frontend dùng HTTPS (có thể cần chấp nhận certificate)"
echo "• Backend dùng HTTP (ảnh và API)"
echo "• Đảm bảo thiết bị khác cùng mạng WiFi"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🚀 Khởi động lại: ./start-system-network.sh"
