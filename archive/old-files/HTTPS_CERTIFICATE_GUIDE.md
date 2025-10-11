# 🔒 Hướng Dẫn Trust Certificate cho PWA

## ⚠️ Vấn đề
HTTPS với self-signed certificate bị browser chặn, không thể cài đặt PWA.

## ✅ Giải pháp

### 📱 Android (Chrome)
1. Truy cập: `https://localhost:5174`
2. Nhấn "Advanced" → "Proceed to localhost (unsafe)"
3. Sau đó cài đặt PWA bình thường

### 📱 Android (Samsung Internet)
1. Truy cập: `https://localhost:5174`
2. Nhấn "Advanced" → "Continue to localhost"
3. Sau đó cài đặt PWA bình thường

### 📱 iOS (Safari)
1. Truy cập: `https://localhost:5174`
2. Nhấn "Advanced" → "Proceed to localhost"
3. Sau đó cài đặt PWA bình thường

### 💻 Desktop (Chrome/Edge)
1. Truy cập: `https://localhost:5174`
2. Nhấn "Advanced" → "Proceed to localhost (unsafe)"
3. Sau đó cài đặt PWA bình thường

## 🔧 Alternative: HTTP Mode

Nếu HTTPS vẫn không hoạt động, có thể chạy HTTP:

### Start HTTP Mode
```bash
cd frontend
npm run dev -- --host 0.0.0.0 --port 5174
```

### Install PWA on HTTP
- URL: `http://localhost:5174`
- PWA sẽ hoạt động trên HTTP (ít bảo mật hơn)

## 🎯 Steps để cài đặt PWA

1. **Trust certificate** (theo hướng dẫn trên)
2. **Truy cập**: `https://localhost:5174`
3. **Cài đặt PWA**:
   - Android: Menu → "Cài đặt ứng dụng"
   - iOS: Chia sẻ → "Thêm vào màn hình chính"
   - Desktop: Biểu tượng cài đặt

## 🚨 Lưu ý

- **Self-signed certificate** không được trust mặc định
- **Cần trust manual** cho mỗi browser
- **PWA vẫn hoạt động offline** sau khi cài đặt
- **HTTP mode** ít bảo mật nhưng dễ cài đặt hơn

## 🔄 Troubleshooting

### Nếu vẫn không cài được:
1. Thử HTTP mode
2. Thử browser khác
3. Thử thiết bị khác
4. Kiểm tra firewall/antivirus

### Test PWA:
1. Cài đặt thành công
2. Tắt mạng
3. Mở app (vẫn hoạt động)
4. Test offline features
