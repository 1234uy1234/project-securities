#!/bin/bash

echo "🔧 SỬA LỖI SSL BROWSER"
echo "======================"

echo ""
echo "✅ Backend đã chạy HTTPS thành công:"
curl -k -s https://10.10.68.200:8000/health && echo " ✅ OK"

echo ""
echo "🔧 ĐỂ SỬA LỖI SSL TRONG BROWSER:"
echo ""
echo "1. Mở tab mới"
echo "2. Truy cập: https://10.10.68.200:8000/health"
echo "3. Click 'Advanced' -> 'Proceed to 10.10.68.200 (unsafe)'"
echo "4. Sau đó truy cập frontend bình thường"
echo ""
echo "HOẶC:"
echo "1. Force refresh: Ctrl+Shift+R (Windows) / Cmd+Shift+R (Mac)"
echo "2. Clear browser cache hoàn toàn"
echo ""
echo "✅ LOGIC ĐÃ SỬA:"
echo "   - Nhiệm vụ mới sẽ không lấy ảnh cũ (8:30)"
echo "   - Chỉ hiển thị ảnh khi employee thực sự checkin"

