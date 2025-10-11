#!/bin/bash

echo "=== SETUP NGROK TUNNELS ==="

# Kill existing ngrok processes
pkill -f ngrok
sleep 2

# Start backend tunnel
echo "Starting backend tunnel..."
ngrok http 8000 --log=stdout > ngrok_backend.log 2>&1 &
BACKEND_PID=$!

# Wait for ngrok to start
sleep 5

# Get backend URL
echo "Getting backend URL..."
BACKEND_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['config']['addr'] == 'http://localhost:8000':
            print(tunnel['public_url'])
            break
except:
    print('ERROR')
" 2>/dev/null)

if [ "$BACKEND_URL" = "ERROR" ] || [ -z "$BACKEND_URL" ]; then
    echo "❌ Failed to get backend URL"
    exit 1
fi

echo "✅ Backend URL: $BACKEND_URL"

# Start frontend tunnel
echo "Starting frontend tunnel..."
ngrok http 5173 --log=stdout > ngrok_frontend.log 2>&1 &
FRONTEND_PID=$!

# Wait for ngrok to start
sleep 5

# Get frontend URL
echo "Getting frontend URL..."
FRONTEND_URL=$(curl -s http://localhost:4041/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['config']['addr'] == 'http://localhost:5173':
            print(tunnel['public_url'])
            break
except:
    print('ERROR')
" 2>/dev/null)

if [ "$FRONTEND_URL" = "ERROR" ] || [ -z "$FRONTEND_URL" ]; then
    echo "❌ Failed to get frontend URL"
    exit 1
fi

echo "✅ Frontend URL: $FRONTEND_URL"

# Create environment file
echo "Creating environment file..."
cat > .env.ngrok << EOF
# Ngrok URLs
VITE_API_BASE_URL=$BACKEND_URL/api
VITE_FRONTEND_URL=$FRONTEND_URL
VITE_BACKEND_URL=$BACKEND_URL
VITE_WS_URL=$BACKEND_URL/ws

# Backend CORS
NGROK_BACKEND_URL=$BACKEND_URL
NGROK_FRONTEND_URL=$FRONTEND_URL
EOF

echo "✅ Environment file created: .env.ngrok"

# Update backend config
echo "Updating backend config..."
python3 -c "
import re

# Read config file
with open('backend/app/config.py', 'r') as f:
    content = f.read()

# Extract ngrok URLs
backend_url = '$BACKEND_URL'
frontend_url = '$FRONTEND_URL'

# Update allowed_origins
allowed_origins = f\"['{backend_url}', '{frontend_url}']\"
content = re.sub(r\"allowed_origins = .*\", f\"allowed_origins = {allowed_origins}\", content)

# Update frontend_base_url
content = re.sub(r\"frontend_base_url = .*\", f\"frontend_base_url = '{frontend_url}'\", content)

# Write back
with open('backend/app/config.py', 'w') as f:
    f.write(content)

print('✅ Backend config updated')
"

echo ""
echo "🎉 NGROK SETUP COMPLETE!"
echo "Backend URL: $BACKEND_URL"
echo "Frontend URL: $FRONTEND_URL"
echo ""
echo "You can now access your app from mobile devices!"
echo "Backend API: $BACKEND_URL/api"
echo "Frontend App: $FRONTEND_URL"
echo ""
echo "To stop ngrok: pkill -f ngrok"

