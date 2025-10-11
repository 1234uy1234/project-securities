#!/bin/bash

echo "🔍 Test Admin Dashboard..."

# Test frontend
echo "1. Test frontend response..."
FRONTEND_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://10.10.68.200:5173)
echo "Frontend status: $FRONTEND_STATUS"

# Test backend
echo "2. Test backend response..."
BACKEND_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://10.10.68.200:8000/api/patrol-tasks/)
echo "Backend status: $BACKEND_STATUS"

# Test specific admin dashboard endpoint
echo "3. Test admin dashboard data..."
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "Token obtained: ${TOKEN:0:20}..."
  
  echo "4. Test checkin records..."
  CHECKIN_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records)
  echo "Checkin records status: $CHECKIN_STATUS"
  
  echo "5. Test patrol tasks..."
  TASKS_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  echo "Patrol tasks status: $TASKS_STATUS"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🌐 Mở Admin Dashboard: https://10.10.68.200:5173/admin-dashboard"
echo "🔍 Nếu vẫn bị đen, mở Developer Tools (F12) để xem lỗi JavaScript"
