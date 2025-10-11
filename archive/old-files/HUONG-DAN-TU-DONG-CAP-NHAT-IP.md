# Hướng Dẫn Tự Động Cập Nhật IP

## 📋 Tổng Quan

Hệ thống này giúp bạn tự động cập nhật địa chỉ IP trong tất cả các file cấu hình khi IP máy tính thay đổi, thường xảy ra mỗi ngày.

## 🚀 Các Script Có Sẵn

### 1. `auto-update-ip.sh` - Cập nhật IP tự động
- **Chức năng**: Cập nhật IP trong tất cả file cấu hình
- **Cách dùng**: `./auto-update-ip.sh`
- **Cập nhật**: frontend/config.js, backend/app/config.py, SSL certificate, docker-compose.yml

### 2. `daily-ip-update.sh` - Chạy tự động mỗi ngày
- **Chức năng**: Kiểm tra IP thay đổi và cập nhật tự động
- **Cách dùng**: Chạy qua cron job
- **Tính năng**: Chỉ cập nhật khi IP thực sự thay đổi

### 3. `manual-update-ip.sh` - Cập nhật thủ công
- **Chức năng**: Menu tương tác để cập nhật IP
- **Cách dùng**: `./manual-update-ip.sh`
- **Tùy chọn**: Cập nhật IP, khởi động lại app, kiểm tra IP

### 4. `restart-app.sh` - Khởi động lại ứng dụng
- **Chức năng**: Dừng và khởi động lại toàn bộ ứng dụng
- **Cách dùng**: `./restart-app.sh`

### 5. `check-ip.sh` - Kiểm tra trạng thái
- **Chức năng**: Kiểm tra IP hiện tại và trạng thái ứng dụng
- **Cách dùng**: `./check-ip.sh`

## ⚙️ Cài Đặt Tự Động

### Bước 1: Cấp quyền thực thi cho các script
```bash
chmod +x auto-update-ip.sh
chmod +x daily-ip-update.sh
chmod +x manual-update-ip.sh
chmod +x restart-app.sh
chmod +x check-ip.sh
```

### Bước 2: Thiết lập cron job để chạy tự động mỗi ngày
```bash
# Mở crontab
crontab -e

# Thêm dòng sau để chạy mỗi ngày lúc 6:00 sáng
0 6 * * * /Users/maybe/Documents/shopee/daily-ip-update.sh >> /Users/maybe/Documents/shopee/ip-update.log 2>&1

# Hoặc chạy mỗi 30 phút để kiểm tra IP
*/30 * * * * /Users/maybe/Documents/shopee/daily-ip-update.sh >> /Users/maybe/Documents/shopee/ip-update.log 2>&1
```

### Bước 3: Kiểm tra cron job đã được thêm
```bash
crontab -l
```

## 📖 Cách Sử Dụng Hàng Ngày

### Tự Động (Khuyến nghị)
- Hệ thống sẽ tự động kiểm tra và cập nhật IP mỗi ngày
- Không cần làm gì thêm, chỉ cần đảm bảo máy tính đang chạy

### Thủ Công (Khi cần)
1. **Kiểm tra IP hiện tại**:
   ```bash
   ./check-ip.sh
   ```

2. **Cập nhật IP thủ công**:
   ```bash
   ./manual-update-ip.sh
   ```

3. **Chỉ khởi động lại ứng dụng**:
   ```bash
   ./restart-app.sh
   ```

## 🔧 Xử Lý Sự Cố

### IP không được cập nhật
```bash
# Kiểm tra log
tail -f ip-update.log

# Chạy cập nhật thủ công
./manual-update-ip.sh
```

### Ứng dụng không khởi động
```bash
# Kiểm tra trạng thái
./check-ip.sh

# Khởi động lại
./restart-app.sh
```

### Cron job không chạy
```bash
# Kiểm tra cron service
sudo launchctl list | grep cron

# Khởi động cron service
sudo launchctl start com.apple.cron

# Kiểm tra log system
log show --predicate 'process == "cron"' --last 1h
```

## 📁 File Backup

Hệ thống tự động tạo backup các file cấu hình trước khi cập nhật:
- `frontend/config.js.backup.YYYYMMDD_HHMMSS`
- `backend/app/config.py.backup.YYYYMMDD_HHMMSS`

## 🎯 Lưu Ý Quan Trọng

1. **Đảm bảo mkcert đã được cài đặt** để tạo SSL certificate
2. **Kiểm tra quyền truy cập** vào các file cấu hình
3. **Backup dữ liệu** trước khi cài đặt lần đầu
4. **Test thử** trên môi trường development trước khi áp dụng production

## 📞 Hỗ Trợ

Nếu gặp vấn đề, hãy chạy:
```bash
./check-ip.sh
```

Và gửi kết quả để được hỗ trợ.
