#!/bin/bash

echo "🧪 TEST HTTPS BACKEND"
echo "===================="

echo "🔍 Kiểm tra certificate:"
echo "----------------------------------------"
ls -la ssl/server.*

echo ""
echo "🔍 Kiểm tra backend process:"
echo "----------------------------------------"
ps aux | grep "python3 -m backend.app.main" | grep -v grep

echo ""
echo "🔍 Test HTTPS connection:"
echo "----------------------------------------"
curl -k -s https://10.10.68.200:5174/health || echo "Backend không chạy"

echo ""
echo "🎯 Kết quả mong đợi:"
echo "- Certificate có sẵn"
echo "- Backend chạy trên https://10.10.68.200:5174"
echo "- Health check trả về {'status':'healthy'}"

echo ""
echo "✅ Nếu backend không chạy, hãy start thủ công!"
