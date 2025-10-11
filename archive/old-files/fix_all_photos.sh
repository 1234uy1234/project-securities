#!/bin/bash

echo "🔧 Sửa tất cả ảnh checkin để hiển thị tự động..."

# Source and destination directories
SOURCE_DIR="/Users/maybe/Documents/shopee/uploads"
DEST_DIR="/Users/maybe/Documents/shopee/backend/uploads"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

echo "📁 Copying all photos from $SOURCE_DIR to $DEST_DIR..."

# Copy all files from source to destination
if [ -d "$SOURCE_DIR" ]; then
    for file in "$SOURCE_DIR"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" "$DEST_DIR/$filename"
            echo "✅ Copied: $filename"
        fi
    done
    echo "🎉 Hoàn thành! Tất cả ảnh đã được copy sang backend/uploads"
    echo "📊 Số lượng ảnh trong backend/uploads:"
    ls -1 "$DEST_DIR" | wc -l
else
    echo "❌ Source directory $SOURCE_DIR not found"
fi

echo "✅ XONG! Bây giờ tất cả ảnh sẽ tự động hiển thị trên trang Reports!"
