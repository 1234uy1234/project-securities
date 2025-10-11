# 🔧 CÁCH LÀM IP CỐ ĐỊNH

## 📋 Các phương pháp làm IP cố định:

### 🎯 **PHƯƠNG PHÁP 1: Static IP trên Router (KHUYẾN NGHỊ)**

1. **Truy cập Router Admin:**
   - Mở trình duyệt, truy cập: `192.168.1.1` hoặc `192.168.0.1`
   - Đăng nhập với tài khoản admin router

2. **Tìm DHCP Reservation:**
   - Vào **Advanced Settings** → **DHCP** → **DHCP Reservation**
   - Hoặc **Network** → **DHCP** → **Static IP**

3. **Thêm Static IP:**
   - **Device Name:** MacBook của bạn
   - **MAC Address:** `xx:xx:xx:xx:xx:xx` (MAC của máy)
   - **IP Address:** `10.10.68.24` (IP hiện tại)
   - **Save/Apply**

4. **Restart Router:**
   - Restart router để áp dụng cài đặt
   - IP sẽ không đổi nữa!

---

### 🎯 **PHƯƠNG PHÁP 2: Static IP trên Mac**

1. **Mở System Preferences:**
   - **Apple Menu** → **System Preferences** → **Network**

2. **Chọn WiFi Connection:**
   - Click vào WiFi connection
   - Click **Advanced...**

3. **Cấu hình Static IP:**
   - **Configure IPv4:** Manually
   - **IP Address:** `10.10.68.24`
   - **Subnet Mask:** `255.255.255.0`
   - **Router:** `10.10.68.1` (hoặc IP gateway)
   - **DNS:** `8.8.8.8`, `8.8.4.4`

4. **Apply và Test:**
   - Click **Apply**
   - Test kết nối internet

---

### 🎯 **PHƯƠNG PHÁP 3: Dynamic DNS (DDNS)**

1. **Đăng ký DDNS miễn phí:**
   - **No-IP:** https://www.noip.com/
   - **DynDNS:** https://dyn.com/
   - **DuckDNS:** https://www.duckdns.org/

2. **Cấu hình trên Router:**
   - Vào **Advanced** → **DDNS**
   - Nhập thông tin DDNS
   - Router sẽ tự động cập nhật IP

3. **Sử dụng Domain:**
   - Thay vì `10.10.68.24`
   - Dùng `yourname.ddns.net`

---

## 🚀 **KHUYẾN NGHỊ:**

**✅ PHƯƠNG PHÁP 1 (Router Static IP)** - Dễ nhất, hiệu quả nhất
**✅ PHƯƠNG PHÁP 3 (DDNS)** - Tốt nhất cho truy cập từ xa

---

## 📱 **KIỂM TRA:**

Sau khi setup xong:
- **Backend:** http://10.10.68.24:8000
- **Frontend:** http://10.10.68.24:5173
- **Từ điện thoại:** Truy cập http://10.10.68.24:5173

---

## ⚠️ **LƯU Ý:**

- **Router Static IP:** Cần quyền admin router
- **Mac Static IP:** Có thể gây xung đột với DHCP
- **DDNS:** Cần đăng ký và cấu hình router hỗ trợ

