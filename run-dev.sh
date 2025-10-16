#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FRONTEND_PORT=5173
BACKEND_PORT=8000
FRONTEND_URL="http://localhost:$FRONTEND_PORT"
BACKEND_URL="http://0.0.0.0:$BACKEND_PORT"

# Process IDs
BACKEND_PID=""
FRONTEND_PID=""
NGROK_PID=""
CLOUDFLARE_PID=""

# Current tunnel type
CURRENT_TUNNEL="none"
CURRENT_URL=""

# Function to print colored output
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

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to kill process by PID
kill_process() {
    local pid=$1
    local name=$2
    if [ ! -z "$pid" ] && kill -0 $pid 2>/dev/null; then
        kill $pid
        print_info "Đã tắt $name (PID: $pid)"
    fi
}

# Function to start backend
start_backend() {
    print_info "Đang khởi động Backend..."
    
    if check_port $BACKEND_PORT; then
        print_warning "Port $BACKEND_PORT đã được sử dụng. Đang tắt process cũ..."
        lsof -ti:$BACKEND_PORT | xargs kill -9 2>/dev/null
        sleep 2
    fi
    
    # Start backend in background
    cd backend
    python -m uvicorn app.main:app --host 0.0.0.0 --port $BACKEND_PORT --reload > ../backend.log 2>&1 &
    BACKEND_PID=$!
    cd ..
    
    # Wait for backend to start
    sleep 3
    
    if check_port $BACKEND_PORT; then
        print_status "Backend đã chạy trên $BACKEND_URL (PID: $BACKEND_PID)"
        return 0
    else
        print_error "Không thể khởi động Backend"
        return 1
    fi
}

# Function to start frontend
start_frontend() {
    print_info "Đang khởi động Frontend..."
    
    if check_port $FRONTEND_PORT; then
        print_warning "Port $FRONTEND_PORT đã được sử dụng. Đang tắt process cũ..."
        lsof -ti:$FRONTEND_PORT | xargs kill -9 2>/dev/null
        sleep 2
    fi
    
    # Start frontend in background
    cd frontend
    npm run dev > ../frontend.log 2>&1 &
    FRONTEND_PID=$!
    cd ..
    
    # Wait for frontend to start
    sleep 5
    
    if check_port $FRONTEND_PORT; then
        print_status "Frontend đã chạy trên $FRONTEND_URL (PID: $FRONTEND_PID)"
        return 0
    else
        print_error "Không thể khởi động Frontend"
        return 1
    fi
}

# Function to start ngrok
start_ngrok() {
    print_info "Đang khởi động Ngrok..."
    
    # Kill existing ngrok processes
    pkill -f ngrok 2>/dev/null
    
    # Start ngrok
    ngrok http $FRONTEND_PORT > ngrok.log 2>&1 &
    NGROK_PID=$!
    
    # Wait for ngrok to start
    sleep 3
    
    # Get ngrok URL
    local ngrok_url=""
    for i in {1..10}; do
        ngrok_url=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4)
        if [ ! -z "$ngrok_url" ]; then
            break
        fi
        sleep 1
    done
    
    if [ ! -z "$ngrok_url" ]; then
        CURRENT_TUNNEL="ngrok"
        CURRENT_URL="$ngrok_url"
        print_status "Ngrok đã chạy: $ngrok_url"
        echo "$ngrok_url" > current_url.txt
        return 0
    else
        print_error "Không thể khởi động Ngrok"
        return 1
    fi
}

# Function to start Cloudflare Tunnel
start_cloudflare() {
    print_info "Đang khởi động Cloudflare Tunnel..."
    
    # Kill existing cloudflared processes
    pkill -f cloudflared 2>/dev/null
    
    # Check if cloudflared is installed
    if ! command -v cloudflared &> /dev/null; then
        print_error "cloudflared chưa được cài đặt. Vui lòng cài đặt:"
        print_info "brew install cloudflared (macOS)"
        print_info "hoặc tải từ: https://github.com/cloudflare/cloudflared/releases"
        return 1
    fi
    
    # Start cloudflared
    cloudflared tunnel --url http://localhost:$FRONTEND_PORT > cloudflare.log 2>&1 &
    CLOUDFLARE_PID=$!
    
    # Wait for cloudflare to start
    sleep 3
    
    # Get cloudflare URL from log
    local cloudflare_url=""
    for i in {1..10}; do
        cloudflare_url=$(grep -a -o 'https://[^.]*\.trycloudflare\.com' cloudflare.log 2>/dev/null | tail -1)
        if [ ! -z "$cloudflare_url" ]; then
            break
        fi
        sleep 1
    done
    
    if [ ! -z "$cloudflare_url" ]; then
        CURRENT_TUNNEL="cloudflare"
        CURRENT_URL="$cloudflare_url"
        print_status "Cloudflare Tunnel đã chạy: $cloudflare_url"
        echo "$cloudflare_url" > current_url.txt
        return 0
    else
        print_error "Không thể khởi động Cloudflare Tunnel"
        return 1
    fi
}

