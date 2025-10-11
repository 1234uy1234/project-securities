# 🔐 Hướng dẫn Test Face Authentication

## 🚀 Cách test nhanh

### 1. Khởi động Backend
```bash
cd backend
source venv/bin/activate
python app.py
```

### 2. Khởi động Frontend
```bash
cd frontend
npm run dev
```

### 3. Test bằng trang HTML đơn giản
Mở file `test-face-login.html` trong browser:
- Click "Bật Camera"
- Click "Chụp ảnh" 
- Click "Test Đăng ký" (lần đầu)
- Click "Test Xác thực" (sau khi đăng ký)

## 🎯 Test trong ứng dụng chính

### 1. Đăng nhập bình thường
- Vào `http://localhost:5173`
- Username: `admin`
- Password: `admin123`

### 2. Đăng ký khuôn mặt
- Sau khi đăng nhập, bạn sẽ thấy nút **"Đăng ký/Đăng nhập bằng khuôn mặt"** ở trang login
- Click vào nút đó
- Cho phép camera
- Chụp ảnh khuôn mặt
- Chờ xử lý

### 3. Đăng nhập bằng khuôn mặt
- Logout khỏi hệ thống
- Vào trang login
- Click **"Đăng nhập bằng khuôn mặt"**
- Chụp ảnh để xác thực

## 🔧 Troubleshooting

### Nếu không thấy nút Face Auth:
1. **Kiểm tra console** (F12) xem có lỗi gì không
2. **Kiểm tra backend** có chạy không: `http://localhost:8000/health`
3. **Refresh trang** và thử lại

### Nếu camera không hoạt động:
1. **Cho phép camera** khi browser hỏi
2. **Kiểm tra camera** có bị app khác sử dụng không
3. **Thử browser khác** (Chrome, Firefox, Safari)

### Nếu lỗi API:
1. **Kiểm tra backend logs** trong terminal
2. **Kiểm tra database** có tạo bảng `user_face_data` chưa
3. **Cài đặt dependencies**: `pip install opencv-python face-recognition`

## 📱 Các tính năng đã có

### ✅ Backend APIs
- `POST /api/face-auth/register` - Đăng ký khuôn mặt
- `POST /api/face-auth/verify` - Xác thực khuôn mặt  
- `GET /api/face-auth/status` - Kiểm tra trạng thái
- `DELETE /api/face-auth/unregister` - Xóa dữ liệu

### ✅ Frontend Components
- **LoginPage**: Nút đăng nhập bằng khuôn mặt
- **FaceAuthModal**: Modal chụp ảnh và xử lý
- **Dashboard**: Section quản lý face auth
- **FaceAuthSettingsPage**: Trang cài đặt chi tiết

### ✅ Database
- Bảng `user_face_data` để lưu face encoding
- Liên kết với bảng `users` qua `user_id`

## 🎨 UI Features

### Trang Login
- Nút **"Đăng ký/Đăng nhập bằng khuôn mặt"** (luôn hiển thị)
- Modal camera với overlay hướng dẫn
- Thông báo lỗi/thành công rõ ràng

### Dashboard
- Section **"Xác thực khuôn mặt"** 
- Nút **"Cài đặt"** để vào trang quản lý
- Hiển thị trạng thái đăng ký

### Trang Cài đặt
- Xem thông tin chi tiết
- Cập nhật khuôn mặt
- Xóa dữ liệu khuôn mặt

## 🔍 Debug

### Kiểm tra Console
```javascript
// Mở F12 Console và chạy:
fetch('/api/face-auth/status')
  .then(r => r.json())
  .then(console.log)
```

### Kiểm tra Backend
```bash
curl http://localhost:8000/health
curl http://localhost:8000/api/face-auth/status
```

### Kiểm tra Database
```python
# Trong Python shell:
from backend.app.database import SessionLocal
from backend.app.models import UserFaceData
db = SessionLocal()
face_data = db.query(UserFaceData).all()
print(f"Found {len(face_data)} face records")
```

## 🎯 Kết quả mong đợi

1. **Trang login** hiển thị nút face auth
2. **Click nút** → Modal camera mở ra
3. **Chụp ảnh** → Xử lý và lưu vào database
4. **Đăng nhập thành công** → Chuyển đến dashboard
5. **Dashboard** hiển thị section face auth

---
*Nếu vẫn không thấy nút, hãy kiểm tra console log và cho tôi biết lỗi gì!*
