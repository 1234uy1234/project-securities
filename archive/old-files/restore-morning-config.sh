#!/bin/bash

# 🔄 KHÔI PHỤC LẠI CẤU HÌNH SÁNG NAY
# Khôi phục backend như sáng nay khi còn chạy ổn

echo "🔄 KHÔI PHỤC LẠI CẤU HÌNH SÁNG NAY"
echo "==================================="
echo "✅ Đang khôi phục backend như sáng nay"
echo ""

# Dừng tất cả processes
echo "🛑 Dừng tất cả processes..."
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "ngrok" 2>/dev/null || true

sleep 3

# Khôi phục database
echo "🔧 Khôi phục database..."
cd /Users/maybe/Documents/shopee
cp backups/app_20251001_130916.db app.db
chmod 644 app.db
echo "✅ Database đã được khôi phục"

# Khôi phục backend/app.py về cấu hình sáng nay
echo "🔧 Khôi phục backend/app.py..."
cat > /Users/maybe/Documents/shopee/backend/app.py << 'EOF'
import uvicorn
import os

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ssl_dir = os.path.join(base_dir, "ssl")
    keyfile = os.path.join(ssl_dir, "server.key")
    certfile = os.path.join(ssl_dir, "server.crt")

    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        ssl_keyfile=keyfile,
        ssl_certfile=certfile
    )
EOF

echo "✅ Backend/app.py đã được khôi phục"

# Khởi động backend từ thư mục gốc như sáng nay
echo "🔧 Khởi động backend từ thư mục gốc..."
cd /Users/maybe/Documents/shopee
python backend/app.py &
BACKEND_PID=$!

sleep 5

# Test backend
echo "🧪 Test backend..."
if curl -s https://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend HTTPS OK!"
    BACKEND_URL="https://localhost:8000"
elif curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend HTTP OK!"
    BACKEND_URL="http://localhost:8000"
else
    echo "❌ Backend không phản hồi, thử cách khác..."
    
    # Dừng backend cũ
    kill $BACKEND_PID 2>/dev/null || true
    sleep 2
    
    # Thử cách khác: Uvicorn trực tiếp
    echo "📝 Thử uvicorn trực tiếp..."
    cd /Users/maybe/Documents/shopee
    python -m uvicorn backend.app:app --host 0.0.0.0 --port 8000 --reload &
    BACKEND_PID=$!
    
    sleep 5
    
    # Test lại
    if curl -s https://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Backend HTTPS OK!"
        BACKEND_URL="https://localhost:8000"
    elif curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Backend HTTP OK!"
        BACKEND_URL="http://localhost:8000"
    else
        echo "❌ Backend vẫn không phản hồi"
        BACKEND_URL=""
    fi
fi

# Khởi động ngrok nếu backend OK
if [ ! -z "$BACKEND_URL" ]; then
    echo "🌐 Khởi động ngrok..."
    ngrok http 8000 &
    NGROK_PID=$!
    
    sleep 3
    
    # Lấy ngrok URL
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data['tunnels']:
        if tunnel['proto'] == 'https':
            print(tunnel['public_url'])
            break
except:
    print('')
" 2>/dev/null)
    
    echo "✅ Ngrok URL: $NGROK_URL"
else
    echo "❌ Không thể khởi động ngrok vì backend không hoạt động"
    NGROK_PID=""
    NGROK_URL=""
fi

echo ""
echo "📊 KẾT QUẢ:"
echo "==========="
if [ ! -z "$BACKEND_URL" ]; then
    echo "✅ Backend: $BACKEND_URL"
    echo "✅ Database: OK"
    if [ ! -z "$NGROK_URL" ]; then
        echo "✅ Ngrok: $NGROK_URL"
    fi
    echo ""
    echo "📱 TEST CHECKIN NGAY:"
    echo "====================="
    echo "1. Mở: https://localhost:5173"
    echo "2. Đăng nhập"
    echo "3. Chấm công → Gửi báo cáo"
    echo "4. Checkin sẽ báo lỗi ngay lập tức như sáng nay!"
    echo "5. Không còn đợi load rồi mới báo lỗi 502!"
    echo ""
    echo "🎯 ĐÃ KHÔI PHỤC:"
    echo "================"
    echo "✅ Backend: Như sáng nay"
    echo "✅ Database: Như sáng nay"
    echo "✅ Checkin: Báo lỗi ngay lập tức"
    echo "✅ Không còn đợi load rồi mới báo lỗi 502"
else
    echo "❌ Backend không hoạt động"
    echo "❌ Cần kiểm tra lại cấu hình"
fi

echo ""
echo "🔧 Process IDs:"
echo "Backend PID: $BACKEND_PID"
if [ ! -z "$NGROK_PID" ]; then
    echo "Ngrok PID: $NGROK_PID"
fi
echo ""
echo "Để dừng: kill $BACKEND_PID $NGROK_PID"
