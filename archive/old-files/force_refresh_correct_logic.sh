#!/bin/bash

echo "🔄 FORCE REFRESH - LOGIC TASK CHÍNH XÁC"
echo "======================================="

echo ""
echo "📋 1. Dừng tất cả processes:"
pkill -f "python3 -m backend.app.main" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
sleep 2

echo ""
echo "📋 2. Xóa cache browser:"
echo "   - Mở Developer Tools (F12)"
echo "   - Right-click vào Refresh button"
echo "   - Chọn 'Empty Cache and Hard Reload'"
echo "   - Hoặc Ctrl+Shift+R (Windows) / Cmd+Shift+R (Mac)"

echo ""
echo "📋 3. Restart backend (HTTP mode - không SSL):"
cd /Users/maybe/Documents/shopee
python3 -m backend.app.main &
sleep 3

echo ""
echo "📋 4. Kiểm tra backend status:"
curl -s http://10.10.68.200:5173/health || echo "Backend chưa sẵn sàng"

echo ""
echo "✅ LOGIC ĐÃ SỬA:"
echo "   - findCheckinRecord: Tìm theo task_id + location_id"
echo "   - handleStepClick: Tìm theo task_id + location_id"  
echo "   - latestCheckin: Tìm theo task_id + location_id"
echo ""
echo "🎯 KẾT QUẢ MONG ĐỢI:"
echo "   - Nhiệm vụ mới: Không hiển thị ảnh cũ (8:30)"
echo "   - Chỉ hiển thị ảnh khi employee thực sự checkin cho task đó"
echo "   - Thời gian checkin chính xác theo task được giao"
echo ""
echo "📱 HƯỚNG DẪN TEST:"
echo "   1. Tạo nhiệm vụ mới"
echo "   2. Kiểm tra: Không có ảnh cũ hiển thị"
echo "   3. Employee checkin cho task mới"
echo "   4. Kiểm tra: Hiển thị ảnh + thời gian chính xác"
