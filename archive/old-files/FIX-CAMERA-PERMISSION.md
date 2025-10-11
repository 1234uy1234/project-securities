# 🔧 Hướng Dẫn Fix Camera Permission

## 🚨 Vấn đề: Camera không hoạt động hoặc không lưu ảnh

### 🔍 Nguyên nhân có thể:
1. **Camera permission bị từ chối**
2. **HTTPS requirement không đáp ứng**
3. **Browser security policy**
4. **Camera đang được sử dụng bởi ứng dụng khác**

### 🛠️ Cách khắc phục:

#### 1. **Kiểm tra Camera Permission**
```bash
# Mở file test trong browser:
file:///Users/maybe/Documents/shopee/test-camera-permission.html
```

#### 2. **Cho phép Camera trong Browser**
- **Chrome/Edge**: Click vào icon camera trên thanh địa chỉ → Allow
- **Firefox**: Click vào icon camera → Allow
- **Safari**: Safari → Preferences → Websites → Camera → Allow

#### 3. **Reset Camera Permission**
- **Chrome**: Settings → Privacy → Site Settings → Camera → Reset
- **Firefox**: about:preferences#privacy → Permissions → Camera → Remove
- **Safari**: Safari → Preferences → Websites → Camera → Remove All

#### 4. **Kiểm tra HTTPS**
- Đảm bảo ứng dụng chạy trên HTTPS
- Frontend: https://localhost:5173
- Backend: https://localhost:8000

#### 5. **Test Camera**
```bash
# Mở file debug camera:
file:///Users/maybe/Documents/shopee/debug-camera-permission.html
```

### 🎯 **Các bước test:**
1. Mở file test-camera-permission.html
2. Cho phép camera khi browser hỏi
3. Kiểm tra xem camera có hoạt động không
4. Nếu OK, thử chụp ảnh trong ứng dụng chính

### 🚀 **Sau khi fix:**
- Camera sẽ hoạt động bình thường
- Ảnh sẽ được lưu vào database
- Báo cáo sẽ hiển thị ảnh đúng

### 💡 **Lưu ý:**
- Camera chỉ hoạt động trên HTTPS
- Cần permission từ user
- Không thể sử dụng camera trên HTTP (trừ localhost)
