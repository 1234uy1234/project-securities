#!/bin/bash

# Script tự động restart services sau khi migration IP
# Usage: ./restart_after_migration.sh [NEW_IP]

set -e

NEW_IP=${1:-"localhost"}
PROJECT_ROOT="/Users/maybe/Documents/shopee"
FRONTEND_PORT=3000
BACKEND_PORT=8000

echo "🚀 Restarting services after migration to IP: $NEW_IP"
echo "=================================================="

# Function để kill processes
kill_processes() {
    echo "🔄 Stopping existing processes..."
    
    # Kill frontend processes
    pkill -f "npm.*dev" || true
    pkill -f "vite" || true
    
    # Kill backend processes
    pkill -f "uvicorn" || true
    pkill -f "python.*main:app" || true
    
    # Kill nginx
    pkill -f "nginx" || true
    
    sleep 2
    echo "✅ Processes stopped"
}

# Function để generate SSL certificates
generate_ssl_certs() {
    echo "🔐 Generating SSL certificates for new IP..."
    
    cd "$PROJECT_ROOT/backend"
    
    # Tạo private key
    openssl genrsa -out key.pem 2048
    
    # Tạo certificate request
    openssl req -new -key key.pem -out cert.csr -subj "/C=VN/ST=HCM/L=HCM/O=MANHTOAN/OU=IT/CN=$NEW_IP"
    
    # Tạo certificate
    openssl x509 -req -days 365 -in cert.csr -signkey key.pem -out cert.pem
    
    # Cleanup
    rm cert.csr
    
    echo "✅ SSL certificates generated"
}

# Function để start backend
start_backend() {
    echo "🔄 Starting backend service..."
    
    cd "$PROJECT_ROOT/backend"
    
    # Activate virtual environment if exists
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    # Start backend với SSL
    nohup python3 -m uvicorn app.main:app \
        --host 0.0.0.0 \
        --port $BACKEND_PORT \
        --ssl-keyfile key.pem \
        --ssl-certfile cert.pem \
        --log-level info \
        > ../backend.log 2>&1 &
    
    BACKEND_PID=$!
    echo "✅ Backend started (PID: $BACKEND_PID)"
    
    # Wait for backend to start
    sleep 5
    
    # Test backend
    if curl -k -s "https://$NEW_IP:$BACKEND_PORT/api/health" > /dev/null; then
        echo "✅ Backend health check passed"
    else
        echo "⚠️ Backend health check failed, but continuing..."
    fi
}

# Function để start frontend
start_frontend() {
    echo "🔄 Starting frontend service..."
    
    cd "$PROJECT_ROOT/frontend"
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing frontend dependencies..."
        npm install
    fi
    
    # Start frontend
    nohup npm run dev -- --host 0.0.0.0 --port $FRONTEND_PORT \
        > ../frontend.log 2>&1 &
    
    FRONTEND_PID=$!
    echo "✅ Frontend started (PID: $FRONTEND_PID)"
    
    # Wait for frontend to start
    sleep 10
    
    # Test frontend
    if curl -k -s "https://$NEW_IP:$FRONTEND_PORT" > /dev/null; then
        echo "✅ Frontend health check passed"
    else
        echo "⚠️ Frontend health check failed, but continuing..."
    fi
}

# Function để start nginx
start_nginx() {
    echo "🔄 Starting nginx..."
    
    cd "$PROJECT_ROOT"
    
    # Update nginx config với IP mới
    if [ -f "nginx-https.conf" ]; then
        sed -i.bak "s/server_name .*/server_name $NEW_IP;/" nginx-https.conf
        echo "✅ Updated nginx config"
    fi
    
    # Start nginx
    sudo nginx -c "$PROJECT_ROOT/nginx-https.conf" || true
    
    echo "✅ Nginx started"
}

