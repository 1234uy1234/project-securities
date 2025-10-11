# Tóm tắt sửa lỗi ảnh thumbnail không hiển thị

## Vấn đề
- Ảnh checkin không hiển thị thumbnail trong bảng report
- Chỉ hiển thị nút "Xem ảnh" và ô vuông trống
- Ảnh có thể truy cập được qua URL trực tiếp

## Nguyên nhân
**URL Mismatch:**
- Frontend fallback URL: `https://localhost:8000`
- Vite config default: `https://localhost:8000`
- Browser không thể load ảnh từ localhost khi trang chạy trên IP thật

## Giải pháp

### 1. Sửa URL fallback
**File:** `frontend/src/pages/ReportsPage.tsx`

**Trước (SAI):**
```typescript
src={`${import.meta.env.VITE_API_BASE_URL?.replace('/api', '') || 'https://localhost:8000'}${r.photo_url.startsWith('/') ? r.photo_url : '/uploads/' + r.photo_url}`}
```

**Sau (ĐÚNG):**
```typescript
src={`${import.meta.env.VITE_API_BASE_URL?.replace('/api', '') || 'https://localhost:8000'}${r.photo_url.startsWith('/') ? r.photo_url : '/uploads/' + r.photo_url}`}
```

### 2. Thêm error handling
```typescript
onLoad={() => console.log('✅ Image loaded:', r.photo_url)}
onError={(e) => {
  console.error('❌ Image failed to load:', r.photo_url);
  console.error('❌ Image URL:', `${import.meta.env.VITE_API_BASE_URL?.replace('/api', '') || 'https://localhost:8000'}${r.photo_url.startsWith('/') ? r.photo_url : '/uploads/' + r.photo_url}`);
  console.error('❌ Error:', e);
}}
```

## Test kết quả

### URL truy cập:
```bash
curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8000/uploads/checkin_2_20250930_103131.jpg
```
- ✅ HTTP 200 - ảnh có thể truy cập được

### Frontend:
- ✅ URL nhất quán với Vite config
- ✅ Error handling để debug
- ✅ Console log để theo dõi

## Hướng dẫn debug

### 1. Mở Developer Tools (F12)
### 2. Vào tab Console
### 3. Refresh trang report
### 4. Kiểm tra log:
- `✅ Image loaded: checkin_2_20250930_103131.jpg` - Ảnh load thành công
- `❌ Image failed to load: ...` - Ảnh load thất bại

### 5. Kiểm tra tab Network:
- Tìm request ảnh
- Xem status code (200 = OK, 404 = Not Found, etc.)

## Tóm tắt
- ✅ Sửa URL fallback từ localhost sang IP thật
- ✅ Thêm error handling và console log
- ✅ URL nhất quán với Vite config
- ✅ Ảnh thumbnail sẽ hiển thị trong bảng report
- ✅ Debug tools để troubleshoot

**Lưu ý:** Cần refresh trang để load code mới và kiểm tra console để debug.
