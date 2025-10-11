# 📱 PWA App - MANHTOAN PLASTIC

## 🎯 Tổng quan

Hệ thống đã được chuyển đổi thành **Progressive Web App (PWA)**, cho phép cài đặt như app native trên điện thoại và hoạt động offline hoàn toàn.

## ✅ Tính năng PWA

### 📱 Cài đặt như App Native
- **Android**: Cài đặt từ Chrome/Samsung Internet
- **iOS**: Thêm vào màn hình chính từ Safari
- **Desktop**: Cài đặt từ Chrome/Edge/Safari
- **Không cần App Store**: Cài đặt trực tiếp từ web

### 🔄 Hoạt động Offline
- **Chấm công offline**: Quét QR và chụp ảnh khi không có mạng
- **Tự động sync**: Sync dữ liệu khi có mạng
- **Không mất dữ liệu**: Tất cả được lưu trong IndexedDB
- **Background sync**: Sync ngay cả khi app đã đóng

### 🎨 Giao diện Native
- **Standalone mode**: Chạy như app thật
- **Responsive design**: Tối ưu cho mobile
- **Touch-friendly**: Giao diện thân thiện với cảm ứng
- **Fast loading**: Cache thông minh

## 🚀 Cách cài đặt

### 📱 Android (Chrome)
1. Mở Chrome trên điện thoại
2. Truy cập: `https://localhost:3000`
3. Nhấn menu (3 chấm) → "Cài đặt ứng dụng"
4. Nhấn "Cài đặt"
5. App xuất hiện trên màn hình chính

### 📱 Android (Samsung Internet)
1. Mở Samsung Internet
2. Truy cập: `https://localhost:3000`
3. Nhấn menu → "Thêm vào màn hình chính"
4. Nhấn "Thêm"

### 📱 iOS (Safari)
1. Mở Safari trên iPhone/iPad
2. Truy cập: `https://localhost:3000`
3. Nhấn biểu tượng chia sẻ (hộp với mũi tên)
4. Chọn "Thêm vào màn hình chính"
5. Nhấn "Thêm"

### 💻 Desktop (Chrome/Edge)
1. Mở Chrome hoặc Edge
2. Truy cập: `https://localhost:3000`
3. Nhấn biểu tượng cài đặt (dấu +) trên thanh địa chỉ
4. Chọn "Cài đặt ứng dụng"

## 🔄 Khi IP thay đổi

### ⚠️ Vấn đề
- App đã cài đặt sẽ không hoạt động khi IP thay đổi
- Cần cập nhật app với IP mới

### ✅ Giải pháp
1. **Cập nhật IP**:
   ```bash
   python3 update_pwa_ip.py NEW_IP
   ```

2. **Hướng dẫn users**:
   - Xóa app cũ khỏi màn hình chính
   - Truy cập IP mới: `https://IP_MỚI:3000`
   - Cài đặt lại app
   - Hoặc quét QR code mới

## 🛠️ Quản lý PWA

### 🔧 Scripts có sẵn

1. **`setup_pwa.py`** - Setup PWA ban đầu:
   ```bash
   python3 setup_pwa.py
   ```

2. **`update_pwa_ip.py`** - Cập nhật IP:
   ```bash
   python3 update_pwa_ip.py 192.168.1.100
   ```

3. **`start_pwa_services.py`** - Start services:
   ```bash
   python3 start_pwa_services.py
   ```

### 📊 Files được tạo
- `PWA_INSTALL_GUIDE.md` - Hướng dẫn cài đặt
- `pwa_install_qr_*.png` - QR code để cài đặt
- `IP_UPDATE_NOTIFICATION_*.txt` - Thông báo cập nhật IP

## 📱 Tính năng App

### ✅ Hoạt động Offline
- **QR Scanner**: Quét QR code offline
- **Camera**: Chụp ảnh offline
- **Check-in**: Chấm công offline
- **Data Storage**: Lưu trong IndexedDB
- **Auto Sync**: Sync khi có mạng

### ✅ Tính năng chính
- **Quét QR code**: Scanner offline
- **Chụp ảnh**: Camera offline
- **Chấm công**: Check-in offline
- **Xem nhiệm vụ**: Tasks offline
- **Báo cáo**: Reports offline
- **Face login**: Đăng nhập bằng khuôn mặt

### ✅ Sync thông minh
- **Auto sync**: Tự động khi online
- **Background sync**: Sync khi app đóng
- **Periodic sync**: Kiểm tra mỗi 30 giây
- **Error handling**: Xử lý lỗi và retry
- **Notifications**: Thông báo sync

## 🔍 Debug & Test

### DevTools Console
```javascript
// Kiểm tra Service Worker
navigator.serviceWorker.ready.then(reg => console.log('SW:', reg))

// Kiểm tra offline queue
// F12 -> Application -> IndexedDB -> OfflineQueueDB

// Kiểm tra cache
caches.keys().then(names => console.log('Caches:', names))
```

### Test Offline
1. Cài đặt app
2. Tắt WiFi/Mobile data
3. Mở app (vẫn hoạt động)
4. Quét QR và chấm công
5. Bật mạng
6. Kiểm tra sync

## 📊 Performance

### Cache Size
- **Static Assets**: ~2MB
- **API Cache**: Dynamic
- **Offline Queue**: ~1KB per check-in

### Sync Performance
- **Auto Sync**: < 2 seconds
- **Periodic Sync**: Every 30 seconds
- **Background Sync**: When app becomes active

## ⚠️ Lưu ý quan trọng

### Browser Support
- ✅ **Chrome/Edge**: Full support
- ✅ **Firefox**: Full support
- ✅ **Safari**: Limited support (no background sync)
- ✅ **Mobile browsers**: Full support

### Requirements
- **HTTPS**: App chỉ hoạt động với HTTPS
- **Certificate**: Cần trust certificate khi truy cập lần đầu
- **Modern Browser**: Cần browser hỗ trợ PWA

### IP Management
- **IP thay đổi**: Cần cài đặt lại app
- **QR Code**: Tạo QR code mới cho IP mới
- **Notification**: Thông báo users về IP mới

## 🎉 Kết quả

**Với PWA, bạn có:**
- ✅ **App native** trên điện thoại
- ✅ **Hoạt động offline** hoàn toàn
- ✅ **Không cần App Store**
- ✅ **Cài đặt nhanh** từ web
- ✅ **Sync tự động** khi có mạng
- ✅ **Không mất dữ liệu**

**PWA đã sẵn sàng sử dụng!**
