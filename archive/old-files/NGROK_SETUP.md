# 🚀 HƯỚNG DẪN SETUP NGROK

## 📋 Các bước thực hiện:

### 1. Chạy ngrok
```bash
ngrok http 8000
```

### 2. Copy URL từ ngrok
- Mở terminal mới
- Chạy lệnh trên
- Copy URL https (ví dụ: `https://abc123.ngrok-free.app`)

### 3. Cập nhật config
```bash
python3 update_config.py https://abc123.ngrok-free.app
```

### 4. Restart services
```bash
./restart_services.sh
```

### 5. Truy cập từ điện thoại
- Mở trình duyệt điện thoại
- Truy cập URL ngrok
- Đăng nhập và sử dụng!

## 🔧 Scripts có sẵn:

- `update_config.py` - Cập nhật config với URL ngrok
- `restart_services.sh` - Restart backend và frontend
- `setup_ngrok.sh` - Tự động setup (cần auth token)

## 📱 Lợi ích:

✅ **URL cố định** - Không đổi mỗi ngày  
✅ **Truy cập từ điện thoại** - Không cần cùng WiFi  
✅ **HTTPS tự động** - Bảo mật  
✅ **Dễ dàng chia sẻ** - Chỉ cần gửi URL  

## 🚨 Lưu ý:

- Ngrok miễn phí có giới hạn bandwidth
- URL sẽ thay đổi nếu restart ngrok
- Cần chạy ngrok mỗi khi khởi động máy

## 🎯 Kết quả:

Sau khi setup xong, bạn có thể:
- Truy cập app từ điện thoại
- Chia sẻ với người khác
- Không cần lo đổi IP mỗi ngày
