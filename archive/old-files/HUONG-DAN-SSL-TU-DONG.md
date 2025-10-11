# Hướng Dẫn Tự Động Cập Nhật SSL Certificate

## 🔐 Vấn Đề SSL

Khi IP máy tính thay đổi mỗi ngày, SSL certificate cũ sẽ không còn hợp lệ cho IP mới, dẫn đến:
- ❌ Trình duyệt báo "Trang không an toàn"
- ❌ Lỗi "NET::ERR_CERT_AUTHORITY_INVALID"
- ❌ Không thể truy cập ứng dụng

## 🚀 Giải Pháp Tự Động

Hệ thống sẽ **tự động cập nhật SSL certificate** mỗi khi IP thay đổi.

### 📋 Các Script SSL

#### 1. `update-ssl-cert.sh` - Cập nhật SSL thủ công
```bash
./update-ssl-cert.sh
```
- Tạo SSL certificate mới cho IP hiện tại
- Backup certificate cũ
- Kiểm tra certificate đã tạo thành công

#### 2. `setup-ssl-auto-update.sh` - Thiết lập tự động
```bash
./setup-ssl-auto-update.sh
```
- Cài đặt mkcert (nếu chưa có)
- Thiết lập cron job tự động
- Test hệ thống

#### 3. `daily-ip-update.sh` - Chạy tự động mỗi ngày
- Tự động phát hiện IP mới
- Cập nhật file cấu hình
- **Tạo SSL certificate mới**
- Khởi động lại ứng dụng

## ⚙️ Cài Đặt

### Bước 1: Thiết lập tự động
```bash
./setup-ssl-auto-update.sh
```

### Bước 2: Kiểm tra mkcert
```bash
# Kiểm tra mkcert đã cài đặt
mkcert -version

# Nếu chưa có, cài đặt:
brew install mkcert
mkcert -install
```

### Bước 3: Test thử
```bash
# Cập nhật SSL thủ công
./update-ssl-cert.sh

# Kiểm tra trạng thái
./check-ip.sh
```

## 🔄 Quy Trình Tự Động

### Mỗi ngày lúc 6:00 sáng:

1. **Phát hiện IP mới** (nếu có thay đổi)
2. **Backup certificate cũ** với timestamp
3. **Tạo certificate mới** cho IP hiện tại
4. **Cập nhật file cấu hình** (frontend, backend)
5. **Khởi động lại ứng dụng**
6. **Ghi log** chi tiết

### Certificate được tạo cho:
- ✅ IP hiện tại (ví dụ: localhost)
- ✅ localhost
- ✅ 127.0.0.1
- ✅ ::1 (IPv6 localhost)

## 📁 Cấu Trúc File

```
ssl/
├── server.crt                    # Certificate hiện tại
├── server.key                    # Private key hiện tại
├── server.crt.backup.YYYYMMDD_HHMMSS  # Backup certificate cũ
└── server.key.backup.YYYYMMDD_HHMMSS  # Backup private key cũ
```

## 🛠️ Xử Lý Sự Cố

### SSL vẫn báo "không an toàn"
```bash
# Kiểm tra certificate hiện tại
openssl x509 -in ssl/server.crt -text -noout | grep "Subject Alternative Name"

# Cập nhật SSL thủ công
./update-ssl-cert.sh

# Khởi động lại ứng dụng
./restart-app.sh
```

### mkcert chưa được cài đặt
```bash
# Cài đặt mkcert
brew install mkcert

# Cài đặt root certificate
mkcert -install

# Test tạo certificate
mkcert localhost 127.0.0.1 ::1
```

### Cron job không chạy
```bash
# Kiểm tra cron job
crontab -l

# Kiểm tra log
tail -f ip-update.log

# Chạy thủ công
./daily-ip-update.sh
```

## 📊 Monitoring

### Xem log tự động
```bash
tail -f ip-update.log
```

### Kiểm tra trạng thái
```bash
./check-ip.sh
```

### Kiểm tra certificate
```bash
# Xem thông tin certificate
openssl x509 -in ssl/server.crt -text -noout

# Kiểm tra IP trong certificate
openssl x509 -in ssl/server.crt -text -noout | grep "IP Address"
```

## 🎯 Lợi Ích

- ✅ **Không cần can thiệp thủ công** mỗi ngày
- ✅ **SSL certificate luôn hợp lệ** cho IP mới
- ✅ **Trình duyệt không báo lỗi** "không an toàn"
- ✅ **Backup tự động** certificate cũ
- ✅ **Log chi tiết** để theo dõi
- ✅ **Hoạt động 24/7** không cần giám sát

## 📞 Hỗ Trợ

Nếu gặp vấn đề, hãy chạy:
```bash
./check-ip.sh
```

Và gửi kết quả để được hỗ trợ.

---

**Từ giờ trở đi, SSL certificate sẽ tự động cập nhật mỗi ngày!** 🎉
