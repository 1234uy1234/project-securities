#!/bin/bash

echo "🔍 Kiểm tra users trong database..."

# Login với admin để lấy danh sách users
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "1. Lấy danh sách users..."
  curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/users/ | jq '.[] | {id, username, full_name, role}' 2>/dev/null || echo "Error"
  
  echo ""
  echo "2. Test với user có role employee..."
  
  # Thử với các user có thể có
  for user in "hung" "employee" "test" "user1"; do
    echo "Testing user: $user"
    TEST_LOGIN=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
      -H "Content-Type: application/json" \
      -d "{\"username\": \"$user\", \"password\": \"$user\"}")
    
    TEST_TOKEN=$(echo $TEST_LOGIN | jq -r '.access_token' 2>/dev/null)
    if [ "$TEST_TOKEN" != "null" ] && [ "$TEST_TOKEN" != "" ]; then
      echo "✅ User $user login thành công!"
      USER_ROLE=$(echo $TEST_LOGIN | jq -r '.user.role' 2>/dev/null)
      echo "Role: $USER_ROLE"
      
      if [ "$USER_ROLE" = "employee" ]; then
        echo "🎯 Found employee user: $user"
        break
      fi
    else
      echo "❌ User $user login thất bại"
    fi
  done
  
else
  echo "❌ Không thể lấy token admin!"
fi

echo ""
echo "✅ Kiểm tra hoàn tất!"
