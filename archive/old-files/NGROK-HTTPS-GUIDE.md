# 🌐 Hướng dẫn tạo HTTPS URL với ngrok

## 🎯 Mục tiêu
Tạo địa chỉ HTTPS có thể truy cập từ **bất kỳ thiết bị nào, bất kỳ mạng nào** (điện thoại, máy tính, mạng khác...)

## 🚀 Cách thực hiện (3 bước đơn giản)

### **Bước 1: Cấu hình ngrok (chỉ cần làm 1 lần)**
```bash
./setup-ngrok-token.sh
```

**Hoặc thủ công:**
1. Truy cập: https://dashboard.ngrok.com/signup
2. Đăng ký tài khoản miễn phí
3. Xác thực email
4. Truy cập: https://dashboard.ngrok.com/get-started/your-authtoken
5. Copy authtoken
6. Chạy: `ngrok config add-authtoken YOUR_TOKEN`

### **Bước 2: Khởi động hệ thống với ngrok**
```bash
./start-with-ngrok-https.sh
```

### **Bước 3: Truy cập từ bất kỳ đâu**
- **Máy tính:** Mở trình duyệt, truy cập URL ngrok
- **Điện thoại:** Mở trình duyệt, truy cập cùng URL ngrok
- **Mạng khác:** Truy cập cùng URL ngrok

## 📱 Ví dụ kết quả

Sau khi chạy script, bạn sẽ thấy:
```
🎉 Hệ thống đã khởi động với ngrok HTTPS!
🌐 HTTPS URL: https://abc123.ngrok.io
📱 Truy cập từ điện thoại: https://abc123.ngrok.io
💻 Truy cập từ máy tính: https://abc123.ngrok.io
```

## 🔧 Troubleshooting

### Lỗi: "authentication failed"
- Chạy lại: `./setup-ngrok-token.sh`
- Đảm bảo đã đăng ký tài khoản ngrok

### Lỗi: "không thể lấy ngrok URL"
- Đợi thêm 30 giây
- Kiểm tra: `curl http://localhost:4040/api/tunnels`

### Lỗi: "port 8000 already in use"
- Chạy: `pkill -f uvicorn`
- Chạy lại script

## 🎯 Lợi ích

- ✅ **HTTPS tự động** - Bảo mật cao
- ✅ **Truy cập từ bất kỳ đâu** - Không cần cùng mạng
- ✅ **Hoạt động trên điện thoại** - Test dễ dàng
- ✅ **Không cần cấu hình router** - Ngrok xử lý
- ✅ **URL cố định** - Có thể bookmark

## 💡 Lưu ý

- Ngrok URL thay đổi mỗi lần khởi động (trừ khi có tài khoản trả phí)
- URL chỉ hoạt động khi script đang chạy
- Để dừng: Nhấn `Ctrl+C`

