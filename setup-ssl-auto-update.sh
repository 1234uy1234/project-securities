#!/bin/bash

# Script thiết lập tự động cập nhật SSL certificate mỗi ngày
echo "🔐 Thiết lập tự động cập nhật SSL certificate..."

# Chuyển đến thư mục dự án
cd "$(dirname "$0")"

# Cấp quyền thực thi cho các script
echo "📝 Cấp quyền thực thi cho các script..."
chmod +x update-ssl-cert.sh
chmod +x daily-ip-update.sh
chmod +x auto-update-ip.sh
chmod +x restart-app.sh
chmod +x check-ip.sh
echo "✅ Đã cấp quyền thực thi"

# Kiểm tra mkcert       
echo "🔍 Kiểm tra mkcert..."
if ! command -v mkcert &> /dev/null; then
    echo "⚠️  mkcert chưa được cài đặt. Cài đặt mkcert..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install mkcert
            mkcert -install
        else
            echo "❌ Homebrew chưa được cài đặt. Vui lòng cài đặt mkcert thủ công."
            echo "   Tải từ: https://github.com/FiloSottile/mkcert/releases"
            exit 1
        fi
    else
        echo "❌ Hệ điều hành không được hỗ trợ tự động. Vui lòng cài đặt mkcert thủ công."
        echo "   Tải từ: https://github.com/FiloSottile/mkcert/releases"
        exit 1
    fi
else
    echo "✅ mkcert đã được cài đặt"
fi

# Tạo thư mục ssl nếu chưa có
if [ ! -d "ssl" ]; then
    echo "📁 Tạo thư mục ssl..."
    mkdir -p ssl
fi

# Thiết lập cron job để cập nhật IP và SSL mỗi ngày
echo "⏰ Thiết lập cron job..."

# Lấy đường dẫn tuyệt đối của script
SCRIPT_PATH="$(pwd)/daily-ip-update.sh"
LOG_PATH="$(pwd)/ip-update.log"

# Tạo cron job entry - chạy mỗi ngày lúc 6:00 sáng
CRON_ENTRY="0 6 * * * $SCRIPT_PATH >> $LOG_PATH 2>&1"

# Kiểm tra xem cron job đã tồn tại chưa
if crontab -l 2>/dev/null | grep -q "daily-ip-update.sh"; then
    echo "⚠️  Cron job đã tồn tại"
else
    # Thêm cron job
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    echo "✅ Đã thêm cron job: chạy mỗi ngày lúc 6:00 sáng"
fi

# Tạo file log
touch "$LOG_PATH"
echo "📝 Đã tạo file log: $LOG_PATH"

# Test script cập nhật SSL
echo "🧪 Test script cập nhật SSL..."
./update-ssl-cert.sh

echo ""
echo "🎉 Thiết lập hoàn tất!"
echo ""
echo "📋 Hệ thống sẽ tự động:"
echo "  - Phát hiện IP mới mỗi ngày lúc 6:00 sáng"
echo "  - Cập nhật tất cả file cấu hình"
echo "  - Tạo SSL certificate mới cho IP mới"
echo "  - Khởi động lại ứng dụng"
echo ""
echo "🔧 Các script có sẵn:"
echo "  - ./update-ssl-cert.sh     : Cập nhật SSL certificate thủ công"
echo "  - ./daily-ip-update.sh     : Cập nhật IP và SSL tự động"
echo "  - ./check-ip.sh            : Kiểm tra IP và trạng thái"
echo "  - ./manual-update-ip.sh    : Menu cập nhật thủ công"
echo ""
echo "📊 Để xem log tự động:"
echo "  tail -f ip-update.log"
echo ""
echo "🔍 Để kiểm tra cron job:"
echo "  crontab -l"
