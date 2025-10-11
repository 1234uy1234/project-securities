# 🦊 Hướng dẫn cài PWA trên Cốc Cốc (Mac)

## 📱 Cách cài PWA trên Cốc Cốc Mac:

### **Phương pháp 1: Menu Cốc Cốc**
1. **Click menu ☰** (3 gạch ngang) ở góc trên bên phải
2. **Chọn "Cài đặt"** (Install)
3. **Chọn "Cài đặt ứng dụng"** (Install App)
4. **Click "Cài đặt"** trong popup xác nhận

### **Phương pháp 2: Icon trên thanh địa chỉ**
1. **Tìm icon "Cài đặt"** (hình vuông với dấu +) trên thanh địa chỉ
2. **Click vào icon đó**
3. **Chọn "Cài đặt ứng dụng"**
4. **Click "Cài đặt"** trong popup xác nhận

### **Phương pháp 3: Shortcut bàn phím**
1. **Nhấn `Cmd + Shift + I`** để mở Developer Tools
2. **Click tab "Application"** (Ứng dụng)
3. **Click "Manifest"** ở sidebar trái
4. **Click "Install"** button

## 🔧 Troubleshooting:

### **Nếu không thấy icon "Cài đặt":**
- **Reload trang** (F5 hoặc Cmd+R)
- **Đợi vài giây** để PWA load xong
- **Kiểm tra HTTPS** (phải có khóa xanh)

### **Nếu menu không có "Cài đặt":**
- **Cập nhật Cốc Cốc** lên phiên bản mới nhất
- **Thử phương pháp 2** (icon trên thanh địa chỉ)

### **Nếu vẫn không cài được:**
- **Thử Chrome** hoặc **Safari** thay thế
- **Kiểm tra firewall** có chặn không
- **Thử mạng khác** (4G thay vì WiFi)

## ✅ Sau khi cài xong:

### **App sẽ xuất hiện:**
- **Trên Desktop** (macOS)
- **Trong Applications** folder
- **Trong Dock** (nếu chọn)

### **Mở app:**
- **Double-click** icon trên Desktop
- **Click** icon trong Applications
- **Click** icon trong Dock

## 🎯 Lưu ý quan trọng:

1. **HTTPS bắt buộc**: PWA chỉ hoạt động với HTTPS
2. **Cốc Cốc mới**: Cần phiên bản Cốc Cốc hỗ trợ PWA
3. **macOS mới**: Cần macOS 10.14+ để cài PWA
4. **Internet**: Cần kết nối internet để cài lần đầu

## 🚀 Test PWA:

### **Kiểm tra PWA status:**
```
https://localhost:5173/
```

### **Test PWA install:**
```
http://localhost:8080/test-pwa-install.html
```

---

**💡 Tip**: Nếu vẫn không cài được, hãy thử Chrome hoặc Safari để test PWA trước!
