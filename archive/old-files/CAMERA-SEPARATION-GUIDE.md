# 📷 Hướng Dẫn Tách Riêng Camera - QR vs Photo

## 🎯 Vấn đề đã được giải quyết

Trước đây, hệ thống sử dụng chung một camera cho cả quét QR và chụp ảnh, gây ra xung đột permission và lỗi "Camera đang được sử dụng". Bây giờ đã tách riêng thành 2 camera độc lập.

## 🔧 Thay đổi chính

### 1. Tách riêng Camera References
```typescript
// Trước (có vấn đề)
const webcamRef = useRef<Webcam | null>(null)

// Sau (đã sửa)
const qrWebcamRef = useRef<Webcam | null>(null) // Camera riêng cho QR
const photoWebcamRef = useRef<Webcam | null>(null) // Camera riêng cho chụp ảnh
```

### 2. Tách riêng State Management
```typescript
// Trước
const [webcamError, setWebcamError] = useState<string | null>(null)
const [facingMode, setFacingMode] = useState<'user' | 'environment'>('environment')

// Sau
const [qrWebcamError, setQrWebcamError] = useState<string | null>(null)
const [photoWebcamError, setPhotoWebcamError] = useState<string | null>(null)
const [qrFacingMode, setQrFacingMode] = useState<'user' | 'environment'>('environment')
const [photoFacingMode, setPhotoFacingMode] = useState<'user' | 'environment'>('environment')
```

### 3. Tách riêng Permission Checking
```typescript
// QR Camera Permission
const checkQRCameraPermission = async (): Promise<boolean> => {
  // Logic kiểm tra permission riêng cho QR
}

// Photo Camera Permission  
const checkPhotoCameraPermission = async (): Promise<boolean> => {
  // Logic kiểm tra permission riêng cho Photo
}
```

### 4. Tách riêng Error Handling
```typescript
// QR Camera Error Handler
const handleQRWebcamError = (err: any) => {
  // Xử lý lỗi riêng cho QR camera
}

// Photo Camera Error Handler
const handlePhotoWebcamError = (err: any) => {
  // Xử lý lỗi riêng cho Photo camera
}
```

## 🚀 Cách sử dụng

### 1. Test Camera Riêng Biệt
Mở file `test-camera-separated.html` để test:
```bash
# Mở file test trong browser
open test-camera-separated.html
```

### 2. Sử dụng trong QR Scanner Page
1. **Bật QR Camera**: Click "Bật camera" trong phần QR Scanner
2. **Bật Photo Camera**: Click "Bật Camera" trong phần Chụp ảnh xác thực
3. **Chuyển đổi camera**: Mỗi camera có nút chuyển đổi riêng
4. **Tắt camera**: Mỗi camera có thể tắt độc lập

### 3. Lợi ích của việc tách riêng

#### ✅ Tránh xung đột Permission
- QR camera và Photo camera hoạt động độc lập
- Không còn lỗi "Camera đang được sử dụng"
- Permission được quản lý riêng biệt

#### ✅ Tối ưu Performance
- Mỗi camera có settings riêng phù hợp với mục đích
- QR camera: độ phân giải thấp, frame rate cao
- Photo camera: độ phân giải cao, chất lượng tốt

#### ✅ Dễ Debug
- Lỗi camera được phân loại rõ ràng
- Log riêng biệt cho từng camera
- Debug info hiển thị trạng thái từng camera

## 🔍 Camera Settings

### QR Camera Settings
```typescript
videoConstraints: {
  facingMode: qrFacingMode,
  width: { ideal: 640, max: 1280 },
  height: { ideal: 480, max: 720 }
}
```

### Photo Camera Settings
```typescript
videoConstraints: {
  facingMode: photoFacingMode,
  width: { ideal: 1280, max: 1920 },
  height: { ideal: 720, max: 1080 }
}
```

## 🐛 Troubleshooting

### Lỗi "Permission denied"
1. Kiểm tra browser settings
2. Cho phép camera access
3. Refresh trang và thử lại

### Lỗi "Camera đang được sử dụng"
1. Tắt camera khác trước khi bật camera mới
2. Refresh trang nếu vẫn lỗi
3. Kiểm tra ứng dụng khác đang dùng camera

### Camera không hiển thị
1. Kiểm tra console log
2. Thử chuyển đổi camera (trước/sau)
3. Kiểm tra browser compatibility

## 📱 Browser Support

- ✅ Chrome/Chromium
- ✅ Firefox
- ✅ Safari (iOS 11+)
- ✅ Edge
- ❌ Internet Explorer

## 🔧 Development

### Debug Mode
Trong development mode, debug info sẽ hiển thị:
- QR Camera active: Yes/No
- Photo Camera active: Yes/No  
- QR Error: None/Error message
- Photo Error: None/Error message
- Photo captured: Yes/No

### Console Logs
```javascript
// QR Camera logs
console.log('QR Camera started successfully')
console.log('QR Video stream loaded, dimensions:', width, 'x', height)

// Photo Camera logs  
console.log('Photo Camera started successfully')
console.log('Photo Video stream loaded, dimensions:', width, 'x', height)
```

## 🎉 Kết quả

Sau khi tách riêng camera:
- ✅ Không còn lỗi permission conflict
- ✅ QR scanner hoạt động ổn định
- ✅ Photo capture chất lượng cao
- ✅ Dễ dàng debug và maintain
- ✅ User experience tốt hơn

## 📞 Support

Nếu gặp vấn đề, hãy:
1. Kiểm tra console log
2. Test với file `test-camera-separated.html`
3. Kiểm tra browser permissions
4. Thử refresh trang
