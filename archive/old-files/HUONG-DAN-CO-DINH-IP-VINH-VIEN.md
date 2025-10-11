# 🔒 HƯỚNG DẪN CỐ ĐỊNH IP VĨNH VIỄN

## 🚨 VẤN ĐỀ HIỆN TẠI
- IP của bạn cứ thay đổi mỗi ngày (localhost hôm nay, có thể khác ngày mai)
- Điều này làm dự án không bao giờ hoàn thành được
- Cần cố định IP vĩnh viễn

## ✅ GIẢI PHÁP TRIỆT ĐỂ

### Bước 1: Cố định IP trên máy macOS
```bash
cd /Users/maybe/Documents/shopee
sudo ./fix-ip-permanently.sh
```

**Hoặc làm thủ công:**
1. Mở **System Preferences** → **Network**
2. Chọn kết nối WiFi hiện tại → **Advanced**
3. Tab **TCP/IP** → **Configure IPv4**: **Manually**
4. Nhập:
   - **IP Address**: `localhost`
   - **Subnet Mask**: `255.255.254.0`
   - **Router**: `localhost`
5. Tab **DNS** → Thêm: `8.8.8.8`, `8.8.4.4`
6. **Apply** → **OK**

### Bước 2: Cố định IP trên Router (Quan trọng!)
1. Truy cập router: `http://localhost`
2. Đăng nhập (thường là admin/admin hoặc admin/password)
3. Tìm **DHCP Reservation** hoặc **Static IP**
4. Thêm MAC address của máy: `f4:0f:24:34:81:14`
5. Gán IP cố định: `localhost`
6. **Save** và **Restart Router**

### Bước 3: Khởi động dự án với IP cố định
```bash
cd /Users/maybe/Documents/shopee
./start-permanent-ip.sh
```

## 🎯 KẾT QUẢ MONG ĐỢI
- ✅ IP `localhost` sẽ KHÔNG BAO GIỜ thay đổi
- ✅ Khởi động lại máy vẫn giữ nguyên IP
- ✅ Dự án hoạt động ổn định mãi mãi
- ✅ Không cần cập nhật IP nữa

## 🔧 BACKUP PLAN
Nếu IP vẫn thay đổi, chạy:
```bash
# Tự động cập nhật IP mỗi 5 phút
crontab -e
# Thêm dòng:
*/5 * * * * cd /Users/maybe/Documents/shopee && ./daily-ip-update.sh
```

## ⚠️ LƯU Ý QUAN TRỌNG
- **PHẢI** cố định IP trên cả máy macOS VÀ router
- Nếu chỉ cố định trên máy mà không cố định trên router → IP vẫn có thể thay đổi
- Router DHCP có thể gán IP khác cho máy bạn

## 🚀 SAU KHI CỐ ĐỊNH IP
Dự án sẽ hoạt động ổn định và bạn có thể:
- Phát triển tính năng mới
- Test và debug
- Deploy production
- Hoàn thành dự án mà không lo IP thay đổi!
