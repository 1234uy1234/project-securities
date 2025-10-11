#!/bin/bash

echo "🧪 Test check-in mới để xem ảnh có được lưu đúng chỗ không..."

# Test login để lấy token
echo "🔐 Step 1: Test login..."
LOGIN_RESPONSE=$(curl -s -k -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

# Extract token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
echo "Token: ${TOKEN:0:20}..."

if [ -z "$TOKEN" ]; then
  echo "❌ Không thể lấy token. Kiểm tra username/password."
  exit 1
fi

# Test check-in với token
echo "🔐 Step 2: Test check-in mới..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CHECKIN_RESPONSE=$(curl -s -k -X POST https://10.10.68.200:8000/api/patrol-records/checkin \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "qr_code": "test_qr_'$TIMESTAMP'",
    "location_id": 1,
    "notes": "Test check-in mới",
    "latitude": 0,
    "longitude": 0,
    "photo": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k="
  }')

echo "Check-in response: $CHECKIN_RESPONSE"

if echo "$CHECKIN_RESPONSE" | grep -q "success"; then
  echo "✅ Check-in thành công!"
  
  # Kiểm tra ảnh có được lưu ở đâu
  echo "🔍 Step 3: Kiểm tra ảnh được lưu ở đâu..."
  
  # Tìm ảnh mới nhất
  LATEST_PHOTO=$(ls -t /Users/maybe/Documents/shopee/backend/uploads/checkin_*.jpg 2>/dev/null | head -1)
  if [ -n "$LATEST_PHOTO" ]; then
    echo "✅ Ảnh mới nhất trong backend/uploads: $(basename $LATEST_PHOTO)"
    echo "📁 Đường dẫn: $LATEST_PHOTO"
    
    # Test truy cập ảnh
    PHOTO_NAME=$(basename $LATEST_PHOTO)
    if curl -s -k "https://10.10.68.200:8000/uploads/$PHOTO_NAME" -o /dev/null -w "%{http_code}" | grep -q "200"; then
      echo "✅ Ảnh có thể truy cập được qua API!"
    else
      echo "❌ Ảnh không thể truy cập được qua API!"
    fi
  else
    echo "❌ Không tìm thấy ảnh mới trong backend/uploads!"
  fi
  
  # Kiểm tra ảnh có ở project root không
  ROOT_PHOTO=$(ls -t /Users/maybe/Documents/shopee/uploads/checkin_*.jpg 2>/dev/null | head -1)
  if [ -n "$ROOT_PHOTO" ]; then
    echo "⚠️ Ảnh cũng có trong project root: $(basename $ROOT_PHOTO)"
  fi
  
else
  echo "❌ Check-in thất bại!"
fi

echo "🎉 Test hoàn thành!"
