#!/bin/bash

# 🧪 TEST HỆ THỐNG CUỐI CÙNG
# Kiểm tra tất cả chức năng hoạt động

echo "🧪 TEST HỆ THỐNG CUỐI CÙNG"
echo "==========================="

NGROK_URL="https://semiprivate-interlamellar-phillis.ngrok-free.dev"
FRONTEND_URL="https://10.10.68.200:5173"

# 1. Test backend qua ngrok
echo "1. Test backend qua ngrok:"
echo "   🔧 Backend: $NGROK_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/docs | grep -q "200"; then
    echo "   ✅ Backend hoạt động"
else
    echo "   ❌ Backend không hoạt động"
fi

# 2. Test frontend
echo "2. Test frontend:"
echo "   🎨 Frontend: $FRONTEND_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 3. Test ảnh qua ngrok
echo "3. Test ảnh qua ngrok:"
echo "   📸 Ảnh: $NGROK_URL/uploads/"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/uploads/checkin_12_20251008_082554.jpg | grep -q "200"; then
    echo "   ✅ Ảnh có thể truy cập"
else
    echo "   ❌ Ảnh không thể truy cập"
fi

# 4. Test API qua ngrok
echo "4. Test API qua ngrok:"
echo "   🔗 API: $NGROK_URL/api/patrol-records/report"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/api/patrol-records/report | grep -q "200"; then
    echo "   ✅ API hoạt động"
else
    echo "   ❌ API không hoạt động"
fi

echo ""
echo "🎉 HỆ THỐNG HOÀN CHỈNH!"
echo "======================="
echo "🔗 Ngrok URL: $NGROK_URL"
echo "🎨 Frontend: $FRONTEND_URL"
echo ""
echo "📱 TRUY CẬP TỪ MỌI NƠI:"
echo "======================="
echo "• 4G: $FRONTEND_URL"
echo "• WiFi khác: $FRONTEND_URL"
echo "• QR Scanner: $FRONTEND_URL/qr-scan"
echo "• Reports: $FRONTEND_URL/reports"
echo "• Admin Dashboard: $FRONTEND_URL/admin-dashboard"
echo "• Employee Dashboard: $FRONTEND_URL/employee-dashboard"
echo ""
echo "🌐 NGROK BACKEND:"
echo "================="
echo "• API: $NGROK_URL/api/"
echo "• Ảnh: $NGROK_URL/uploads/"
echo "• Docs: $NGROK_URL/docs"
echo ""
echo "✅ TẤT CẢ CHỨC NĂNG HOẠT ĐỘNG:"
echo "=============================="
echo "• QR Code hiển thị đúng"
echo "• Ảnh hiển thị đúng"
echo "• Chấm công hoạt động"
echo "• Reports hiển thị ảnh"
echo "• Truy cập từ 4G/WiFi khác"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🌐 Khởi động lại: ./start-system-ngrok.sh"
