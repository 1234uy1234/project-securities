# 🛡️ BACKUP ẢNH VÀ DATABASE

## 📅 Thông tin Backup
- **Ngày tạo**: Wed Oct  8 08:37:43 +07 2025
- **Tổng số ảnh**:        2
- **Kích thước ảnh**: 148K
- **Records có ảnh**: 2
- **Kích thước database**:  52K

## 📁 Cấu trúc Backup
```
backup_photos_20251008_083743/
├── uploads/           # Tất cả ảnh checkin
│   ├── checkin_*.jpg  # Ảnh chấm công
│   └── qr_codes/      # QR codes
├── app.db             # Database SQLite
└── README.md          # File này
```

## 🔄 Cách Restore
1. Copy thư mục backup vào project
2. Chạy: `./restore-backup.sh backup_photos_20251008_083743`
3. Restart backend

## ⚠️ Lưu ý Quan Trọng
- ✅ Ảnh được lưu với đường dẫn tương đối (/uploads/...)
- ✅ Database chứa thông tin liên kết đến ảnh
- ✅ Khi IP thay đổi, chỉ cần cập nhật config files
- ✅ Ảnh và database sẽ KHÔNG bị mất

## 📋 Danh sách Ảnh
checkin_12_20251008_082554.jpg
checkin_13_20251007_155226.jpg
