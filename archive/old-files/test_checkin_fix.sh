#!/bin/bash

echo "🧪 Test check-in với token và thời gian Việt Nam..."

# Test login để lấy token
echo "🔐 Step 1: Test login..."
LOGIN_RESPONSE=$(curl -s -k -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

echo "Login response: $LOGIN_RESPONSE"

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
echo "Token: ${TOKEN:0:20}..."

if [ -z "$TOKEN" ]; then
  echo "❌ Không thể lấy token. Kiểm tra username/password."
  exit 1
fi

# Test check-in với token
echo "🔐 Step 2: Test check-in với token..."
CHECKIN_RESPONSE=$(curl -s -k -X POST https://10.10.68.200:8000/api/patrol-records/checkin \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "qr_code": "test_qr_123",
    "location_id": 1,
    "notes": "Test check-in từ script",
    "latitude": 0,
    "longitude": 0,
    "photo": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k="
  }')

echo "Check-in response: $CHECKIN_RESPONSE"

if echo "$CHECKIN_RESPONSE" | grep -q "success"; then
  echo "✅ Check-in thành công!"
else
  echo "❌ Check-in thất bại!"
fi

echo "🎉 Test hoàn thành!"
