#!/bin/bash

echo "🔍 Test Employee Dashboard hoàn chỉnh..."

# Test với user testemployee
echo "1. Login với testemployee..."
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testemployee", "password": "test123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)
USER_ROLE=$(echo $LOGIN_RESPONSE | jq -r '.user.role' 2>/dev/null)
USER_ID=$(echo $LOGIN_RESPONSE | jq -r '.user.id' 2>/dev/null)

echo "Login response: $LOGIN_RESPONSE"
echo "Role: $USER_ROLE, ID: $USER_ID"

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo ""
  echo "2. Test endpoint /my-tasks..."
  MY_TASKS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/my-tasks)
  
  echo "My-tasks response: $MY_TASKS_RESPONSE"
  
  echo ""
  echo "3. Test endpoint /locations/ (should work for employee)..."
  LOCATIONS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/locations/)
  
  if echo "$LOCATIONS_RESPONSE" | grep -q "id"; then
    echo "✅ Locations endpoint works for employee"
    echo "Locations count: $(echo "$LOCATIONS_RESPONSE" | jq '. | length')"
  else
    echo "❌ Locations endpoint failed: $LOCATIONS_RESPONSE"
  fi
  
  echo ""
  echo "4. Test endpoint /patrol-tasks/ (should fail for employee)..."
  ALL_TASKS_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  if [ "$ALL_TASKS_STATUS" == "403" ]; then
    echo "✅ All-tasks endpoint correctly returns 403 for employee"
  else
    echo "❌ All-tasks endpoint returned: $ALL_TASKS_STATUS (expected 403)"
  fi
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
echo "🌐 Mở Employee Dashboard: https://10.10.68.200:5173/dashboard"
echo "🔍 Login với: testemployee / test123"
