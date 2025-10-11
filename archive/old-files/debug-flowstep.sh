#!/bin/bash

echo "🔍 Debug FlowStep không hiển thị check-in..."

# Test API để xem có data check-in không
echo "1. Test API checkin records..."
curl -k -s -H "Authorization: Bearer $(cat /Users/maybe/Documents/shopee/test_token.txt 2>/dev/null || echo 'test')" \
  https://10.10.68.200:8000/api/checkin/admin/all-records | jq '.[0:3]' 2>/dev/null || echo "API Error"

echo ""
echo "2. Test API patrol tasks..."
curl -k -s -H "Authorization: Bearer $(cat /Users/maybe/Documents/shopee/test_token.txt 2>/dev/null || echo 'test')" \
  https://10.10.68.200:8000/api/patrol-tasks/ | jq '.[0:2]' 2>/dev/null || echo "API Error"

echo ""
echo "3. Test API locations..."
curl -k -s -H "Authorization: Bearer $(cat /Users/maybe/Documents/shopee/test_token.txt 2>/dev/null || echo 'test')" \
  https://10.10.68.200:8000/api/locations/ | jq '.[0:3]' 2>/dev/null || echo "API Error"

echo ""
echo "✅ Debug hoàn tất!"

