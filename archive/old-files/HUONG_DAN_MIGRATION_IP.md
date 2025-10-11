# 🚀 HƯỚNG DẪN MIGRATION HỆ THỐNG SANG IP MỚI

## 📋 Tổng quan

Hệ thống MANHTOAN PLASTIC PWA đã được chuẩn bị sẵn các script tự động để migration sang IP mới. Quá trình này bao gồm:

- ✅ Cập nhật frontend, backend, API config
- ✅ Backup và migrate dữ liệu
- ✅ Cập nhật cron jobs
- ✅ Tạo QR codes mới
- ✅ Restart services
- ✅ Test hệ thống

## 🎯 Các Script có sẵn

### 1. `complete_migration.py` - Script tổng hợp (KHUYẾN NGHỊ)
```bash
python3 complete_migration.py NEW_IP
```
**Tính năng**: Thực hiện toàn bộ quá trình migration tự động
- Kiểm tra prerequisites
- Dừng services hiện tại
- Migrate config và data
- Restart services
- Test hệ thống
- Tạo báo cáo cuối cùng

### 2. `migrate_to_new_ip.py` - Migration config
```bash
python3 migrate_to_new_ip.py NEW_IP
```
**Tính năng**: Cập nhật config files và tạo QR codes
- Frontend config (API, .env)
- Backend config
- Nginx config
- Script files
- Cron jobs
- QR codes mới

### 3. `backup_and_migrate_data.py` - Migration data
```bash
python3 backup_and_migrate_data.py NEW_IP
```
**Tính năng**: Backup và migrate dữ liệu
- Backup database
- Backup uploads và photos
- Migrate database URLs
- Tạo migration package
- Tạo deployment guide

### 4. `restart_after_migration.sh` - Restart services
```bash
./restart_after_migration.sh NEW_IP
```
**Tính năng**: Restart services với IP mới
- Generate SSL certificates
- Start backend service
- Start frontend service
- Start nginx
- Test services
- Tạo QR codes

## 🚀 Cách sử dụng (KHUYẾN NGHỊ)

### Phương pháp 1: Migration tự động hoàn chỉnh
```bash
# Chạy script tổng hợp (KHUYẾN NGHỊ)
python3 complete_migration.py 192.168.1.100
```

### Phương pháp 2: Migration từng bước
```bash
# Bước 1: Migrate config và data
python3 migrate_to_new_ip.py 192.168.1.100
python3 backup_and_migrate_data.py 192.168.1.100

# Bước 2: Restart services
./restart_after_migration.sh 192.168.1.100
```

## 📱 Ví dụ thực tế

### Migration sang IP: 192.168.1.100
```bash
# Chạy migration hoàn chỉnh
python3 complete_migration.py 192.168.1.100
```

**Kết quả**:
- ✅ PWA URL mới: https://192.168.1.100:3000
- ✅ API URL mới: https://192.168.1.100:8000/api
- ✅ QR code mới: pwa_install_qr_192_168_1_100.png
- ✅ Backup data: migration_backup_*
- ✅ Migration package: migration_package_192_168_1_100_*.zip

## 🔧 Prerequisites

### Yêu cầu hệ thống:
- ✅ Python 3.x
- ✅ Node.js và npm
- ✅ OpenSSL
- ✅ Nginx (optional)

### Yêu cầu dependencies:
```bash
# Python dependencies
pip install qrcode[pil] requests urllib3

# Node.js dependencies (nếu chưa có)
cd frontend && npm install
```

## 📊 Files được tạo sau migration

### 1. QR Codes
- `pwa_install_qr_NEW_IP.png` - QR code để cài đặt PWA

### 2. Backup Data
- `migration_backup_TIMESTAMP/` - Backup toàn bộ dữ liệu
- `migration_package_NEW_IP_TIMESTAMP.zip` - Package để deploy

### 3. Reports
- `migration_report_NEW_IP.md` - Báo cáo migration
- `DEPLOYMENT_GUIDE_NEW_IP.md` - Hướng dẫn deployment
- `FINAL_MIGRATION_REPORT_NEW_IP.md` - Báo cáo cuối cùng
- `migration_status_NEW_IP.txt` - Status report

