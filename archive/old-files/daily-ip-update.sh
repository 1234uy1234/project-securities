#!/bin/bash

# Script chạy tự động mỗi ngày để cập nhật IP
# Script này được thiết kế để chạy qua cron job

echo "🕐 $(date): Bắt đầu cập nhật IP hàng ngày..."

# Chuyển đến thư mục dự án
cd "$(dirname "$0")"

# Lấy IP hiện tại
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

if [ -z "$CURRENT_IP" ]; then
    echo "❌ $(date): Không thể lấy được IP hiện tại!"
    exit 1
fi

# Kiểm tra xem IP có thay đổi không
LAST_IP_FILE=".last_ip"
if [ -f "$LAST_IP_FILE" ]; then
    LAST_IP=$(cat "$LAST_IP_FILE")
    if [ "$CURRENT_IP" = "$LAST_IP" ]; then
        echo "✅ $(date): IP không thay đổi ($CURRENT_IP), không cần cập nhật"
        exit 0
    fi
fi

echo "🔄 $(date): IP đã thay đổi từ $LAST_IP thành $CURRENT_IP"

# Chạy script cập nhật IP
./auto-update-ip.sh

if [ $? -eq 0 ]; then
    # Lưu IP hiện tại
    echo "$CURRENT_IP" > "$LAST_IP_FILE"
    
    # Cập nhật SSL certificate cho IP mới
    echo "🔐 $(date): Cập nhật SSL certificate cho IP mới..."
    ./update-ssl-cert.sh
    
    if [ $? -eq 0 ]; then
        # Khởi động lại ứng dụng
        echo "🚀 $(date): Khởi động lại ứng dụng..."
        ./restart-app.sh
        
        echo "✅ $(date): Cập nhật IP và SSL thành công, đã khởi động lại ứng dụng"
    else
        echo "❌ $(date): Lỗi khi cập nhật SSL certificate"
        exit 1
    fi
else
    echo "❌ $(date): Lỗi khi cập nhật IP"
    exit 1
fi