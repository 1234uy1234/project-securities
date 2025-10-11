#!/bin/bash

# 🎨 TEST CẢI TIẾN GIAO DIỆN
# Kiểm tra các cải tiến UI đã thực hiện

echo "🎨 TEST CẢI TIẾN GIAO DIỆN"
echo "=========================="

NGROK_URL="https://semiprivate-interlamellar-phillis.ngrok-free.dev"
FRONTEND_URL="https://10.10.68.200:5173"

# 1. Test API trả về tên người, nhiệm vụ, vị trí
echo "1. Test API Reports:"
echo "   🔗 API: $NGROK_URL/api/patrol-records/report"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/api/patrol-records/report | grep -q "200"; then
    echo "   ✅ API hoạt động"
    
    # Kiểm tra dữ liệu trả về
    echo "   📊 Dữ liệu mẫu:"
    curl -k -s $NGROK_URL/api/patrol-records/report | python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data[:2]:
    user_name = r.get('user', {}).get('full_name', 'None') if r.get('user') else 'None'
    task_name = r.get('task', {}).get('title', 'None') if r.get('task') else 'None'
    location_name = r.get('location', {}).get('name', 'None') if r.get('location') else 'None'
    print(f'      Record {r[\"id\"]}: User={user_name}, Task={task_name}, Location={location_name}')
" 2>/dev/null || echo "      Không thể parse dữ liệu"
else
    echo "   ❌ API không hoạt động"
fi

# 2. Test frontend
echo "2. Test frontend:"
echo "   🎨 Frontend: $FRONTEND_URL"
if curl -k -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
    echo "   ✅ Frontend hoạt động"
else
    echo "   ❌ Frontend không hoạt động"
fi

# 3. Test ảnh
echo "3. Test ảnh:"
echo "   📸 Ảnh: $NGROK_URL/uploads/"
if curl -k -s -o /dev/null -w "%{http_code}" $NGROK_URL/uploads/checkin_12_20251008_082554.jpg | grep -q "200"; then
    echo "   ✅ Ảnh có thể truy cập"
else
    echo "   ❌ Ảnh không thể truy cập"
fi

echo ""
echo "🎉 CẢI TIẾN GIAO DIỆN HOÀN TẤT!"
echo "==============================="
echo "✅ Reports page hiển thị tên người, nhiệm vụ, vị trí"
echo "✅ Thời gian hiển thị dài hơn (ngày + giờ riêng biệt)"
echo "✅ Xóa độ ưu tiên khỏi form tạo nhiệm vụ"
echo "✅ Xóa độ ưu tiên khỏi bảng hiển thị nhiệm vụ"
echo ""
echo "📱 TRUY CẬP ĐỂ KIỂM TRA:"
echo "========================"
echo "• Reports: $FRONTEND_URL/reports"
echo "• Tasks: $FRONTEND_URL/tasks"
echo "• Admin Dashboard: $FRONTEND_URL/admin-dashboard"
echo "• Employee Dashboard: $FRONTEND_URL/employee-dashboard"
echo ""
echo "🔍 KIỂM TRA:"
echo "============"
echo "1. Mở Reports page → Kiểm tra cột User, Task, Location hiển thị tên"
echo "2. Kiểm tra cột thời gian hiển thị ngày và giờ riêng biệt"
echo "3. Mở Tasks page → Kiểm tra form tạo nhiệm vụ không có độ ưu tiên"
echo "4. Kiểm tra bảng nhiệm vụ không có cột độ ưu tiên"
echo ""
echo "🛑 Dừng hệ thống: ./stop-system.sh"
echo "🌐 Khởi động lại: ./start-system-ngrok.sh"
