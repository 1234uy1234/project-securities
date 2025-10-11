#!/bin/bash

echo "🔍 Tạo user employee mới để test..."

# Login với admin
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "1. Tạo user employee mới..."
  
  CREATE_USER_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/users/ \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "username": "testemployee",
      "email": "testemployee@example.com",
      "full_name": "Test Employee",
      "password": "test123",
      "role": "employee"
    }')
  
  echo "Create user response: $CREATE_USER_RESPONSE"
  
  echo ""
  echo "2. Test login với user mới..."
  
  TEST_LOGIN=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "testemployee", "password": "test123"}')
  
  echo "Test login response: $TEST_LOGIN"
  
  TEST_TOKEN=$(echo $TEST_LOGIN | jq -r '.access_token' 2>/dev/null)
  if [ "$TEST_TOKEN" != "null" ] && [ "$TEST_TOKEN" != "" ]; then
    echo "✅ User testemployee login thành công!"
    
    echo ""
    echo "3. Test endpoint /my-tasks..."
    MY_TASKS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $TEST_TOKEN" \
      https://10.10.68.200:8000/api/patrol-tasks/my-tasks)
    
    echo "My-tasks response: $MY_TASKS_RESPONSE"
    
  else
    echo "❌ User testemployee login thất bại"
  fi
  
else
  echo "❌ Không thể lấy token admin!"
fi

echo ""
echo "✅ Test hoàn tất!"
