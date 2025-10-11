#!/bin/bash

echo "=== SETUP AUTO BACKUP ==="
echo ""

# Tạo cron job để backup hàng ngày lúc 2:00 AM
CRON_JOB="0 2 * * * cd /Users/maybe/Documents/shopee && ./backup_database.sh >> /Users/maybe/Documents/shopee/backups/backup.log 2>&1"

# Thêm vào crontab
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "✅ Auto backup scheduled daily at 2:00 AM"
echo "📋 Cron job added: $CRON_JOB"
echo ""

# Tạo script để xem backup logs
cat > /Users/maybe/Documents/shopee/view_backup_logs.sh << 'EOF'
#!/bin/bash

echo "=== BACKUP LOGS ==="
echo ""

if [ -f "/Users/maybe/Documents/shopee/backups/backup.log" ]; then
    echo "📋 Recent backup logs:"
    tail -20 /Users/maybe/Documents/shopee/backups/backup.log
else
    echo "📋 No backup logs found yet"
fi

echo ""
echo "📊 Backup directory contents:"
ls -la /Users/maybe/Documents/shopee/backups/
EOF

chmod +x /Users/maybe/Documents/shopee/view_backup_logs.sh

echo "✅ Backup log viewer created: view_backup_logs.sh"
echo ""
echo "💡 Commands:"
echo "   - View backup logs: ./view_backup_logs.sh"
echo "   - Manual backup: ./backup_database.sh"
echo "   - Restore database: ./restore_database.sh"
echo "   - View cron jobs: crontab -l"
