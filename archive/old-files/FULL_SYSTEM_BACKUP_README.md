# Hệ Thống Backup & Restore Toàn Diện

## 🎯 Tổng quan

Hệ thống backup và restore toàn diện để đảm bảo khi đổi IP backend/frontend, **TẤT CẢ** dữ liệu đều được bảo toàn:

- ✅ **QR Codes** (7 codes)
- ✅ **Ảnh chấm công** (49 files)  
- ✅ **Patrol Records** (6 records)
- ✅ **Patrol Tasks** (5 tasks)
- ✅ **Locations** (32 locations)
- ✅ **Users** (3 users)
- ✅ **Face Data** (9 face images)
- ✅ **Tất cả files uploads** (83 files, 3.04 MB)

## 🚀 Cách sử dụng đơn giản

### 1. Backup toàn bộ hệ thống
```bash
python3 backup.py
```

### 2. Xem trạng thái backup
```bash
python3 backup.py status
```

### 3. Restore từ backup
```bash
python3 backup.py restore full_system_backup/full_backup_20250930_142904
```

## 📊 Backup hiện tại

- **Thời gian**: 2025-09-30T14:29:04
- **QR codes**: 7
- **Patrol records**: 6  
- **Tasks**: 5
- **Locations**: 32
- **Users**: 3
- **Files**: 83 files (3.04 MB)

## 🔧 Scripts chi tiết

### `backup.py` - Script chính
- Backup toàn diện với 1 lệnh
- Hiển thị trạng thái backup
- Restore từ backup

### `full_system_backup.py` - Backup engine
- Backup database qua API
- Backup tất cả files uploads
- Tạo metadata và restore info

### `restore_full_system.py` - Restore engine  
- Restore files từ backup
- Import database data qua API
- Khôi phục hoàn toàn hệ thống

## 📁 Cấu trúc backup

```
full_system_backup/
└── full_backup_20250930_142904/
    ├── backup_info.json          # Thông tin backup
    ├── database_data.json        # Tất cả dữ liệu database
    └── uploads/                  # Tất cả files
        ├── checkin_*.jpg         # Ảnh chấm công
        ├── qr_codes/            # QR code images
        ├── faces/               # Face data
        └── test_*.jpg           # Test images
```

## 🔄 Quy trình khi đổi IP

### Bước 1: Backup trước khi đổi IP
```bash
python3 backup.py
```

### Bước 2: Sau khi đổi IP và setup lại backend
```bash
# Restore toàn bộ hệ thống
python3 backup.py restore full_system_backup/full_backup_20250930_142904

# Hoặc restore thủ công
python3 restore_full_system.py full_system_backup/full_backup_20250930_142904
```

### Bước 3: Cập nhật frontend (nếu cần)
```bash
# Sửa API base URL trong frontend/src/utils/api.ts
# Từ: https://localhost:8000/api
# Thành: https://IP_MỚI:8000/api
```

### Bước 4: Restart backend
```bash
# Restart backend server
```

## 📋 Danh sách dữ liệu được backup

### QR Codes (7)
| ID | Data | Type | Created |
|----|------|------|---------|
| 7 | Test QR Code | static | 2025-09-30T14:12:58 |
| 6 | nhà đi chơi | static | 2025-09-30T09:56:29 |
| 5 | abcd | static | 2025-09-30T09:30:57 |
| 4 | nhà xe | static | 2025-09-30T09:06:24 |
| 3 | test from frontend | static | 2025-09-30T09:00:37 |
| 2 | test | static | 2025-09-30T09:00:02 |
| 1 | nhà ăn | static | 2025-09-30T08:59:09 |

### Patrol Records (6)
| ID | Photo | Check-in Time |
|----|-------|---------------|
| 20 | checkin_3_20250930_141521.jpg | 2025-09-30T21:15:21 |
| 18 | checkin_2_20250930_131103.jpg | 2025-09-30T20:11:03 |
| 17 | checkin_1_20250930_103849.jpg | 2025-09-30T18:30:19 |
| 8 | checkin_2_20250930_103131.jpg | 2025-09-30T17:31:31 |
| 9 | checkin_1_20250930_102740.jpg | 2025-09-30T17:27:41 |

### Files được backup (83 files)
- **Ảnh chấm công**: 49 files
- **QR codes**: 32 files  
- **Face data**: 9 files
- **Test images**: 3 files

## ⚠️ Lưu ý quan trọng

1. **Backup định kỳ**: Chạy backup sau mỗi lần có dữ liệu mới
2. **Files vs Database**: Backup bao gồm cả files và database
3. **API endpoints**: Restore sử dụng API để tạo lại dữ liệu
4. **IP thay đổi**: Cập nhật API base URL trong frontend
5. **Permissions**: Đảm bảo có quyền đọc/ghi files

## 🔍 Troubleshooting

### Lỗi đăng nhập
- Kiểm tra username/password trong script
- Kiểm tra API base URL
- Kiểm tra backend có chạy không

### Files không tồn tại
- Kiểm tra đường dẫn `backend/uploads/`
- Đảm bảo có quyền đọc files

### Restore lỗi
- Kiểm tra API endpoints
- Kiểm tra token authentication
- Kiểm tra database connection

## 🎉 Kết quả

**Khi đổi IP, bạn sẽ có:**
- ✅ Tất cả QR codes y nguyên
- ✅ Tất cả ảnh chấm công y nguyên  
- ✅ Tất cả tasks và reports y nguyên
- ✅ Tất cả face data y nguyên
- ✅ Không mất dữ liệu gì cả!

**Chỉ cần chạy 1 lệnh để backup, 1 lệnh để restore!**
