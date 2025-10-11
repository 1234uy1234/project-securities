# 🚀 Hướng dẫn khởi động nhanh với HTTPS

## 📍 Vị trí thư mục
Đảm bảo bạn đang ở thư mục đúng:
```bash
cd /Users/maybe/Documents/shopee
```

## 🔧 Cách 1: Khởi động từng service riêng biệt

### Bước 1: Khởi động Backend (Terminal 1)
```bash
cd /Users/maybe/Documents/shopee
./start-backend-https.sh
```

### Bước 2: Khởi động Frontend (Terminal 2)
```bash
cd /Users/maybe/Documents/shopee
./start-frontend-https.sh
```

## 🔧 Cách 2: Khởi động cả hai cùng lúc
```bash
cd /Users/maybe/Documents/shopee
./start-https.sh
```

## 🌐 Truy cập ứng dụng
- **Frontend**: https://localhost:5173
- **Backend API**: https://localhost:8000
- **API Docs**: https://localhost:8000/docs

## ✅ Test kết nối
```bash
cd /Users/maybe/Documents/shopee
python3 test-https-connection.py
```

## 🔍 Kiểm tra trạng thái
```bash
# Kiểm tra backend
curl -k https://localhost:8000/health

# Kiểm tra frontend
curl -k https://localhost:5173
```

## 🛠️ Troubleshooting

### Nếu gặp lỗi "no such file or directory":
```bash
# Kiểm tra vị trí hiện tại
pwd

# Di chuyển đến thư mục đúng
cd /Users/maybe/Documents/shopee

# Kiểm tra script có tồn tại không
ls -la start-*.sh
```

### Nếu gặp lỗi SSL:
```bash
# Tạo lại certificate
cd ssl
mkcert localhost localhost 127.0.0.1
mv localhost+2.pem server.crt
mv localhost+2-key.pem server.key
cd ..
```

### Nếu port bị chiếm:
```bash
# Tìm process đang sử dụng port
lsof -i :8000
lsof -i :5173

# Kill process (thay PID bằng số thực tế)
kill -9 PID
```

## 📱 Đăng nhập
- **Username**: admin
- **Password**: admin123
- **URL**: https://localhost:5173

Sau khi khởi động thành công, bạn sẽ không còn thấy lỗi `ERR_CERT_AUTHORITY_INVALID` nữa! 🎉
