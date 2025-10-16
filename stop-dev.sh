#!/bin/bash

# Stop Development Environment Script
# This script stops all running development services

echo "🛑 Stopping Smart Patrol System Development Environment"
echo "======================================================"

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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to kill processes by port
kill_by_port() {
    local port=$1
    local service_name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        local pids=$(lsof -ti:$port)
        echo "$pids" | xargs kill -9 2>/dev/null
        print_status "Đã tắt $service_name trên port $port"
    else
        print_info "$service_name trên port $port không chạy"
    fi
}

# Function to kill processes by name
kill_by_name() {
    local process_name=$1
    local service_name=$2
    
    if pgrep -f "$process_name" >/dev/null 2>&1; then
        pkill -f "$process_name"
        print_status "Đã tắt $service_name"
    else
        print_info "$service_name không chạy"
    fi
}

print_info "Đang dừng tất cả services..."

# Stop services by port
kill_by_port 8000 "Backend (FastAPI)"
kill_by_port 5173 "Frontend (React)"
kill_by_port 4040 "Ngrok Dashboard"

# Stop services by process name
kill_by_name "uvicorn.*app.main:app" "Backend Process"
kill_by_name "npm run dev" "Frontend Process"
kill_by_name "ngrok" "Ngrok Tunnel"
kill_by_name "cloudflared" "Cloudflare Tunnel"

# Clean up log files (optional)
if [ "$1" = "--clean" ]; then
    print_info "Đang xóa log files..."
    rm -f backend.log frontend.log ngrok.log cloudflare.log current_url.txt
    print_status "Đã xóa log files"
fi

print_status "Tất cả services đã được dừng"
echo ""
echo "Để khởi động lại, chạy:"
echo "  npm run dev"
echo "  hoặc"
echo "  ./run-dev.sh"
