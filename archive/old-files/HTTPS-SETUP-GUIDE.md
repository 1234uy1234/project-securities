# Hướng dẫn cấu hình HTTPS cho hệ thống tuần tra

## ✅ Đã hoàn thành

### 1. Tạo SSL Certificate hợp lệ
- Sử dụng `mkcert` để tạo certificate được tin cậy bởi hệ thống
- Certificate bao gồm: `localhost`, `localhost`, `127.0.0.1`
- Certificate được lưu tại: `ssl/server.crt` và `ssl/server.key`
- Thời hạn: 12/12/2027

### 2. Cấu hình Backend (HTTPS)
- Backend chạy trên: `https://localhost:8000`
- Sử dụng certificate từ mkcert
- CORS đã được cấu hình cho cả HTTP và HTTPS

### 3. Cấu hình Frontend (HTTPS)
- Frontend chạy trên: `https://localhost:5173`
- Vite đã được cấu hình để sử dụng HTTPS
- API calls được proxy qua HTTPS

## 🚀 Cách khởi động ứng dụng

### Phương pháp 1: Sử dụng script tự động
```bash
./start-https.sh
```

### Phương pháp 2: Khởi động thủ công

#### Backend:
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --ssl-keyfile ../ssl/server.key --ssl-certfile ../ssl/server.crt
```

#### Frontend:
```bash
cd frontend
VITE_API_BASE_URL=https://localhost:8000 npm run dev -- --host 0.0.0.0 --port 5173 --https
```

## 🔧 Cấu hình đã được cập nhật

### Frontend (`frontend/config.js`):
```javascript
export const config = {
  API_BASE_URL: 'https://localhost:8000',
  API_TIMEOUT: 10000,
  SSL_VERIFY: false
}
```

### Frontend API (`frontend/src/utils/api.ts`):
```javascript
export const api = axios.create({
  baseURL: 'https://localhost:8000/api',
  // ...
})
```

### Backend (`backend/app/main.py`):
```python
uvicorn.run(app, host="0.0.0.0", port=8000, 
           ssl_keyfile="../ssl/server.key", 
           ssl_certfile="../ssl/server.crt")
```

## 🌐 Truy cập ứng dụng

- **Frontend**: https://localhost:5173
- **Backend API**: https://localhost:8000
- **API Documentation**: https://localhost:8000/docs

## ✅ Lợi ích của cấu hình này

1. **Không còn lỗi SSL**: Certificate được tin cậy bởi hệ thống
2. **Bảo mật**: Tất cả traffic được mã hóa
3. **PWA hoạt động**: Service Worker yêu cầu HTTPS
4. **Mixed Content**: Không còn vấn đề mixed content
5. **Tương thích**: Hoạt động trên tất cả trình duyệt hiện đại

## 🔍 Test kết nối

Chạy script test để kiểm tra:
```bash
python3 test-https-connection.py
```

## 📱 PWA Installation

Với HTTPS, PWA có thể được cài đặt:
1. Mở https://localhost:5173
2. Nhấn nút "Install App" hoặc "Add to Home Screen"
3. Ứng dụng sẽ được cài đặt như native app

## 🛠️ Troubleshooting

### Nếu vẫn gặp lỗi SSL:
1. Kiểm tra certificate: `ls -la ssl/`
2. Tạo lại certificate: `cd ssl && mkcert localhost localhost 127.0.0.1`
3. Restart ứng dụng

### Nếu không truy cập được:
1. Kiểm tra firewall: `sudo ufw status`
2. Kiểm tra port: `netstat -tlnp | grep :8000`
3. Kiểm tra log: Xem console của browser và terminal

## 📋 Checklist

- [x] Tạo SSL certificate với mkcert
- [x] Cấu hình backend HTTPS
- [x] Cấu hình frontend HTTPS  
- [x] Cập nhật API endpoints
- [x] Test kết nối thành công
- [x] Tạo script khởi động tự động
- [x] Viết hướng dẫn chi tiết
