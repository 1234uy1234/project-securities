# Cấu hình IP tĩnh cho dự án Shopee Patrol System

## IP cố định: localhost

### Các file đã được cố định IP:

1. **start-https-final.sh** - Script khởi động
   - IP: localhost
   - Backend: https://localhost:8000
   - Frontend: https://localhost:5173

2. **nginx-https.conf** - Cấu hình Nginx
   - Upstream: localhost:8000
   - Server name: localhost localhost

3. **frontend/src/utils/api.ts** - API configuration
   - Base URL: https://localhost/api

### Cách sử dụng:

1. **Khởi động dự án:**
   ```bash
   cd /Users/maybe/Documents/shopee
   ./start-https-final.sh
   ```

2. **Truy cập ứng dụng:**
   - Frontend: https://localhost:5173
   - Backend API: https://localhost:8000
   - API Docs: https://localhost:8000/docs

3. **Thông tin đăng nhập:**
   - Username: admin
   - Password: admin123

### Lưu ý:
- IP đã được cố định là localhost
- Không thay đổi IP nữa để tránh lỗi kết nối
- Nếu cần thay đổi IP, phải cập nhật tất cả các file trên
