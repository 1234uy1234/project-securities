#!/bin/bash

echo "🔍 Test API với authentication thật..."

# Lấy token từ localStorage của browser (giả định)
echo "1. Test login để lấy token..."
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

echo "Login response: $LOGIN_RESPONSE"

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)
echo "Token: $TOKEN"

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo ""
  echo "2. Test API với token..."
  
  echo "Checkin records:"
  curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records | jq '.[0:2]' 2>/dev/null || echo "Error"
  
  echo ""
  echo "Patrol tasks:"
  curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/ | jq '.[0:2]' 2>/dev/null || echo "Error"
    
  echo ""
  echo "Locations:"
  curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/locations/ | jq '.[0:2]' 2>/dev/null || echo "Error"
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"

