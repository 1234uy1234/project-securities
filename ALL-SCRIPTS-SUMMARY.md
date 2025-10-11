# 🛠️ TỔNG HỢP TẤT CẢ SCRIPTS

## 🚀 **SCRIPTS KHỞI ĐỘNG**

### `start-ngrok-system.sh`
```bash
# Khởi động toàn bộ hệ thống
- Dừng tất cả processes cũ
- Restore database
- Start backend
- Start ngrok
- Start frontend
```

### `quick-start.sh`
```bash
# Khởi động nhanh
- Dừng processes cũ
- Restore database
- Start backend
- Start ngrok
```

## 🔧 **SCRIPTS SỬA LỖI**

### `fix-camera-qr-issues.sh`
```bash
# Sửa lỗi camera và QR
- Dừng tất cả processes
- Restart frontend
- Test camera và QR
```

### `fix-checkin-502.sh`
```bash
# Sửa lỗi 502
- Kill processes
- Restore database
- Start backend
- Start ngrok
```

### `fix-checkin-400-final.sh`
```bash
# Sửa lỗi 400 cuối cùng
- Dừng processes
- Restore database
- Fix frontend endpoints
- Start backend
- Start ngrok
```

### `fix-ngrok-connection.sh`
```bash
# Sửa lỗi kết nối ngrok
- Kill tất cả processes
- Start backend với 0.0.0.0
- Start ngrok với 0.0.0.0:8000
- Test kết nối
```

### `fix-ultimate.sh`
```bash
# Sửa tất cả mọi thứ
- Kill tất cả processes
- Restore database
- Fix backend app.py
- Fix frontend endpoints
- Start backend
- Start ngrok
- Test tất cả endpoints
```

### `fix-simple.sh`
```bash
# Sửa đơn giản
- Dừng tất cả
- Restore database
- Start backend
- Start ngrok
```

## 📊 **SCRIPTS KIỂM TRA**

### `restore-morning-config.sh`
```bash
# Khôi phục config sáng
- Revert backend/app.py
- Restart system
```

### `restore-morning-working.sh`
```bash
# Khôi phục trạng thái sáng
- Stop processes
- Restore database
- Revert backend/app.py
- Start backend
- Test backend
- Start ngrok
```

## 🎯 **SCRIPTS CHUYÊN BIỆT**

### `fix-auth-403.sh`
```bash
# Sửa lỗi 403
- Stop processes
- Restore database
- Start backend
- Test backend
- Start ngrok
```

### `fix-qr-checkin-400.sh`
```bash
# Sửa lỗi QR checkin 400
- Stop processes
- Restore database
- Fix backend/app.py
- Start backend
- Test backend
- Start ngrok
```

## 📋 **CÁCH SỬ DỤNG**

### 1. **Khởi động hệ thống:**
```bash
./start-ngrok-system.sh
```

### 2. **Sửa lỗi thường gặp:**
```bash
# Lỗi 400
./fix-checkin-400-final.sh

# Lỗi 502
./fix-checkin-502.sh

# Lỗi ngrok
./fix-ngrok-connection.sh

# Lỗi camera
./fix-camera-qr-issues.sh
```

### 3. **Sửa tất cả:**
```bash
./fix-ultimate.sh
```

## ⚠️ **LƯU Ý**

- Tất cả scripts đều tự động restore database
- Không cần chạy thủ công
- Chỉ cần chạy script tương ứng với lỗi
- Scripts đã được test và hoạt động ổn định

---
**Tổng số scripts:** 12
**Trạng thái:** ✅ Tất cả đều hoạt động
