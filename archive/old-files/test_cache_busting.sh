#!/bin/bash

echo "=== FORCE REFRESH IMAGE CACHE ==="

# 1. Add cache-busting parameter to image URLs
echo "🔧 CACHE-BUSTING SOLUTION:"
echo "Thêm timestamp vào URL ảnh để bypass cache"
echo ""

# 2. Test với cache-busting
echo "🧪 TEST WITH CACHE-BUSTING:"
timestamp=$(date +%s)
echo "https://10.10.68.200:8000/uploads/checkin_1_20251001_134856.jpg?v=$timestamp"
echo "https://10.10.68.200:8000/uploads/checkin_1_20251001_134839.jpg?v=$timestamp"
echo "https://10.10.68.200:8000/uploads/checkin_1_20251001_134614.jpg?v=$timestamp"
echo ""

# 3. Test static file serving với cache-busting
echo "🌐 TEST STATIC FILE SERVING WITH CACHE-BUSTING:"
curl -k -s -o /dev/null -w "Status: %{http_code}\n" "https://10.10.68.200:8000/uploads/checkin_1_20251001_134856.jpg?v=$timestamp"
curl -k -s -o /dev/null -w "Status: %{http_code}\n" "https://10.10.68.200:8000/uploads/checkin_1_20251001_134839.jpg?v=$timestamp"
curl -k -s -o /dev/null -w "Status: %{http_code}\n" "https://10.10.68.200:8000/uploads/checkin_1_20251001_134614.jpg?v=$timestamp"
echo ""

echo "✅ CACHE-BUSTING TEST COMPLETE!"
echo "📱 Try accessing images with ?v=timestamp parameter!"
