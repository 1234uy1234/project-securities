# MANHTOAN PLASTIC - Hệ thống Tuần tra

Hệ thống tuần tra thông minh sử dụng mã QR và GPS để quản lý tuần tra của nhân viên.

## Tính năng chính

### 👤 Nhân viên
- Đăng nhập vào hệ thống
- Xem nhiệm vụ tuần tra được phân công
- Quét mã QR để xác nhận tuần tra
- Chụp ảnh tại vị trí tuần tra
- Xem lịch sử tuần tra cá nhân
- Sử dụng offline với PWA

### 👨‍💼 Quản lý
- Quản lý tài khoản nhân viên
- Tạo và phân công nhiệm vụ tuần tra
- Lên lịch tuần tra theo tuần
- Xem báo cáo tuần tra toàn bộ nhân viên
- Quản lý vị trí tuần tra

### 🏢 Admin
- Quản lý toàn bộ hệ thống
- Tạo tài khoản quản lý
- Cấu hình hệ thống
- Xem thống kê tổng quan

## Cấu trúc dự án

```
shopee/
├── frontend/                 # React + Vite frontend
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── pages/          # Các trang chính
│   │   ├── hooks/          # Custom hooks
│   │   ├── utils/          # Utility functions
│   │   └── assets/         # Hình ảnh, icons
├── backend/                 # Python FastAPI backend
│   ├── app/
│   │   ├── models/         # Database models
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   └── utils/          # Helper functions
│   └── requirements.txt     # Python dependencies
└── database/               # Database scripts
```

## Cài đặt và chạy

### Backend

1. Cài đặt Python 3.8+
2. Cài đặt PostgreSQL
3. Tạo database `patrol_system`
4. Cài đặt dependencies:

```bash
cd backend
pip install -r requirements.txt
```

5. Chạy backend:

```bash
cd backend
uvicorn app.main:app --reload
```

Backend sẽ chạy tại: https://10.10.68.22:8000

### Frontend

1. Cài đặt Node.js 16+
2. Cài đặt dependencies:

```bash
cd frontend
npm install
```

3. Chạy frontend:

```bash
cd frontend
npm run dev
```

Frontend sẽ chạy tại: https://10.10.68.22:5173

## API Endpoints

### Authentication
- `POST /auth/login` - Đăng nhập
- `POST /auth/refresh` - Làm mới token

### Users
- `GET /users/me` - Thông tin user hiện tại
- `GET /users` - Danh sách users (Admin/Manager)
- `POST /users` - Tạo user mới (Admin/Manager)
- `PUT /users/{id}` - Cập nhật user (Admin/Manager)

### Patrol Tasks
- `GET /patrol-tasks` - Danh sách nhiệm vụ tuần tra
- `POST /patrol-tasks` - Tạo nhiệm vụ mới (Manager)
- `PUT /patrol-tasks/{id}` - Cập nhật nhiệm vụ (Manager)
- `DELETE /patrol-tasks/{id}` - Xóa nhiệm vụ (Manager)

### Patrol Records
- `POST /patrol-records/scan` - Ghi nhận tuần tra bằng QR
- `GET /patrol-records/history` - Lịch sử tuần tra
- `GET /patrol-records/report` - Báo cáo tuần tra (Manager)

### Locations
- `GET /locations` - Danh sách vị trí tuần tra
- `POST /locations` - Tạo vị trí mới (Manager)
- `PUT /locations/{id}` - Cập nhật vị trí (Manager)

## Database Schema

### Users
- id, username, email, password_hash, role, full_name, phone, created_at, updated_at

### PatrolTasks
- id, title, description, location_id, assigned_to, schedule_week, status, created_by, created_at, updated_at

### PatrolRecords
- id, user_id, task_id, location_id, check_in_time, check_out_time, gps_latitude, gps_longitude, photo_url, notes, created_at

### Locations
- id, name, description, qr_code, address, gps_latitude, gps_longitude, created_at, updated_at

## Tính năng PWA

- Service Worker để cache tài nguyên
- IndexedDB để lưu dữ liệu offline
- Đồng bộ dữ liệu khi có mạng
- Cài đặt trên thiết bị di động

## Bảo mật

- JWT authentication
- Role-based access control
- Password hashing với bcrypt
- CORS configuration
- Rate limiting

## Triển khai

### Production
1. Build frontend: `npm run build`
2. Sử dụng Gunicorn cho backend
3. Nginx reverse proxy
4. PostgreSQL production setup
5. Environment variables cho production

### Docker (Tùy chọn)
```bash
docker-compose up -d
```

## Hỗ trợ

Nếu có vấn đề gì, vui lòng tạo issue hoặc liên hệ team phát triển.
