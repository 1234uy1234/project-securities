#!/bin/bash

echo "🔄 FORCE REFRESH - LOGIC TÌM CHECKIN RECORD ĐÚNG THỜI GIAN"
echo "========================================================="

echo "📋 Logic mới:"
echo "1. Ưu tiên checkin record gần với scheduled_time"
echo "2. Xóa ảnh bé ở dưới điểm stop"
echo "3. Chỉ hiển thị ảnh trong modal chi tiết"

echo ""
echo "🔄 Bước 1: Force refresh frontend"
echo "----------------------------------------"
echo "1. Mở browser"
echo "2. Vào https://10.10.68.200:5173"
echo "3. Nhấn Ctrl+Shift+R (hard refresh)"
echo "4. Hoặc nhấn F12 → Network → Disable cache → Refresh"

echo ""
echo "🎯 Kết quả mong đợi:"
echo "- Task giao 10:20 → Hiển thị checkin record gần 10:20 nhất"
echo "- Không còn ảnh bé ở dưới điểm stop"
echo "- Bấm vào điểm stop → Hiển thị ảnh trong modal chi tiết"

echo ""
echo "📊 Dữ liệu hiện tại:"
echo "- Task 'tuần tra nhà': Giao 10:20"
echo "- Checkin records: 13:46, 13:48, 13:48, 14:23"
echo "- Logic: Tìm checkin record gần 10:20 nhất (13:46)"

echo ""
echo "✅ Logic đã được sửa - tìm checkin record đúng thời gian!"
