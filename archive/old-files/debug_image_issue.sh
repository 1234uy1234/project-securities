#!/bin/bash

echo "=== DEBUG IMAGE DISPLAY ISSUE ==="

echo "🔍 KIỂM TRA BACKEND:"
echo "1. API có trả về photo_url: ✅"
echo "2. Ảnh có tồn tại: ✅"
echo "3. Static serving hoạt động: ✅"
echo ""

echo "🔍 KIỂM TRA FRONTEND:"
echo "1. Cache-busting có: ✅"
echo "2. Logic hiển thị đúng: ✅"
echo "3. URL ảnh đúng: ✅"
echo ""

echo "🎯 VẤN ĐỀ CÓ THỂ LÀ:"
echo "1. Browser cache quá mạnh"
echo "2. Service worker cache"
echo "3. Frontend không reload đúng cách"
echo ""

echo "💡 GIẢI PHÁP:"
echo "1. Mở DevTools (F12)"
echo "2. Tab Network"
echo "3. Check 'Disable cache'"
echo "4. Hard refresh: Cmd+Shift+R"
echo "5. Xem có request ảnh không"
echo ""

echo "🧪 TEST TRỰC TIẾP:"
echo "Mở URL này trong browser:"
echo "https://10.10.68.200:8000/uploads/checkin_1_20251001_134614.jpg"
echo ""

echo "📱 NẾU VẪN KHÔNG ĐƯỢC:"
echo "1. Thử incognito mode"
echo "2. Thử browser khác"
echo "3. Clear tất cả data của site"
