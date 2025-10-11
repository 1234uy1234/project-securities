#!/bin/bash

echo "🔍 Test login với các password khác nhau..."

# Test với user minh
echo "1. Test user minh với các password..."
for password in "minh123" "123456" "password" "minh" "admin123"; do
  echo "Testing minh:$password"
  TEST_LOGIN=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"minh\", \"password\": \"$password\"}")
  
  TEST_TOKEN=$(echo $TEST_LOGIN | jq -r '.access_token' 2>/dev/null)
  if [ "$TEST_TOKEN" != "null" ] && [ "$TEST_TOKEN" != "" ]; then
    echo "✅ minh:$password - Login thành công!"
    USER_ROLE=$(echo $TEST_LOGIN | jq -r '.user.role' 2>/dev/null)
    USER_ID=$(echo $TEST_LOGIN | jq -r '.user.id' 2>/dev/null)
    echo "Role: $USER_ROLE, ID: $USER_ID"
    
    echo ""
    echo "2. Test endpoint /my-tasks với user minh..."
    MY_TASKS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $TEST_TOKEN" \
      https://10.10.68.200:8000/api/patrol-tasks/my-tasks)
    
    echo "My-tasks response: $MY_TASKS_RESPONSE"
    break
  else
    echo "❌ minh:$password - Login thất bại"
  fi
done

echo ""
echo "3. Test với user hung..."
for password in "hung123" "123456" "password" "hung" "admin123"; do
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
    echo "4. Test endpoint /my-tasks với user hung..."
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
