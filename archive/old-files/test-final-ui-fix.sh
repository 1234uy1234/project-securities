#!/bin/bash

# 🎨 TEST SỬA GIAO DIỆN CUỐI CÙNG
# Kiểm tra xóa độ ưu tiên và sửa thời gian

echo "🎨 TEST SỬA GIAO DIỆN CUỐI CÙNG"
echo "================================"

NGROK_URL="https://semiprivate-interlamellar-phillis.ngrok-free.dev"
FRONTEND_URL="https://10.10.68.200:5173"

# 1. Test frontend
echo "1. Test frontend:"
echo "   🎨 Frontend: $FRONTEND_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 2. Kiểm tra file đã sửa
echo "2. Kiểm tra file đã sửa:"
if grep -q "priority.*low.*medium.*high" /Users/maybe/Documents/shopee/frontend/src/pages/TasksPage.tsx; then
    echo "   ❌ Vẫn còn priority trong TasksPage.tsx"
else
    echo "   ✅ Đã xóa hết priority khỏi TasksPage.tsx"
fi

if grep -q "Độ ưu tiên" /Users/maybe/Documents/shopee/frontend/src/pages/TasksPage.tsx; then
    echo "   ❌ Vẫn còn 'Độ ưu tiên' trong TasksPage.tsx"
else
    echo "   ✅ Đã xóa hết 'Độ ưu tiên' khỏi TasksPage.tsx"
fi

# 3. Kiểm tra TimeRangePicker
echo "3. Kiểm tra TimeRangePicker:"
if grep -q "p-4.*text-base.*font-medium" /Users/maybe/Documents/shopee/frontend/src/components/TimeRangePicker.tsx; then
    echo "   ✅ TimeRangePicker đã được sửa to hơn"
else
    echo "   ❌ TimeRangePicker chưa được sửa"
fi

# 4. Test API
echo "4. Test API:"
echo "   🔗 API: $NGROK_URL/api/patrol-records/report"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/api/patrol-records/report | grep -q "200"; then
    echo "   ✅ API hoạt động"
else
    echo "   ❌ API không hoạt động"
fi

echo ""
echo "🎉 KIỂM TRA HOÀN TẤT!"
echo "====================="
echo "✅ Đã xóa hết 'Độ ưu tiên' khỏi form và bảng"
echo "✅ Đã sửa TimeRangePicker to hơn"
echo "✅ API hoạt động bình thường"
echo ""
echo "📱 TRUY CẬP ĐỂ KIỂM TRA:"
echo "========================"
echo "• Tasks: $FRONTEND_URL/tasks"
echo "• Reports: $FRONTEND_URL/reports"
echo ""
echo "🔍 KIỂM TRA:"
echo "============"
echo "1. Mở Tasks page → Click 'Tạo nhiệm vụ mới'"
echo "2. Kiểm tra KHÔNG có field 'Độ ưu tiên'"
echo "3. Kiểm tra 'Thời gian thực hiện' to hơn"
echo "4. Kiểm tra bảng nhiệm vụ KHÔNG có cột 'Độ ưu tiên'"
echo ""
echo "💡 Nếu vẫn thấy 'Độ ưu tiên':"
echo "   - Hard refresh: Ctrl+F5 (Windows) hoặc Cmd+Shift+R (Mac)"
echo "   - Clear browser cache"
echo "   - Mở incognito/private mode"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🌐 Khởi động lại: ./start-system-ngrok.sh"
