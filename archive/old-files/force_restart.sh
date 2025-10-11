#!/bin/bash

echo "🔄 FORCE RESTART - Clear all caches and restart"

# Stop all processes
pkill -f "npm run dev" 2>/dev/null
pkill -f "uvicorn" 2>/dev/null
pkill -f "nginx" 2>/dev/null
pkill -f "ngrok" 2>/dev/null
sleep 3

# Clear all caches
cd /Users/maybe/Documents/shopee/frontend
rm -rf node_modules/.vite
rm -rf dist
rm -rf .vite
rm -rf .env.local
rm -rf .env.production
rm -rf .env.development

# Restart backend
echo "🔧 Restart Backend..."
cd /Users/maybe/Documents/shopee
python3 -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload &
sleep 3

# Restart frontend
echo "🌐 Restart Frontend..."
cd /Users/maybe/Documents/shopee/frontend
npm run dev -- --host 0.0.0.0 --port 5173 &
sleep 3

# Restart nginx
echo "🔄 Restart Nginx..."
cd /Users/maybe/Documents/shopee
nginx -c $(pwd)/nginx_combined.conf &
sleep 2

# Restart ngrok
echo "🌍 Restart Ngrok..."
ngrok http 10.10.68.200:8080 --log=stdout > ngrok_combined.log 2>&1 &
sleep 5

# Get URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data.get('tunnels', []):
        if tunnel.get('proto') == 'https':
            print(tunnel.get('public_url'))
            break
except:
    print('')
")

if [ -n "$NGROK_URL" ]; then
    echo ""
    echo "🎉 FORCE RESTART COMPLETED!"
    echo "🌐 URL: $NGROK_URL"
    echo "👤 Login: admin / admin123"
    echo ""
    echo "📝 IMPORTANT: Clear browser cache (Ctrl+Shift+R) before testing!"
    echo "🔧 If still having issues, try incognito mode"
else
    echo "❌ Cannot get Ngrok URL"
fi
