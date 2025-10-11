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
