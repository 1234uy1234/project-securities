#!/bin/bash

echo "🔍 Test với user hung (có task được giao)..."

# Test với user hung
echo "1. Test login với user hung..."
for password in "hung123" "123456" "password" "hung" "admin123" "hung@123"; do
  echo "Testing hung:$password"
  TEST_LOGIN=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"hung\", \"password\": \"$password\"}")
  
  TEST_TOKEN=$(echo $TEST_LOGIN | jq -r '.access_token' 2>/dev/null)
  if [ "$TEST_TOKEN" != "null" ] && [ "$TEST_TOKEN" != "" ]; then
    echo "✅ hung:$password - Login thành công!"
    USER_ROLE=$(echo $TEST_LOGIN | jq -r '.user.role' 2>/dev/null)
    USER_ID=$(echo $TEST_LOGIN | jq -r '.user.id' 2>/dev/null)
    echo "Role: $USER_ROLE, ID: $USER_ID"
    
    echo ""
    echo "2. Test endpoint /my-tasks với user hung..."
    MY_TASKS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $TEST_TOKEN" \
      https://10.10.68.200:8000/api/patrol-tasks/my-tasks)
    
    echo "My-tasks response: $MY_TASKS_RESPONSE"
    break
  else
    echo "❌ hung:$password - Login thất bại"
  fi
done

echo ""
echo "✅ Test hoàn tất!"
