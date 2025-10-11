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
