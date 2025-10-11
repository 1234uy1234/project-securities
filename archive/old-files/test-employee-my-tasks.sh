#!/bin/bash

echo "🔍 Test endpoint my-tasks cho employee..."

# Test với user minh (employee)
echo "1. Login với user minh (employee)..."
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "minh", "password": "minh123"}')

echo "Login response: $LOGIN_RESPONSE"

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)
USER_ROLE=$(echo $LOGIN_RESPONSE | jq -r '.user.role' 2>/dev/null)
USER_ID=$(echo $LOGIN_RESPONSE | jq -r '.user.id' 2>/dev/null)

echo "Token: ${TOKEN:0:20}..."
echo "User role: $USER_ROLE"
echo "User ID: $USER_ID"

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo ""
  echo "2. Test endpoint /my-tasks..."
  
  MY_TASKS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/my-tasks)
  
  echo "My-tasks response: $MY_TASKS_RESPONSE"
  
  echo ""
  echo "3. Test endpoint /patrol-tasks/ (should fail for employee)..."
  
  ALL_TASKS_RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  echo "All-tasks status: $ALL_TASKS_RESPONSE (should be 403 for employee)"
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
