#!/bin/bash

echo "=== RESTART SERVICES FOR NGROK ==="

# Kill existing processes
echo "Stopping existing services..."
pkill -f uvicorn
pkill -f "npm run dev"
sleep 2

# Start backend
echo "Starting backend..."
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 3

# Check if backend is running
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Backend started successfully"
else
    echo "❌ Backend failed to start"
    exit 1
fi

# Start frontend
echo "Starting frontend..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

# Wait for frontend to start
sleep 5

# Check if frontend is running
if curl -s http://localhost:5173 > /dev/null; then
    echo "✅ Frontend started successfully"
else
    echo "❌ Frontend failed to start"
    exit 1
fi

echo ""
echo "🎉 SERVICES RESTARTED!"
echo "Backend: http://localhost:8000"
echo "Frontend: http://localhost:5173"
echo ""
echo "Now run ngrok in another terminal:"
echo "ngrok http 8000"
echo ""
echo "Then update config with:"
echo "python3 update_config.py <ngrok_url>"

