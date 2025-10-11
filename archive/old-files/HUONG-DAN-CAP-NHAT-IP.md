# 📱 Hướng dẫn cập nhật IP cho Shopee App

## 🚨 Vấn đề
Địa chỉ IP của máy tính thay đổi mỗi ngày, khiến frontend không thể kết nối với backend.

## ✅ Giải pháp

### 1. Cập nhật IP tự động (Khuyến nghị)

#### Cách 1: Chạy script tự động
```bash
# Cập nhật IP ngay lập tức
./daily-ip-update.sh

# Hoặc sử dụng script cũ
./update-backend-ip.sh
```

#### Cách 2: Tự động hóa với crontab (macOS/Linux)
```bash
# Mở crontab editor
crontab -e

# Thêm dòng này để chạy mỗi 5 phút
*/5 * * * * cd /Users/maybe/Documents/shopee && ./daily-ip-update.sh

# Hoặc chạy mỗi giờ
0 * * * * cd /Users/maybe/Documents/shopee && ./daily-ip-update.sh
```

### 2. Cập nhật IP thủ công

#### Bước 1: Kiểm tra IP hiện tại
```bash
# Cách 1: Sử dụng ifconfig
ifconfig | grep "inet " | grep -v 127.0.0.1

# Cách 2: Sử dụng ip command
ip route get 1.1.1.1 | awk '{print $7}'

# Cách 3: Sử dụng hostname
hostname -I
```

#### Bước 2: Cập nhật cấu hình
```bash
# Cập nhật với IP mới (thay YOUR_NEW_IP bằng IP thực tế)
./update-backend-ip.sh YOUR_NEW_IP 8000

# Ví dụ:
./update-backend-ip.sh 192.168.1.100 8000
```

#### Bước 3: Khởi động lại frontend
```bash
# Cách 1: Sử dụng script
./run-frontend.sh

# Cách 2: Thủ công
cd frontend
npm run dev
```

### 3. Cố định IP (Giải pháp lâu dài)

#### Cách 1: Cấu hình Static IP trên Router
1. Truy cập router (thường là 192.168.1.1 hoặc 192.168.0.1)
2. Tìm phần "DHCP Reservation" hoặc "Static IP"
3. Thêm MAC address của máy tính với IP cố định
4. Khởi động lại router

#### Cách 2: Cấu hình Static IP trên máy tính

**macOS:**
1. System Preferences → Network
2. Chọn kết nối hiện tại → Advanced
3. Tab TCP/IP → Configure IPv4: Manually
4. Nhập IP cố định (ví dụ: 192.168.1.100)
5. Nhập Subnet Mask: 255.255.255.0
6. Nhập Router: 192.168.1.1

**Windows:**
1. Control Panel → Network and Sharing Center
2. Change adapter settings
3. Right-click kết nối → Properties
4. Chọn Internet Protocol Version 4 (TCP/IPv4) → Properties
5. Chọn "Use the following IP address"
6. Nhập IP cố định và thông tin mạng

### 4. Script khởi động tự động

#### Tạo script khởi động
```bash
# Tạo file start-app.sh
cat > start-app.sh << 'EOF'
#!/bin/bash
cd /Users/maybe/Documents/shopee
./daily-ip-update.sh
./auto-detect-ip.sh
EOF

chmod +x start-app.sh
```

#### Thêm vào startup (macOS)
1. System Preferences → Users & Groups
2. Login Items → Add
3. Chọn file `start-app.sh`

## 🔧 Troubleshooting

### Lỗi thường gặp:

1. **"Không thể phát hiện IP"**
   - Kiểm tra kết nối mạng
   - Thử chạy: `ping google.com`

2. **"Port đã được sử dụng"**
   - Dừng process cũ: `pkill -f "uvicorn\|npm"`
   - Hoặc thay đổi port trong script

3. **"SSL Certificate Error"**
   - Chạy: `./fix-certificate.sh`
   - Hoặc tắt SSL verification trong config

### Kiểm tra trạng thái:
```bash
# Kiểm tra IP hiện tại
./update-backend-ip.sh

# Kiểm tra port đang sử dụng
lsof -i :8000
lsof -i :5173

# Kiểm tra log
tail -f backend/logs/app.log
```

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy:
1. Chạy `./daily-ip-update.sh` để cập nhật IP
2. Kiểm tra log để xem lỗi cụ thể
3. Thử khởi động lại toàn bộ hệ thống

---
*Cập nhật lần cuối: $(date)*
