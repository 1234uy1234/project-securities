#!/bin/bash

echo "🔄 Đồng bộ ảnh mới từ project root sang backend/uploads..."

SOURCE_DIR="/Users/maybe/Documents/shopee/uploads"
DEST_DIR="/Users/maybe/Documents/shopee/backend/uploads"

# Tạo thư mục đích nếu chưa có
mkdir -p "$DEST_DIR"

# Tìm tất cả ảnh checkin mới hơn 1 giờ
echo "🔍 Tìm ảnh checkin mới..."
find "$SOURCE_DIR" -name "checkin_*.jpg" -mmin -60 -exec basename {} \; | while read filename; do
    if [ ! -f "$DEST_DIR/$filename" ]; then
        echo "📸 Copying new photo: $filename"
        cp "$SOURCE_DIR/$filename" "$DEST_DIR/$filename"
    fi
done

echo "✅ Hoàn thành đồng bộ ảnh mới!"
