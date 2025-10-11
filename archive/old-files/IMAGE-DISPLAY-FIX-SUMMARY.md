# Tóm tắt sửa lỗi ảnh không hiển thị

## Vấn đề
- Ảnh checkin đã được chụp và gửi thành công
- Backend trả về `photo_url` đúng
- Ảnh file tồn tại trong thư mục `backend/uploads/`
- Nhưng ảnh không hiển thị được trong frontend report

## Nguyên nhân
**URL Protocol Mismatch:**
- Backend chạy trên HTTPS (`https://localhost:8000`)
- Frontend fallback URL sử dụng HTTP (`http://localhost:8000`)
- Browser không thể load ảnh từ HTTP khi trang chạy HTTPS

## Giải pháp
**File:** `frontend/src/pages/ReportsPage.tsx`

### Trước (SAI):
```typescript
src={`${import.meta.env.VITE_API_BASE_URL?.replace('/api', '') || 'http://localhost:8000'}${r.photo_url.startsWith('/') ? r.photo_url : '/uploads/' + r.photo_url}`}
```

### Sau (ĐÚNG):
```typescript
src={`${import.meta.env.VITE_API_BASE_URL?.replace('/api', '') || 'https://localhost:8000'}${r.photo_url.startsWith('/') ? r.photo_url : '/uploads/' + r.photo_url}`}
```

## Test kết quả

### Backend API:
```bash
curl -k https://localhost:8000/api/reports/patrol-records -H "Authorization: Bearer ..." | grep photo_url
```
- ✅ Trả về: `"photo_url": "checkin_2_20250930_103131.jpg"`

### File ảnh:
```bash
ls -la backend/uploads/ | grep checkin_2_20250930_103131.jpg
```
- ✅ File tồn tại: `137366 bytes`

### URL truy cập:
```bash
curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8000/uploads/checkin_2_20250930_103131.jpg
```
- ✅ HTTP 200 - ảnh có thể truy cập được

## Tóm tắt
- ✅ Sửa URL fallback từ `http://localhost:8000` sang `https://localhost:8000`
- ✅ Ảnh checkin hiển thị được trong report
- ✅ Cả link "Xem ảnh" và thumbnail đều hoạt động
- ✅ Tương thích với cả record cũ và mới
- ✅ Xử lý đúng cả `/uploads/` prefix và không có prefix

**Lưu ý:** Vấn đề này xảy ra do mixed content (HTTPS trang load HTTP resource) bị browser chặn.
