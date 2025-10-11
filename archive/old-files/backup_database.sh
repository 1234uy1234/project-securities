#!/bin/bash

echo "=== BACKUP SQLITE DATABASE ==="
echo "📅 $(date)"
echo ""

# Tạo thư mục backup nếu chưa có
mkdir -p /Users/maybe/Documents/shopee/backups

# Backup SQLite database
BACKUP_FILE="/Users/maybe/Documents/shopee/backups/app_$(date +%Y%m%d_%H%M%S).db"
cp /Users/maybe/Documents/shopee/backend/app.db "$BACKUP_FILE"

echo "✅ Database backed up to: $BACKUP_FILE"
echo "📊 Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
echo ""

# Liệt kê các backup gần đây
echo "📋 Recent backups:"
ls -la /Users/maybe/Documents/shopee/backups/ | tail -5
echo ""

# Tạo script restore
cat > /Users/maybe/Documents/shopee/restore_database.sh << 'EOF'
#!/bin/bash

echo "=== RESTORE DATABASE ==="
echo "Available backups:"
ls -la /Users/maybe/Documents/shopee/backups/

echo ""
echo "Enter backup filename to restore:"
read BACKUP_FILE

if [ -f "/Users/maybe/Documents/shopee/backups/$BACKUP_FILE" ]; then
    cp "/Users/maybe/Documents/shopee/backups/$BACKUP_FILE" /Users/maybe/Documents/shopee/backend/app.db
    echo "✅ Database restored from: $BACKUP_FILE"
else
    echo "❌ Backup file not found: $BACKUP_FILE"
fi
EOF

chmod +x /Users/maybe/Documents/shopee/restore_database.sh

echo "✅ Restore script created: restore_database.sh"
echo ""
echo "💡 Để restore database, chạy: ./restore_database.sh"
