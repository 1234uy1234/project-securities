#!/bin/bash

# 🛡️ HỆ THỐNG BACKUP ẢNH TỰ ĐỘNG
# Tạo bởi: Assistant
# Mục đích: Đảm bảo ảnh checkin không bị mất

echo "🛡️ HỆ THỐNG BACKUP ẢNH TỰ ĐỘNG"
echo "================================="

# 1. Kiểm tra thư mục uploads
echo "📸 Kiểm tra thư mục uploads..."
UPLOADS_DIR="/Users/maybe/Documents/shopee/backend/uploads"
if [ -d "$UPLOADS_DIR" ]; then
    TOTAL_PHOTOS=$(find "$UPLOADS_DIR" -type f -name "*.jpg" | wc -l)
    TOTAL_SIZE=$(du -sh "$UPLOADS_DIR" | cut -f1)
    echo "   ✅ Thư mục tồn tại: $UPLOADS_DIR"
    echo "   📊 Tổng số ảnh: $TOTAL_PHOTOS"
    echo "   💾 Kích thước: $TOTAL_SIZE"
else
    echo "   ❌ Thư mục uploads không tồn tại!"
    exit 1
fi

# 2. Kiểm tra database
echo "🗄️ Kiểm tra database..."
DB_FILE="/Users/maybe/Documents/shopee/backend/app.db"
if [ -f "$DB_FILE" ]; then
    DB_SIZE=$(du -sh "$DB_FILE" | cut -f1)
    echo "   ✅ Database tồn tại: $DB_FILE"
    echo "   💾 Kích thước: $DB_SIZE"
    
    # Đếm records có ảnh
    RECORDS_WITH_PHOTOS=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM patrol_records WHERE photo_path IS NOT NULL;")
    echo "   📋 Records có ảnh: $RECORDS_WITH_PHOTOS"
else
    echo "   ❌ Database không tồn tại!"
    exit 1
fi

# 3. Tạo backup
echo "💾 Tạo backup..."
BACKUP_DIR="backup_photos_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup ảnh
cp -r "$UPLOADS_DIR" "$BACKUP_DIR/"
echo "   ✅ Đã backup ảnh vào: $BACKUP_DIR/uploads/"

# Backup database
cp "$DB_FILE" "$BACKUP_DIR/"
echo "   ✅ Đã backup database vào: $BACKUP_DIR/app.db"

# 4. Tạo file README
cat > "$BACKUP_DIR/README.md" << EOF
# 🛡️ BACKUP ẢNH VÀ DATABASE

## 📅 Thông tin Backup
- **Ngày tạo**: $(date)
- **Tổng số ảnh**: $TOTAL_PHOTOS
- **Kích thước ảnh**: $TOTAL_SIZE
- **Records có ảnh**: $RECORDS_WITH_PHOTOS
- **Kích thước database**: $DB_SIZE

## 📁 Cấu trúc Backup
\`\`\`
$BACKUP_DIR/
├── uploads/           # Tất cả ảnh checkin
│   ├── checkin_*.jpg  # Ảnh chấm công
│   └── qr_codes/      # QR codes
├── app.db             # Database SQLite
└── README.md          # File này
\`\`\`

## 🔄 Cách Restore
1. Copy thư mục backup vào project
2. Chạy: \`./restore-backup.sh $BACKUP_DIR\`
3. Restart backend

## ⚠️ Lưu ý Quan Trọng
- ✅ Ảnh được lưu với đường dẫn tương đối (/uploads/...)
- ✅ Database chứa thông tin liên kết đến ảnh
- ✅ Khi IP thay đổi, chỉ cần cập nhật config files
- ✅ Ảnh và database sẽ KHÔNG bị mất

## 📋 Danh sách Ảnh
EOF

# Thêm danh sách ảnh vào README
find "$UPLOADS_DIR" -name "*.jpg" -exec basename {} \; | sort >> "$BACKUP_DIR/README.md"

# 5. Tạo script restore
cat > "$BACKUP_DIR/restore-backup.sh" << 'EOF'
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
EOF

chmod +x "$BACKUP_DIR/restore-backup.sh"

# 6. Tạo script auto-backup
cat > "auto-backup-photos.sh" << EOF
#!/bin/bash
# Script tự động backup hàng ngày

# Chạy backup
./backup-photos-system.sh

# Xóa backup cũ (giữ lại 7 ngày)
find . -name "backup_photos_*" -type d -mtime +7 -exec rm -rf {} \;

echo "🧹 Đã xóa backup cũ hơn 7 ngày"
EOF

chmod +x "auto-backup-photos.sh"

echo ""
echo "🎉 HOÀN TẤT BACKUP!"
echo "📁 Backup được lưu tại: $BACKUP_DIR"
echo "📋 Tổng số ảnh: $TOTAL_PHOTOS"
echo "💾 Kích thước: $TOTAL_SIZE"
echo ""
echo "🔄 Để restore: ./$BACKUP_DIR/restore-backup.sh"
echo "⏰ Để auto-backup: ./auto-backup-photos.sh"
echo ""
echo "✅ HỆ THỐNG BACKUP ĐÃ SẴN SÀNG!"
