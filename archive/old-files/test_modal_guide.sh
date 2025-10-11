#!/bin/bash

echo "=== HƯỚNG DẪN KIỂM TRA MODAL MỚI ==="
echo ""

echo "1. Mở trình duyệt và truy cập:"
echo "   https://10.10.68.200:5173/admin-dashboard"
echo ""

echo "2. Đăng nhập với:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""

echo "3. Hard refresh trang (Ctrl+Shift+R hoặc Cmd+Shift+R)"
echo ""

echo "4. Kiểm tra các tasks hiện tại:"
sqlite3 backend/app.db "SELECT pt.id, pt.title, pts.completed, pts.scheduled_time FROM patrol_tasks pt LEFT JOIN patrol_task_stops pts ON pt.id = pts.task_id WHERE pt.id >= 54 ORDER BY pt.id DESC;"

echo ""
echo "5. Click vào FlowStep của từng task để xem modal:"
echo ""

echo "=== TASK 55 - 'Test đúng giờ' ==="
echo "   - Scheduled: 15:59"
echo "   - Completed: true (checkin đúng giờ)"
echo "   - Modal sẽ hiển thị: '✅ Chấm công đúng giờ' (màu xanh)"
echo ""

echo "=== TASK 56 - 'fvbfhbv' ==="
echo "   - Scheduled: 16:01" 
echo "   - Completed: false (checkin ngoài giờ)"
echo "   - Modal sẽ hiển thị: '⚠️ Chấm công ngoài giờ' (màu cam)"
echo ""

echo "=== TASK 57 - 'nhà đi chơi' ==="
echo "   - Scheduled: null"
echo "   - Completed: null (chưa có stop)"
echo "   - Modal sẽ hiển thị: 'Chưa chấm công' (màu đỏ)"
echo ""

echo "=== NẾU KHÔNG THẤY THAY ĐỔI ==="
echo "1. Clear browser cache:"
echo "   - Chrome: Ctrl+Shift+Delete"
echo "   - Safari: Cmd+Option+E"
echo "   - Firefox: Ctrl+Shift+Delete"
echo ""

echo "2. Thử incognito/private mode"
echo ""

echo "3. Kiểm tra console (F12) có lỗi không"
echo ""

echo "4. Restart frontend:"
echo "   cd /Users/maybe/Documents/shopee/frontend"
echo "   npm run dev"
echo ""

echo "=== TEST THÊM ==="
echo "Bạn có thể tạo checkin mới để test:"
echo "1. Mở QR Scanner"
echo "2. Scan QR với nội dung mới"
echo "3. Chụp ảnh và checkin"
echo "4. Kiểm tra modal hiển thị đúng trạng thái"