### 4. Logs
- `backend.log` - Backend service logs
- `frontend.log` - Frontend service logs
- `nginx_access.log` - Nginx access logs

## 🧪 Testing sau migration

### 1. Test API
```bash
curl -k https://NEW_IP:8000/api/health
```

### 2. Test Frontend
```bash
curl -k https://NEW_IP:3000
```

### 3. Test PWA
- Truy cập: https://NEW_IP:3000
- Test cài đặt PWA
- Test các tính năng chính

## 📱 Cập nhật Users

### 1. Gửi QR code mới
- File: `pwa_install_qr_NEW_IP.png`
- URL: https://NEW_IP:3000

### 2. Hướng dẫn users
1. **Xóa app cũ** khỏi màn hình chính
2. **Quét QR code mới** hoặc truy cập URL mới
3. **Cài đặt lại PWA**
4. **Test các tính năng**

## 🔍 Monitoring

### Check services
```bash
# Check processes
ps aux | grep uvicorn
ps aux | grep npm
ps aux | grep nginx

# Check logs
tail -f backend.log
tail -f frontend.log
tail -f nginx_access.log
```

### Health checks
```bash
# Backend health
curl -k https://NEW_IP:8000/api/health

# Frontend health
curl -k https://NEW_IP:3000

# PWA manifest
curl -k https://NEW_IP:3000/manifest.json
```

## 🆘 Troubleshooting

### Lỗi SSL Certificate
```bash
# Regenerate certificates
cd backend
rm key.pem cert.pem
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out cert.csr -subj "/C=VN/ST=HCM/L=HCM/O=MANHTOAN/OU=IT/CN=NEW_IP"
openssl x509 -req -days 365 -in cert.csr -signkey key.pem -out cert.pem
```

### Lỗi Database
```bash
# Check database integrity
sqlite3 backend/app.db "PRAGMA integrity_check;"
sqlite3 backend/patrol.db "PRAGMA integrity_check;"
```

### Lỗi Services
```bash
# Restart services
./restart_after_migration.sh NEW_IP

# Check logs
tail -f backend.log frontend.log
```

## 🔄 Rollback (nếu cần)

### Nếu có vấn đề nghiêm trọng:
1. **Stop services hiện tại**
2. **Restore từ backup**: `migration_backup_TIMESTAMP/`
3. **Restore config files cũ**
4. **Restart với IP cũ**

### Script rollback:
```bash
# Restore từ backup
cp migration_backup_TIMESTAMP/app.db backend/
cp migration_backup_TIMESTAMP/patrol.db backend/
cp -r migration_backup_TIMESTAMP/uploads backend/

# Restore config
cp migration_backup_TIMESTAMP/configs/api.ts frontend/src/utils/
cp migration_backup_TIMESTAMP/configs/config.py backend/app/

# Restart với IP cũ
./restart_after_migration.sh OLD_IP
```

## 📞 Support

### Khi cần hỗ trợ:
1. **Check logs**: `tail -f backend.log frontend.log`
2. **Check status**: `ps aux | grep -E "(uvicorn|npm|nginx)"`
3. **Test connectivity**: `curl -k https://NEW_IP:8000/api/health`
4. **Check backup**: `ls -la migration_backup_*`

### Files quan trọng:
- **Backup data**: `migration_backup_TIMESTAMP/`
- **Migration package**: `migration_package_NEW_IP_TIMESTAMP.zip`
- **Logs**: `backend.log`, `frontend.log`
- **Reports**: `FINAL_MIGRATION_REPORT_NEW_IP.md`

---

## 🎉 Kết luận

Hệ thống đã được chuẩn bị sẵn để migration sang IP mới một cách tự động và an toàn. 

**Khuyến nghị**: Sử dụng `complete_migration.py` để thực hiện migration hoàn chỉnh với một lệnh duy nhất.

**Lưu ý**: Luôn backup dữ liệu trước khi migration và test kỹ sau khi hoàn thành.

---
*Hướng dẫn migration hoàn chỉnh - MANHTOAN PLASTIC PWA* 🚀