# Function to check ngrok status
check_ngrok_status() {
    if [ -z "$NGROK_PID" ] || ! kill -0 $NGROK_PID 2>/dev/null; then
        return 1
    fi
    
    # Check for ERR_NGROK_725 in ngrok log
    if grep -q "ERR_NGROK_725" ngrok.log 2>/dev/null; then
        return 1
    fi
    
    # Check if ngrok API is responding
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4040/api/tunnels)
    if [ "$response" != "200" ]; then
        return 1
    fi
    
    return 0
}

# Function to monitor and switch tunnels
monitor_tunnels() {
    print_info "Đang theo dõi trạng thái tunnel..."
    
    while true; do
        sleep 30  # Tăng thời gian chờ để tránh chuyển đổi quá nhanh
        
        if [ "$CURRENT_TUNNEL" = "ngrok" ]; then
            if ! check_ngrok_status; then
                print_warning "Ngrok gặp lỗi (ERR_NGROK_725 hoặc không phản hồi). Chuyển sang Cloudflare Tunnel..."
                
                # Kill ngrok
                kill_process $NGROK_PID "Ngrok"
                NGROK_PID=""
                
                # Start Cloudflare
                if start_cloudflare; then
                    print_status "Đã chuyển sang Cloudflare Tunnel: $CURRENT_URL"
                else
                    print_error "Không thể khởi động Cloudflare Tunnel"
                fi
            fi
        elif [ "$CURRENT_TUNNEL" = "cloudflare" ]; then
            # Try to restart ngrok
            if start_ngrok; then
                print_status "Ngrok đã hoạt động lại. Chuyển từ Cloudflare sang Ngrok..."
                
                # Kill Cloudflare
                kill_process $CLOUDFLARE_PID "Cloudflare Tunnel"
                CLOUDFLARE_PID=""
                
                print_status "Đã chuyển sang Ngrok: $CURRENT_URL"
            fi
        fi
    done
}

# Function to cleanup on exit
cleanup() {
    print_info "Đang dọn dẹp..."
    
    kill_process $BACKEND_PID "Backend"
    kill_process $FRONTEND_PID "Frontend"
    kill_process $NGROK_PID "Ngrok"
    kill_process $CLOUDFLARE_PID "Cloudflare Tunnel"
    
    # Kill any remaining processes
    pkill -f "uvicorn.*app.main:app" 2>/dev/null
    pkill -f "npm run dev" 2>/dev/null
    pkill -f ngrok 2>/dev/null
    pkill -f cloudflared 2>/dev/null
    
    print_status "Đã dọn dẹp xong"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main execution
main() {
    echo -e "${BLUE}🚀 Khởi động Development Environment${NC}"
    echo "=================================="
    
    # Check dependencies
    if ! command -v ngrok &> /dev/null; then
        print_error "ngrok chưa được cài đặt. Vui lòng cài đặt ngrok trước."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm chưa được cài đặt. Vui lòng cài đặt Node.js trước."
        exit 1
    fi
    
    # Start services
    if ! start_backend; then
        exit 1
    fi
    
    if ! start_frontend; then
        cleanup
        exit 1
    fi
    
    # Try ngrok first, fallback to Cloudflare
    if ! start_ngrok; then
        print_warning "Ngrok không khởi động được. Thử Cloudflare Tunnel..."
        if ! start_cloudflare; then
            print_error "Cả Ngrok và Cloudflare đều không khởi động được"
            cleanup
            exit 1
        fi
    fi
    
    echo "=================================="
    print_status "Tất cả services đã sẵn sàng!"
    print_info "🌍 Public URL: $CURRENT_URL"
    print_info "📱 Frontend: $FRONTEND_URL"
    print_info "🔧 Backend: $BACKEND_URL"
    print_info "📊 Ngrok Dashboard: http://localhost:4040"
    echo "=================================="
    print_info "Nhấn Ctrl+C để dừng tất cả services"
    
    # Start monitoring in background
    monitor_tunnels &
    
    # Keep script running
    wait
}

# Run main function
main
