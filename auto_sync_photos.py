#!/usr/bin/env python3

import os
import time
import shutil
from pathlib import Path

def sync_photos():
    """Tự động đồng bộ ảnh từ project root sang backend/uploads"""
    source_dir = Path("/Users/maybe/Documents/shopee/uploads")
    dest_dir = Path("/Users/maybe/Documents/shopee/backend/uploads")
    
    # Tạo thư mục đích nếu chưa có
    dest_dir.mkdir(parents=True, exist_ok=True)
    
    # Tìm tất cả ảnh checkin
    checkin_photos = list(source_dir.glob("checkin_*.jpg"))
    
    synced_count = 0
    for photo in checkin_photos:
        dest_file = dest_dir / photo.name
        if not dest_file.exists() or photo.stat().st_mtime > dest_file.stat().st_mtime:
            shutil.copy2(photo, dest_file)
            print(f"✅ Synced: {photo.name}")
            synced_count += 1
    
    if synced_count > 0:
        print(f"🔄 Synced {synced_count} new photos")
    else:
        print("✅ All photos are up to date")

if __name__ == "__main__":
    sync_photos()
