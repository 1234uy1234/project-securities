#!/bin/bash

echo "=== CLEAR IMAGE CACHE ==="

# 1. Clear browser cache (instructions)
echo "📱 MOBILE BROWSER CACHE CLEAR:"
echo "1. Chrome: Settings > Privacy > Clear browsing data > Cached images and files"
echo "2. Safari: Settings > Safari > Clear History and Website Data"
echo "3. Firefox: Settings > Privacy > Clear Data > Cached Web Content"
echo ""

# 2. Clear service worker cache
echo "🔧 SERVICE WORKER CACHE CLEAR:"
echo "1. Open DevTools (F12)"
echo "2. Go to Application tab"
echo "3. Click 'Service Workers'"
echo "4. Click 'Unregister' for this site"
echo "5. Refresh page"
echo ""

# 3. Test image URLs
echo "🧪 TEST IMAGE URLs:"
echo "New IP (10.10.68.200):"
echo "https://10.10.68.200:8000/uploads/checkin_1_20251001_134856.jpg"
echo "https://10.10.68.200:8000/uploads/checkin_1_20251001_134839.jpg"
echo "https://10.10.68.200:8000/uploads/checkin_1_20251001_134614.jpg"
echo ""

# 4. Check if images exist
echo "📁 CHECK IMAGE FILES:"
ls -la backend/uploads/checkin_1_20251001_134*.jpg
echo ""

# 5. Test static file serving
echo "🌐 TEST STATIC FILE SERVING:"
curl -k -s -o /dev/null -w "Status: %{http_code}\n" "https://10.10.68.200:8000/uploads/checkin_1_20251001_134856.jpg"
curl -k -s -o /dev/null -w "Status: %{http_code}\n" "https://10.10.68.200:8000/uploads/checkin_1_20251001_134839.jpg"
curl -k -s -o /dev/null -w "Status: %{http_code}\n" "https://10.10.68.200:8000/uploads/checkin_1_20251001_134614.jpg"
echo ""

echo "✅ CACHE CLEAR INSTRUCTIONS COMPLETE!"
echo "📱 Please clear browser cache on mobile and try again!"
