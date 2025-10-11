# QR Code Backup & Restore System

## 📋 Tổng quan

Hệ thống backup và restore QR codes để đảm bảo khi đổi IP backend/frontend, các QR codes vẫn có thể được khôi phục y nguyên.

## 🔧 Các script có sẵn

### 1. `auto_backup_qr.py` - Backup tự động
```bash
python3 auto_backup_qr.py
```
- Tự động backup tất cả QR codes từ database và files
- Tạo thư mục `qr_backup/qr_backup_YYYYMMDD_HHMMSS/`
- Lưu metadata và files QR code

### 2. `auto_restore_qr.py` - Restore tự động
```bash
# Restore từ backup mới nhất
python3 auto_restore_qr.py

# Restore từ backup cụ thể
python3 auto_restore_qr.py qr_backup/qr_backup_20250930_142224

# Liệt kê các backup có sẵn
python3 auto_restore_qr.py list
```

### 3. `qr_import_tool.py` - Import vào database
```bash
python3 qr_import_tool.py
```
- Import QR codes từ backup vào database
- Sử dụng API để tạo lại QR codes trong database

### 4. `qr_backup_tool.py` - Tool tương tác
```bash
python3 qr_backup_tool.py
```
- Menu tương tác để backup/restore
- Có thể chọn backup cụ thể

## 📁 Cấu trúc backup

```
qr_backup/
└── qr_backup_20250930_142224/
    ├── qr_codes_metadata.json    # Metadata từ database
    ├── restore_info.json         # Thông tin restore
    └── qr_files/                 # Files QR code
        ├── qr_static_1759216378.png
        ├── qr_static_1759200989.png
        └── ...
```

## 🚀 Quy trình khi đổi IP

### Bước 1: Backup trước khi đổi IP
```bash
python3 auto_backup_qr.py
```

### Bước 2: Sau khi đổi IP và setup lại backend
```bash
# Restore files
python3 auto_restore_qr.py

# Import vào database
python3 qr_import_tool.py
```

## 📊 Thông tin backup hiện tại

- **Tổng QR codes**: 7
- **Files đã backup**: 7
- **Backup time**: 2025-09-30T14:22:24
- **API base URL**: https://localhost:8000/api

## 🔍 Kiểm tra backup

```bash
# Xem danh sách backup
python3 auto_restore_qr.py list

# Xem metadata
cat qr_backup/qr_backup_20250930_142224/qr_codes_metadata.json

# Xem restore info
cat qr_backup/qr_backup_20250930_142224/restore_info.json
```

## ⚠️ Lưu ý

1. **Backup định kỳ**: Chạy backup sau mỗi lần tạo QR code mới
2. **Files vs Database**: Backup bao gồm cả files và metadata database
3. **Import sau restore**: Sau khi restore files, cần import vào database
4. **IP thay đổi**: Cập nhật `api_base_url` trong scripts nếu cần

## 🎯 QR Codes hiện có

| ID | Data | Type | Created |
|----|------|------|---------|
| 7 | Test QR Code | static | 2025-09-30T14:12:58 |
| 6 | nhà đi chơi | static | 2025-09-30T09:56:29 |
| 5 | abcd | static | 2025-09-30T09:30:57 |
| 4 | nhà xe | static | 2025-09-30T09:06:24 |
| 3 | test from frontend | static | 2025-09-30T09:00:37 |
| 2 | test | static | 2025-09-30T09:00:02 |
| 1 | nhà ăn | static | 2025-09-30T08:59:09 |

## 🔧 Troubleshooting

### Lỗi đăng nhập
- Kiểm tra username/password trong script
- Kiểm tra API base URL

### Files không tồn tại
- Kiểm tra đường dẫn `backend/uploads/qr_codes/`
- Đảm bảo backend đã tạo files QR code

### Import lỗi
- Kiểm tra API endpoint `/qr-codes/generate-simple`
- Kiểm tra token authentication
