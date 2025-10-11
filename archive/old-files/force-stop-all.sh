#!/bin/bash

echo "🛑 FORCE STOP ALL PROCESSES"
echo "============================"

# Kill all processes
echo "🔪 Killing all processes..."
pkill -f "uvicorn" || true
pkill -f "vite" || true
pkill -f "node" || true
pkill -f "python.*app" || true

# Force kill by port
echo "🔪 Force killing by port..."
lsof -ti :5173 | xargs kill -9 2>/dev/null || true
lsof -ti :8000 | xargs kill -9 2>/dev/null || true
lsof -ti :5174 | xargs kill -9 2>/dev/null || true

# Wait
sleep 3

# Check
echo "🔍 Checking processes..."
ps aux | grep -E "(uvicorn|vite|node)" | grep -v grep || echo "No processes found"

echo "🔍 Checking ports..."
lsof -i :5173 -i :8000 -i :5174 || echo "No ports in use"

echo "✅ All processes stopped!"
