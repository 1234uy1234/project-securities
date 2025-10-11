#!/bin/bash

echo "🔍 Tạo task cho user testemployee..."

# Login với admin
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "1. Tạo task cho testemployee..."
  
  CREATE_TASK_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/patrol-tasks/ \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "title": "Test Task cho Employee",
      "description": "Nhiệm vụ test cho employee",
      "assigned_to": 14,
      "location_id": 1
    }')
  
  echo "Create task response: $CREATE_TASK_RESPONSE"
  
  echo ""
  echo "2. Test login với testemployee..."
  
  TEST_LOGIN=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "testemployee", "password": "test123"}')
  
  TEST_TOKEN=$(echo $TEST_LOGIN | jq -r '.access_token' 2>/dev/null)
  if [ "$TEST_TOKEN" != "null" ] && [ "$TEST_TOKEN" != "" ]; then
    echo "✅ testemployee login thành công!"
    
    echo ""
    echo "3. Test endpoint /my-tasks với task mới..."
    MY_TASKS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $TEST_TOKEN" \
      https://10.10.68.200:8000/api/patrol-tasks/my-tasks)
    
    echo "My-tasks response: $MY_TASKS_RESPONSE"
    
  else
    echo "❌ testemployee login thất bại"
  fi
  
else
  echo "❌ Không thể lấy token admin!"
fi

echo ""
echo "✅ Test hoàn tất!"
