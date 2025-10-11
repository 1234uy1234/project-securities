# 🌐 Hướng dẫn sử dụng ngrok cho hệ thống

## 📋 Tổng quan
Hệ thống đã được cấu hình để sử dụng ngrok, cho phép truy cập từ bất kỳ đâu qua HTTPS public URL.

## 🚀 Cách sử dụng

### 0. Cấu hình ngrok (chỉ cần làm 1 lần)
```bash
./setup-ngrok.sh
```

Nếu chưa có authtoken:
1. Truy cập: https://dashboard.ngrok.com/signup
2. Đăng ký tài khoản miễn phí
3. Lấy authtoken từ: https://dashboard.ngrok.com/get-started/your-authtoken
4. Chạy: `ngrok config add-authtoken YOUR_TOKEN`

### 1. Khởi động Backend với ngrok
```bash
python start-with-ngrok.py
```

Script này sẽ:
- ✅ Khởi động backend Python
- ✅ Tự động tạo ngrok tunnel
- ✅ Cập nhật file `.env` với ngrok URL
- ✅ In ra public URL để truy cập

### 2. Khởi động Frontend
```bash
./start-frontend-with-ngrok.sh
```

Hoặc thủ công:
```bash
cd frontend
npm run dev
```

## 📁 Cấu trúc file

### File mới được tạo:
- `start-with-ngrok.py` - Script khởi động backend + ngrok
- `start-frontend-with-ngrok.sh` - Script khởi động frontend
- `frontend/src/utils/config.ts` - Utility functions cho URL
- `env-template.txt` - Template cho file .env

### File đã cập nhật:
- `frontend/src/utils/api.ts` - Sử dụng VITE_API_URL
- `frontend/src/components/CheckinDetailModal.tsx` - Sử dụng getImageUrl()
- `frontend/src/pages/ReportsPage.tsx` - Sử dụng getImageUrl()
- `frontend/src/pages/TasksPage.tsx` - Sử dụng getQRCodeUrl()

## 🔧 Cấu hình

### File .env
```env
NGROK_URL=https://abc123.ngrok.io
VITE_API_URL=https://abc123.ngrok.io
```

### Biến môi trường
- `NGROK_URL` - URL ngrok cho backend
- `VITE_API_URL` - URL cho frontend (tự động cập nhật)

## 📱 Truy cập từ điện thoại

1. Chạy `python start-with-ngrok.py`
2. Lấy ngrok URL từ terminal (ví dụ: `https://abc123.ngrok.io`)
3. Mở trình duyệt điện thoại và truy cập URL đó
4. Hệ thống sẽ hoạt động bình thường!

## 🔄 Luồng hoạt động

1. **Backend khởi động** → Chạy trên port 8000
2. **Ngrok tạo tunnel** → Tạo public HTTPS URL
3. **Cập nhật .env** → Lưu ngrok URL
4. **Frontend đọc .env** → Sử dụng ngrok URL cho API
5. **Tất cả ảnh/API** → Tự động sử dụng ngrok URL

## 🛠️ Troubleshooting

### Lỗi: "NGROK_URL chưa được cập nhật"
```bash
# Chạy script backend trước
python start-with-ngrok.py
```

### Lỗi: "File .env không tồn tại"
```bash
# Tạo file .env từ template
cp env-template.txt .env
```

### Lỗi: "Ngrok không khởi động"
```bash
# Kiểm tra ngrok đã cài đặt
which ngrok

# Nếu chưa có, cài đặt ngrok
# macOS: brew install ngrok
# Hoặc tải từ: https://ngrok.com/download
```

## 📊 Kiểm tra hoạt động

### 1. Kiểm tra backend
```bash
curl https://your-ngrok-url.ngrok.io/api/health
```

### 2. Kiểm tra ảnh
```bash
curl https://your-ngrok-url.ngrok.io/uploads/test.jpg
```

### 3. Kiểm tra frontend
- Mở trình duyệt
- Truy cập ngrok URL
- Kiểm tra console để xem API calls

## 🎯 Lợi ích

- ✅ **Truy cập từ bất kỳ đâu** - Không cần cùng mạng
- ✅ **HTTPS tự động** - Bảo mật cao
- ✅ **Không cần cấu hình router** - Ngrok xử lý
- ✅ **Tự động cập nhật** - Không cần sửa code
- ✅ **Hoạt động trên điện thoại** - Test dễ dàng

## 🔐 Bảo mật

- Ngrok URL là public, chỉ sử dụng cho development
- Không sử dụng cho production
- Có thể cấu hình authentication nếu cần
