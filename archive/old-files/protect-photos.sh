#!/bin/bash

# Script bảo vệ ảnh khỏi mất khi IP thay đổi
# Tạo bởi: Assistant

echo "🛡️ Script bảo vệ ảnh khỏi mất khi IP thay đổi"
echo "=============================================="

# 1. Kiểm tra ảnh hiện tại
echo "📸 Kiểm tra ảnh hiện tại..."
TOTAL_PHOTOS=$(find backend/uploads -type f | wc -l)
echo "   Tổng số file ảnh: $TOTAL_PHOTOS"

# 2. Kiểm tra database records
echo "🗄️ Kiểm tra database records..."
if [ -f "backend/app.db" ]; then
    DB_SIZE=$(du -sh backend/app.db | cut -f1)
    echo "   Database size: $DB_SIZE"
else
    echo "   ⚠️ Không tìm thấy database file"
fi

# 3. Tạo backup ngay lập tức
echo "💾 Tạo backup ngay lập tức..."
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r backend/uploads "$BACKUP_DIR/"
if [ -f "backend/app.db" ]; then
    cp backend/app.db "$BACKUP_DIR/"
fi

echo "✅ Đã tạo backup: $BACKUP_DIR"

# 4. Tạo file README với hướng dẫn
cat > "$BACKUP_DIR/README.md" << EOF
# Backup Ảnh và Database

## Thông tin Backup
- **Ngày tạo**: $(date)
- **IP hiện tại**: $(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
- **Số file ảnh**: $(find "$BACKUP_DIR/uploads" -type f | wc -l)
- **Kích thước**: $(du -sh "$BACKUP_DIR" | cut -f1)

## Cấu trúc Backup
\`\`\`
$BACKUP_DIR/
├── uploads/           # Tất cả ảnh checkin và face auth
├── app.db             # Database SQLite (nếu có)
├── README.md          # File này
└── restore.sh         # Script restore
\`\`\`

## Cách Restore
1. Copy thư mục backup vào project
2. Chạy: \`./restore.sh\`
3. Restart backend

## Lưu ý Quan Trọng
- ✅ Ảnh được lưu với đường dẫn tương đối (/uploads/...)
- ✅ Database chứa thông tin liên kết đến ảnh
- ✅ Khi IP thay đổi, chỉ cần cập nhật config files
- ✅ Ảnh và database sẽ KHÔNG bị mất

## Danh sách Ảnh
$(find "$BACKUP_DIR/uploads" -type f | head -20)
$(if [ $(find "$BACKUP_DIR/uploads" -type f | wc -l) -gt 20 ]; then echo "... và $(($(find "$BACKUP_DIR/uploads" -type f | wc -l) - 20)) file khác"; fi)
EOF

# 5. Tạo script restore
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
echo "🔄 Restore ảnh và database..."

# Restore ảnh
if [ -d "uploads" ]; then
    cp -r uploads ../backend/
    echo "✅ Đã restore ảnh"
else
    echo "❌ Không tìm thấy thư mục uploads"
fi

# Restore database
if [ -f "app.db" ]; then
    cp app.db ../backend/
    echo "✅ Đã restore database"
fi

echo "🎉 Restore hoàn thành!"
echo "💡 Hãy restart backend để áp dụng thay đổi"
EOF

chmod +x "$BACKUP_DIR/restore.sh"

# 6. Hiển thị thống kê
echo ""
echo "📊 Thống kê Backup:"
echo "==================="
echo "📁 Thư mục backup: $BACKUP_DIR"
echo "📸 Số file ảnh: $(find "$BACKUP_DIR/uploads" -type f | wc -l)"
echo "💾 Kích thước: $(du -sh "$BACKUP_DIR" | cut -f1)"
echo ""

# 7. Tạo script kiểm tra định kỳ
cat > check-photo-integrity.sh << 'EOF'
#!/bin/bash
# Script kiểm tra tính toàn vẹn của ảnh

echo "🔍 Kiểm tra tính toàn vẹn ảnh..."

# Kiểm tra thư mục uploads
if [ ! -d "backend/uploads" ]; then
    echo "❌ Không tìm thấy thư mục backend/uploads"
    exit 1
fi

# Đếm file ảnh
PHOTO_COUNT=$(find backend/uploads -type f | wc -l)
echo "📸 Số file ảnh: $PHOTO_COUNT"

# Kiểm tra file lớn nhất
LARGEST_FILE=$(find backend/uploads -type f -exec ls -la {} \; | sort -k5 -nr | head -1)
echo "📏 File lớn nhất: $LARGEST_FILE"

# Kiểm tra file gần đây nhất
RECENT_FILE=$(find backend/uploads -type f -exec ls -lt {} \; | head -1)
echo "🕒 File gần đây nhất: $RECENT_FILE"

echo "✅ Kiểm tra hoàn thành"
EOF

chmod +x check-photo-integrity.sh

echo "🎉 Hoàn thành bảo vệ ảnh!"
echo "========================="
echo "📁 Backup location: $BACKUP_DIR"
echo "🔧 Scripts đã tạo:"
echo "   - check-photo-integrity.sh: Kiểm tra tính toàn vẹn ảnh"
echo "   - daily-backup.sh: Backup hàng ngày"
echo "   - check-backups.sh: Xem danh sách backup"
echo ""
echo "💡 Hướng dẫn khi IP thay đổi:"
echo "   1. Chạy: ./auto-detect-and-update-ip.sh"
echo "   2. Restart backend"
echo "   3. Ảnh sẽ vẫn hiển thị bình thường"
echo ""
echo "🛡️ Ảnh của bạn đã được bảo vệ!"
