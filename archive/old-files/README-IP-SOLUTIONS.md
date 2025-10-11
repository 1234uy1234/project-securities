# 🔧 Giải pháp xử lý IP thay đổi cho Shopee App

## 🚨 Vấn đề
Địa chỉ IP của máy tính thay đổi mỗi ngày, khiến frontend không thể kết nối với backend.

## ✅ Giải pháp đã triển khai

### 1. 🚀 Khởi động nhanh (Khuyến nghị)
```bash
# Cách đơn giản nhất - tự động cập nhật IP và khởi động app
./start-app.sh --auto-ip
```

### 2. 🔄 Cập nhật IP tự động mỗi ngày
```bash
# Cài đặt tự động cập nhật IP mỗi 5 phút
./setup-auto-update.sh --install

# Kiểm tra trạng thái
./setup-auto-update.sh --status

# Xem log cập nhật
./setup-auto-update.sh --log
```

### 3. 📝 Cập nhật IP thủ công
```bash
# Cập nhật IP ngay lập tức
./daily-ip-update.sh

# Hoặc cập nhật với IP cụ thể
./update-backend-ip.sh 192.168.1.100 8000
```

### 4. 🔒 Cố định IP (Giải pháp lâu dài)
```bash
# Cố định IP hiện tại
sudo ./fix-static-ip.sh

# Cố định IP cụ thể
sudo ./fix-static-ip.sh 192.168.1.100 255.255.255.0 192.168.1.1

# Khôi phục DHCP
sudo ./fix-static-ip.sh --restore
```

## 📋 Danh sách Scripts

| Script | Mô tả | Sử dụng |
|--------|-------|---------|
| `start-app.sh` | Khởi động app với tự động cập nhật IP | `./start-app.sh --auto-ip` |
| `daily-ip-update.sh` | Cập nhật IP và kiểm tra thay đổi | `./daily-ip-update.sh` |
| `setup-auto-update.sh` | Thiết lập crontab tự động | `./setup-auto-update.sh --install` |
| `fix-static-ip.sh` | Cố định IP address | `sudo ./fix-static-ip.sh` |
| `update-backend-ip.sh` | Cập nhật IP backend cho frontend | `./update-backend-ip.sh IP PORT` |
| `auto-detect-ip.sh` | Tự động phát hiện IP và chạy app | `./auto-detect-ip.sh` |

## 🎯 Hướng dẫn sử dụng

### Cách 1: Sử dụng hàng ngày (Đơn giản)
```bash
# Mỗi khi muốn chạy app
./start-app.sh --auto-ip
```

### Cách 2: Tự động hóa hoàn toàn
```bash
# Cài đặt một lần
./setup-auto-update.sh --install

# Sau đó chỉ cần chạy app bình thường
./start-app.sh
```

### Cách 3: Cố định IP (Khuyến nghị cho production)
```bash
# Cố định IP một lần
sudo ./fix-static-ip.sh

# Sau đó IP sẽ không thay đổi nữa
./start-app.sh
```

## 🔍 Troubleshooting

### Lỗi "Không thể phát hiện IP"
```bash
# Kiểm tra kết nối mạng
ping google.com

# Kiểm tra IP hiện tại
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### Lỗi "Port đã được sử dụng"
```bash
# Dừng tất cả process
pkill -f "uvicorn\|npm"

# Hoặc thay đổi port
./update-backend-ip.sh YOUR_IP 8001
```

### Lỗi SSL Certificate
```bash
# Sửa chứng chỉ SSL
./fix-certificate.sh

# Hoặc tắt SSL verification trong config
```

## 📊 Monitoring

### Kiểm tra trạng thái
```bash
# Kiểm tra IP hiện tại
./update-backend-ip.sh

# Kiểm tra port đang sử dụng
lsof -i :8000
lsof -i :5173

# Kiểm tra log
tail -f ip-update.log
```

### Kiểm tra kết nối
```bash
# Test backend
curl -k https://YOUR_IP:8000/health

# Test frontend
curl -k https://YOUR_IP:5173
```

## 🚀 Quick Start

1. **Lần đầu sử dụng:**
   ```bash
   ./setup-auto-update.sh --install
   ./start-app.sh --auto-ip
   ```

2. **Sử dụng hàng ngày:**
   ```bash
   ./start-app.sh
   ```

3. **Nếu IP thay đổi:**
   ```bash
   ./daily-ip-update.sh
   ```

## 📱 PWA Installation

Sau khi app chạy, mở trình duyệt và truy cập:
- **Frontend:** `https://YOUR_IP:5173`
- **Backend API:** `https://YOUR_IP:8000`

App sẽ tự động hiển thị popup cài đặt PWA.

## 🔧 Advanced Configuration

### Cấu hình crontab tùy chỉnh
```bash
# Chỉnh sửa crontab
crontab -e

# Thêm job cập nhật IP mỗi giờ
0 * * * * cd /Users/maybe/Documents/shopee && ./daily-ip-update.sh
```

### Cấu hình static IP tùy chỉnh
```bash
# Cấu hình IP tĩnh với thông tin mạng cụ thể
sudo ./fix-static-ip.sh 192.168.1.100 255.255.255.0 192.168.1.1
```

---
*Cập nhật lần cuối: $(date)*
*Tác giả: AI Assistant*
