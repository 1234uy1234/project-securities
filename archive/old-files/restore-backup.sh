#!/bin/bash
# Script restore backup

BACKUP_DIR="$1"
if [ -z "$BACKUP_DIR" ]; then
    echo "Sử dụng: $0 <backup_directory>"
    exit 1
fi

echo "🔄 Restore backup từ: $BACKUP_DIR"

# Restore ảnh
if [ -d "$BACKUP_DIR/uploads" ]; then
    cp -r "$BACKUP_DIR/uploads" "/Users/maybe/Documents/shopee/backend/"
    echo "✅ Đã restore ảnh"
else
    echo "❌ Không tìm thấy thư mục uploads trong backup"
fi

# Restore database
if [ -f "$BACKUP_DIR/app.db" ]; then
    cp "$BACKUP_DIR/app.db" "/Users/maybe/Documents/shopee/backend/"
    echo "✅ Đã restore database"
else
    echo "❌ Không tìm thấy database trong backup"
fi

echo "🎉 Restore hoàn tất!"
echo "💡 Hãy restart backend để áp dụng thay đổi"
