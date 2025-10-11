#!/bin/bash
# Script tự động backup hàng ngày

# Chạy backup
./backup-photos-system.sh

# Xóa backup cũ (giữ lại 7 ngày)
find . -name "backup_photos_*" -type d -mtime +7 -exec rm -rf {} \;

echo "🧹 Đã xóa backup cũ hơn 7 ngày"
