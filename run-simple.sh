#!/bin/bash

# Simple Development Script - No Auto Switching
# This script starts all services without complex monitoring

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Configuration
FRONTEND_PORT=5173
BACKEND_PORT=8000

echo -e "${BLUE}🚀 Khởi động Development Environment (Simple Mode)${NC}"
echo "=================================================="

# Function to cleanup on exit
cleanup() {
    print_info "Đang dọn dẹp..."
    pkill -f "uvicorn.*app.main:app" 2>/dev/null
    pkill -f "npm run dev" 2>/dev/null
    pkill -f ngrok 2>/dev/null
    pkill -f cloudflared 2>/dev/null
    print_status "Đã dọn dẹp xong"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start Backend
print_info "Đang khởi động Backend..."
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port $BACKEND_PORT --reload > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

sleep 3
if lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_status "Backend đã chạy trên http://0.0.0.0:$BACKEND_PORT (PID: $BACKEND_PID)"
else
    print_error "Không thể khởi động Backend"
    exit 1
fi

# Start Frontend
print_info "Đang khởi động Frontend..."
cd frontend
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

sleep 5
if lsof -Pi :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_status "Frontend đã chạy trên http://localhost:$FRONTEND_PORT (PID: $FRONTEND_PID)"
else
    print_error "Không thể khởi động Frontend"
    cleanup
    exit 1
fi

# Start Ngrok
print_info "Đang khởi động Ngrok..."
ngrok http $FRONTEND_PORT > ngrok.log 2>&1 &
NGROK_PID=$!

sleep 3

# Get ngrok URL
NGROK_URL=""
for i in {1..10}; do
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ ! -z "$NGROK_URL" ]; then
        break
    fi
    sleep 1
done

if [ ! -z "$NGROK_URL" ]; then
    print_status "Ngrok đã chạy: $NGROK_URL"
    echo "$NGROK_URL" > current_url.txt
else
    print_warning "Ngrok không khởi động được. Thử Cloudflare Tunnel..."
    
    # Try Cloudflare
    if command -v cloudflared &> /dev/null; then
        cloudflared tunnel --url http://localhost:$FRONTEND_PORT > cloudflare.log 2>&1 &
        CLOUDFLARE_PID=$!
        
        sleep 3
        
        # Get cloudflare URL
        CLOUDFLARE_URL=""
        for i in {1..10}; do
            CLOUDFLARE_URL=$(grep -a -o 'https://[^.]*\.trycloudflare\.com' cloudflare.log 2>/dev/null | tail -1)
            if [ ! -z "$CLOUDFLARE_URL" ]; then
                break
            fi
            sleep 1
        done
        
        if [ ! -z "$CLOUDFLARE_URL" ]; then
            print_status "Cloudflare Tunnel đã chạy: $CLOUDFLARE_URL"
            echo "$CLOUDFLARE_URL" > current_url.txt
            NGROK_URL="$CLOUDFLARE_URL"
        else
            print_error "Cả Ngrok và Cloudflare đều không khởi động được"
            cleanup
            exit 1
        fi
    else
        print_error "cloudflared chưa được cài đặt"
        cleanup
        exit 1
    fi
fi

echo "=================================================="
print_status "Tất cả services đã sẵn sàng!"
print_info "🌍 Public URL: $NGROK_URL"
print_info "📱 Frontend: http://localhost:$FRONTEND_PORT"
print_info "🔧 Backend: http://0.0.0.0:$BACKEND_PORT"
print_info "📊 Ngrok Dashboard: http://localhost:4040"
echo "=================================================="
print_info "Nhấn Ctrl+C để dừng tất cả services"

# Keep script running
wait
