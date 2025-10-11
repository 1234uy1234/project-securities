# 🔐 Hướng dẫn sử dụng Face Authentication

## 📋 Tổng quan

Face Authentication là tính năng đăng nhập bằng khuôn mặt được tích hợp vào hệ thống tuần tra MANHTOAN PLASTIC. Tính năng này giúp:
- **Đăng nhập nhanh** không cần nhập mật khẩu
- **Bảo mật cao** với dữ liệu khuôn mặt được mã hóa
- **Tiện lợi** cho nhân viên không cần nhớ mật khẩu
- **Tránh mượn máy** đăng nhập hộ

## 🚀 Cài đặt

### Backend Dependencies
```bash
cd backend
pip install opencv-python==4.8.1.78 face-recognition==1.3.0 "numpy>=1.21.0"
```

### Database Migration
```bash
# Tạo bảng user_face_data
python -c "from app.database import engine; from app.models import Base; Base.metadata.create_all(bind=engine)"
```

## 🎯 Cách sử dụng

### 1. Đăng ký khuôn mặt

#### Cách 1: Từ Dashboard
1. Vào **Dashboard** → Click **"Cài đặt"** trong phần Face Authentication
2. Click **"Đăng ký khuôn mặt"**
3. Cho phép truy cập camera
4. Đặt khuôn mặt trong khung tròn
5. Click **"Chụp ảnh"**
6. Chờ xử lý và xác nhận thành công

#### Cách 2: Từ Login Page
1. Đăng nhập bình thường bằng username/password
2. Trang login sẽ hiển thị nút **"Đăng nhập bằng khuôn mặt"** (nếu đã đăng ký)
3. Click để cập nhật khuôn mặt

### 2. Đăng nhập bằng khuôn mặt

1. Vào trang **Login**
2. Click **"Đăng nhập bằng khuôn mặt"**
3. Cho phép truy cập camera
4. Nhìn vào camera và click **"Chụp ảnh"**
5. Hệ thống sẽ xác thực và đăng nhập tự động

### 3. Quản lý khuôn mặt

1. Vào **Dashboard** → **"Cài đặt"** trong Face Authentication
2. Xem trạng thái đăng ký
3. **Cập nhật**: Chụp ảnh khuôn mặt mới
4. **Xóa**: Xóa dữ liệu khuôn mặt (cần xác nhận)

## 🔧 API Endpoints

### Đăng ký khuôn mặt
```http
POST /api/face-auth/register
Content-Type: multipart/form-data

image_data: base64_encoded_image
```

### Xác thực khuôn mặt
```http
POST /api/face-auth/verify
Content-Type: multipart/form-data

image_data: base64_encoded_image
```

### Kiểm tra trạng thái
```http
GET /api/face-auth/status
```

### Xóa dữ liệu
```http
DELETE /api/face-auth/unregister
```

## 🛡️ Bảo mật

### Dữ liệu được bảo vệ
- **Face encoding**: Được mã hóa bằng pickle và lưu dưới dạng binary
- **Ảnh mẫu**: Lưu trong thư mục `uploads/faces/` với tên file unique
- **Database**: Chỉ lưu encoding, không lưu ảnh gốc

### Quyền truy cập
- Chỉ user đã đăng nhập mới có thể đăng ký/cập nhật khuôn mặt của mình
- API xác thực không cần token (public endpoint)
- Dữ liệu khuôn mặt được liên kết với user_id

## 📱 Frontend Components

### FaceAuthModal
- Modal chụp ảnh và xử lý face recognition
- Hỗ trợ 2 mode: `register` và `verify`
- Tích hợp camera với overlay hướng dẫn

### FaceAuthStatus
- Hiển thị trạng thái đăng ký khuôn mặt
- Nút đăng ký/cập nhật nhanh
- Tích hợp vào LoginPage và Dashboard

### FaceAuthSettingsPage
- Trang quản lý đầy đủ tính năng face auth
- Xem thông tin chi tiết
- Cập nhật/xóa dữ liệu

## 🎨 UI/UX Features

### Camera Interface
- **Overlay hướng dẫn**: Khung tròn để đặt khuôn mặt
- **Real-time preview**: Xem trước camera
- **Auto-focus**: Tự động lấy nét
- **Error handling**: Thông báo lỗi rõ ràng

### Status Indicators
- ✅ **Đã đăng ký**: Màu xanh với icon CheckCircle
- ⚠️ **Chưa đăng ký**: Màu cam với icon AlertCircle
- 🔄 **Đang xử lý**: Loading spinner
- ❌ **Lỗi**: Màu đỏ với thông báo chi tiết

## 🔍 Troubleshooting

### Lỗi thường gặp

#### 1. "Không thể truy cập camera"
- **Nguyên nhân**: Chưa cấp quyền camera
- **Giải pháp**: Refresh trang và cho phép truy cập camera

#### 2. "Không phát hiện được khuôn mặt"
- **Nguyên nhân**: Ánh sáng không đủ hoặc khuôn mặt không rõ
- **Giải pháp**: 
  - Đảm bảo ánh sáng đủ
  - Nhìn thẳng vào camera
  - Tránh đeo kính râm/khẩu trang

#### 3. "Khuôn mặt không khớp"
- **Nguyên nhân**: Khuôn mặt thay đổi nhiều so với lúc đăng ký
- **Giải pháp**: Cập nhật khuôn mặt mới

#### 4. "Lỗi server"
- **Nguyên nhân**: Backend chưa cài đặt dependencies
- **Giải pháp**: Cài đặt OpenCV và face-recognition

### Debug Mode
Bật console để xem log chi tiết:
```javascript
// Trong browser console
localStorage.setItem('debug', 'face-auth');
```

## 📊 Performance

### Tối ưu hóa
- **Face encoding**: Chỉ tính toán 1 lần khi đăng ký
- **Image compression**: Nén ảnh trước khi gửi lên server
- **Caching**: Lưu trạng thái trong localStorage
- **Lazy loading**: Chỉ load camera khi cần

### Kích thước dữ liệu
- **Face encoding**: ~1KB per user
- **Ảnh mẫu**: ~50-100KB (nén JPEG)
- **Database impact**: Minimal (chỉ thêm 1 bảng)

## 🔮 Tính năng tương lai

### Đang phát triển
- [ ] **Multi-face support**: Hỗ trợ nhiều khuôn mặt cho 1 user
- [ ] **Face aging**: Tự động cập nhật theo thời gian
- [ ] **Anti-spoofing**: Phát hiện ảnh giả
- [ ] **Mobile optimization**: Tối ưu cho mobile

### Cải tiến
- [ ] **Better accuracy**: Cải thiện độ chính xác
- [ ] **Faster processing**: Tăng tốc xử lý
- [ ] **Offline support**: Hoạt động offline
- [ ] **Biometric backup**: Sao lưu dữ liệu sinh trắc học

## 📞 Hỗ trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra console log để xem lỗi chi tiết
2. Thử refresh trang và đăng ký lại
3. Liên hệ admin để được hỗ trợ

---
*Cập nhật: 16/09/2025 - Face Authentication v1.0*
