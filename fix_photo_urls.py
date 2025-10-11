#!/usr/bin/env python3
import os
import sys
sys.path.append('backend')

from backend.app.database import get_db
from backend.app.models import PatrolRecord
from sqlalchemy.orm import Session

def fix_photo_urls():
    """Sửa đường dẫn ảnh trong database để không phụ thuộc vào IP"""
    db = next(get_db())
    
    # Lấy tất cả records có photo_url
    records = db.query(PatrolRecord).filter(PatrolRecord.photo_url.isnot(None)).all()
    
    print(f"🔍 Tìm thấy {len(records)} records có ảnh")
    
    updated_count = 0
    for record in records:
        old_url = record.photo_url
        if old_url and old_url.startswith('/uploads/'):
            # Đường dẫn đã đúng, không cần sửa
            continue
        elif old_url and ('http://' in old_url or 'https://' in old_url):
            # Đường dẫn chứa IP, cần sửa
            # Tách phần đường dẫn sau domain
            if '/uploads/' in old_url:
                new_url = '/uploads/' + old_url.split('/uploads/')[1]
                record.photo_url = new_url
                updated_count += 1
                print(f"✅ Updated record {record.id}: {old_url} -> {new_url}")
    
    if updated_count > 0:
        db.commit()
        print(f"🎉 Đã cập nhật {updated_count} records")
    else:
        print("✅ Tất cả đường dẫn ảnh đã đúng")
    
    # Hiển thị danh sách ảnh hiện tại
    print("\n📋 Danh sách ảnh hiện tại:")
    records = db.query(PatrolRecord).filter(PatrolRecord.photo_url.isnot(None)).all()
    for record in records:
        print(f"  Record {record.id}: {record.photo_url}")

if __name__ == "__main__":
    fix_photo_urls()
