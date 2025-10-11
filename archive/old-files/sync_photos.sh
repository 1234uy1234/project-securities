#!/bin/bash

# Script để đồng bộ ảnh từ project root sang backend/uploads
# Chạy script này sau mỗi lần checkin để đảm bảo ảnh hiển thị được

echo "🔄 Đồng bộ ảnh từ project root sang backend/uploads..."

# Tạo thư mục backend/uploads nếu chưa có
mkdir -p /Users/maybe/Documents/shopee/backend/uploads

# Copy tất cả ảnh checkin từ project root sang backend/uploads
if [ -d "/Users/maybe/Documents/shopee/uploads" ]; then
    # Copy ảnh mới (chỉ copy nếu file ở backend/uploads nhỏ hơn hoặc không tồn tại)
    for file in /Users/maybe/Documents/shopee/uploads/checkin_*.jpg; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            backend_file="/Users/maybe/Documents/shopee/backend/uploads/$filename"
            
            # Chỉ copy nếu file backend nhỏ hơn hoặc không tồn tại
            if [ ! -f "$backend_file" ] || [ "$file" -nt "$backend_file" ]; then
                cp "$file" "$backend_file"
                echo "✅ Copied: $filename"
            fi
        fi
    done
    echo "🎉 Hoàn thành đồng bộ ảnh!"
else
    echo "❌ Không tìm thấy thư mục uploads trong project root"
fi