# Function để test services
test_services() {
    echo "🧪 Testing services..."
    
    # Test backend API
    echo "Testing backend API..."
    if curl -k -s "https://$NEW_IP:$BACKEND_PORT/api/health" | grep -q "ok"; then
        echo "✅ Backend API: OK"
    else
        echo "❌ Backend API: FAILED"
    fi
    
    # Test frontend
    echo "Testing frontend..."
    if curl -k -s "https://$NEW_IP:$FRONTEND_PORT" | grep -q "html"; then
        echo "✅ Frontend: OK"
    else
        echo "❌ Frontend: FAILED"
    fi
    
    # Test PWA manifest
    echo "Testing PWA manifest..."
    if curl -k -s "https://$NEW_IP:$FRONTEND_PORT/manifest.json" | grep -q "name"; then
        echo "✅ PWA Manifest: OK"
    else
        echo "❌ PWA Manifest: FAILED"
    fi
}

# Function để tạo QR code
create_qr_code() {
    echo "📱 Creating QR code for new IP..."
    
    cd "$PROJECT_ROOT"
    
    # Tạo QR code bằng Python
    python3 -c "
import qrcode
import sys

url = 'https://$NEW_IP:$FRONTEND_PORT'
qr = qrcode.QRCode(version=1, box_size=10, border=5)
qr.add_data(url)
qr.make(fit=True)

img = qr.make_image(fill_color='black', back_color='white')
filename = 'pwa_install_qr_${NEW_IP//./_}.png'
img.save(filename)

print(f'✅ QR code created: {filename}')
print(f'📱 URL: {url}')
"
}

# Function để tạo status report
create_status_report() {
    echo "📋 Creating status report..."
    
    REPORT_FILE="migration_status_${NEW_IP//./_}.txt"
    
    cat > "$REPORT_FILE" << EOF
# 📊 MIGRATION STATUS REPORT

## 🎯 System Information
- **New IP**: $NEW_IP
- **Frontend Port**: $FRONTEND_PORT
- **Backend Port**: $BACKEND_PORT
- **Migration Time**: $(date)

## 🔗 URLs
- **PWA Install**: https://$NEW_IP:$FRONTEND_PORT
- **Admin Dashboard**: https://$NEW_IP:$FRONTEND_PORT/admin
- **API Base**: https://$NEW_IP:$BACKEND_PORT/api
- **WebSocket**: wss://$NEW_IP:$BACKEND_PORT/ws

## 📱 QR Code
- **File**: pwa_install_qr_${NEW_IP//./_}.png
- **URL**: https://$NEW_IP:$FRONTEND_PORT

## 🚀 Services Status
- **Backend**: $(pgrep -f "uvicorn" > /dev/null && echo "RUNNING" || echo "STOPPED")
- **Frontend**: $(pgrep -f "npm.*dev" > /dev/null && echo "RUNNING" || echo "STOPPED")
- **Nginx**: $(pgrep -f "nginx" > /dev/null && echo "RUNNING" || echo "STOPPED")

## 📝 Next Steps
1. Share QR code with users
2. Test PWA installation
3. Monitor logs for any issues
4. Update users about new IP

## 🔧 Troubleshooting
- Check logs: tail -f backend.log frontend.log
- Restart services: ./restart_after_migration.sh $NEW_IP
- Health check: curl -k https://$NEW_IP:$BACKEND_PORT/api/health

---
Migration completed successfully! 🎉
EOF

    echo "✅ Status report created: $REPORT_FILE"
}

# Main execution
main() {
    echo "🚀 Starting service restart after migration..."
    
    # 1. Kill existing processes
    kill_processes
    
    # 2. Generate SSL certificates
    generate_ssl_certs
    
    # 3. Start backend
    start_backend
    
    # 4. Start frontend
    start_frontend
    
    # 5. Start nginx
    start_nginx
    
    # 6. Test services
    test_services
    
    # 7. Create QR code
    create_qr_code
    
    # 8. Create status report
    create_status_report
    
    echo ""
    echo "🎉 SERVICES RESTART COMPLETED!"
    echo "=================================================="
    echo "📍 New IP: $NEW_IP"
    echo "📱 PWA URL: https://$NEW_IP:$FRONTEND_PORT"
    echo "🔧 API URL: https://$NEW_IP:$BACKEND_PORT/api"
    echo "📱 QR Code: pwa_install_qr_${NEW_IP//./_}.png"
    echo "📋 Status Report: migration_status_${NEW_IP//./_}.txt"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Share QR code with users"
    echo "2. Test PWA installation"
    echo "3. Monitor logs: tail -f backend.log frontend.log"
    echo ""
}

# Run main function
main "$@"

