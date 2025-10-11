#!/bin/bash

echo "🔍 Test hệ thống HTTPS hoàn chỉnh..."

# Test Backend
echo "1. Test Backend HTTPS..."
curl -k -s -o /dev/null -w "Backend: %{http_code}\n" https://10.10.68.200:8000/api/locations/

# Test Frontend  
echo "2. Test Frontend HTTPS..."
curl -k -s -o /dev/null -w "Frontend: %{http_code}\n" https://10.10.68.200:5173

# Test CORS
echo "3. Test CORS..."
curl -k -s -X OPTIONS \
  -H "Origin: https://10.10.68.200:5173" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: authorization" \
  -o /dev/null -w "CORS: %{http_code}\n" \
  https://10.10.68.200:8000/api/locations/

echo "✅ Test hoàn tất!"
