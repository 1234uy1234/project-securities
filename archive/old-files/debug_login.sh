#!/bin/bash

echo "=== DEBUG LOGIN ISSUE ==="
echo ""
echo "🔍 Testing Backend API..."

# Test health endpoint
echo "1. Testing health endpoint:"
curl -k -s https://10.10.68.200:8000/health
echo ""
echo ""

# Test login endpoint
echo "2. Testing login endpoint:"
curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}' | jq .
echo ""
echo ""

# Test CORS
echo "3. Testing CORS with Origin header:"
curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Origin: https://10.10.68.200:5173" \
  -d '{"username": "admin", "password": "admin123"}' | jq .
echo ""
echo ""

echo "📱 Mobile Debug Steps:"
echo "1. Open browser developer tools on mobile"
echo "2. Check Network tab for failed requests"
echo "3. Check Console for error messages"
echo "4. Try accessing: https://10.10.68.200:8000/health"
echo ""
echo "🔧 If SSL error on mobile:"
echo "1. Tap 'Advanced' or 'Tiếp tục'"
echo "2. Select 'Proceed to 10.10.68.200 (unsafe)'"
echo "3. Or 'Accept Risk and Continue'"
echo ""
echo "🎯 Direct URLs:"
echo "   Frontend: https://10.10.68.200:5173"
echo "   Backend:  https://10.10.68.200:8000"
echo "   Health:   https://10.10.68.200:8000/health"
