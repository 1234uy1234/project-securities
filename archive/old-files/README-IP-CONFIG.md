# Hướng dẫn cấu hình IP cho hệ thống

## Vấn đề
Mỗi ngày địa chỉ IP của máy có thể thay đổi, khiến frontend không thể kết nối đến backend.

## Giải pháp
Đã tạo các script tự động để giải quyết vấn đề này:

### 1. Script tự động phát hiện IP và khởi động hệ thống
```bash
./quick-start.sh
```
Script này sẽ:
- Tự động phát hiện địa chỉ IP hiện tại
- Cập nhật cấu hình frontend
- Khởi động cả backend và frontend

### 2. Script cập nhật IP thủ công
```bash
./update-backend-ip.sh [IP_ADDRESS] [PORT]
```

Ví dụ:
```bash
# Tự động phát hiện IP
./update-backend-ip.sh

# Chỉ định IP cụ thể
./update-backend-ip.sh 192.168.1.100 8000
```

### 3. Script chạy frontend với cấu hình động
```bash
./run-frontend.sh [IP_ADDRESS] [BACKEND_PORT]
```

Ví dụ:
```bash
# Tự động phát hiện IP
./run-frontend.sh

# Chỉ định IP cụ thể
./run-frontend.sh 192.168.1.100 8000
```

## Cách sử dụng hàng ngày

### Cách 1: Sử dụng script tự động (Khuyến nghị)
```bash
./quick-start.sh
```

### Cách 2: Cập nhật IP thủ công
1. Kiểm tra IP hiện tại:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. Cập nhật cấu hình:
   ```bash
   ./update-backend-ip.sh [IP_MỚI]
   ```

3. Chạy frontend:
   ```bash
   ./run-frontend.sh
   ```

## Cấu hình được lưu ở đâu?

- **File cấu hình chính**: `frontend/.env.local`
- **File cấu hình phụ**: `frontend/config.js`
- **Cấu hình Vite**: `frontend/vite.config.ts`

## Troubleshooting

### Lỗi "Connection refused"
- Kiểm tra backend có đang chạy không: `lsof -i :8000`
- Kiểm tra IP có đúng không: `./update-backend-ip.sh`

### Lỗi "Mixed Content"
- Đảm bảo cả frontend và backend đều chạy HTTPS
- Kiểm tra cấu hình proxy trong `vite.config.ts`

### Lỗi "Certificate"
- Script đã cấu hình `secure: false` để bỏ qua lỗi certificate
- Nếu vẫn lỗi, kiểm tra file SSL trong thư mục `ssl/`

## Lưu ý
- Script sẽ tự động phát hiện IP của interface mạng chính
- Nếu có nhiều interface, có thể cần chỉ định IP thủ công
- Luôn chạy backend trước khi chạy frontend
