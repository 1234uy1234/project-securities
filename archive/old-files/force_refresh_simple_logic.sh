#!/bin/bash

echo "🔄 FORCE REFRESH - LOGIC ĐƠN GIẢN"
echo "================================="

echo "📋 Logic mới đã được áp dụng:"
echo "1. Có checkin record = hoàn thành (giống như Report)"
echo "2. Không cần kiểm tra thời gian, ảnh phức tạp"
echo "3. Chấm công → FlowStep nhận ngay"

echo ""
echo "🔄 Bước 1: Restart backend server"
echo "----------------------------------------"
pkill -f "python3 -m backend.app.main" || true
sleep 2

echo "🔄 Bước 2: Start backend server"
echo "----------------------------------------"
cd /Users/maybe/Documents/shopee
python3 -m backend.app.main &
sleep 3

echo "🔄 Bước 3: Force refresh frontend"
echo "----------------------------------------"
echo "1. Mở browser"
echo "2. Vào https://10.10.68.200:5173"
echo "3. Nhấn Ctrl+Shift+R (hard refresh)"
echo "4. Hoặc nhấn F12 → Network → Disable cache → Refresh"

echo ""
echo "🎯 Kết quả mong đợi:"
echo "- Task 'tuan tra': FlowStep hiển thị 'Đã chấm công' với ảnh"
echo "- Task 'bjsucd': FlowStep hiển thị 'Đã chấm công' với ảnh"
echo "- Không còn lỗi 'đéo nhận' checkin"

echo ""
echo "✅ Logic đã được sửa đơn giản - chấm là nhận!"
