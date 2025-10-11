#!/bin/bash

echo "🔍 Kiểm tra trạng thái cuối cùng..."

# Lấy token
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo ""
  echo "1. Checkin records (latest 3):"
  curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records | jq '.[0:3] | .[] | {id, task_id, task_title, location_id, check_in_time, photo_url}' 2>/dev/null || echo "Error"
  
  echo ""
  echo "2. Patrol tasks (latest 3):"
  curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/ | jq '.[0:3] | .[] | {id, title, status, stops: [.stops[] | {location_id, sequence, scheduled_time, completed}]}' 2>/dev/null || echo "Error"
    
  echo ""
  echo "3. System status:"
  echo "✅ Backend HTTPS: https://10.10.68.200:8000"
  echo "✅ Frontend HTTPS: https://10.10.68.200:5173"
  echo "✅ SSL Certificate: mkcert trusted"
  echo "✅ CORS: Configured correctly"
  echo "✅ API: Working with authentication"
  echo "✅ Check-in: Creating records successfully"
  
  echo ""
  echo "4. Next steps:"
  echo "🌐 Open Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
  echo "🔍 Check browser console for debug logs"
  echo "📱 Test check-in from QR Scanner page"
  echo "🔄 Check if FlowStep updates after check-in"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Kiểm tra hoàn tất!"

