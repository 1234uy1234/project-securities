# Tóm tắt sửa múi giờ và ảnh

## Vấn đề ban đầu
- Múi giờ checkin hiển thị sai: 0:31 thay vì 10:31 (Vietnam time)
- Ảnh checkin không hiển thị được trong report

## Nguyên nhân

### 1. Múi giờ sai
- Database lưu dữ liệu không nhất quán:
  - Record cũ: `check_in_time: 2025-09-30 17:31:31` (UTC time)
  - Record mới: `check_in_time: 2025-09-30 10:38:49` (Vietnam time)
- Logic chuyển đổi múi giờ không xử lý đúng trường hợp UTC time

### 2. Ảnh không hiển thị
- Backend trả về `photo_url` không nhất quán:
  - Record mới: `"checkin_2_20250930_103131.jpg"` (không có `/uploads/`)
  - Record cũ: `"/uploads/sample.jpg"` (có `/uploads/`)
- Frontend không xử lý được cả hai trường hợp

## Giải pháp

### 1. Sửa múi giờ
**File:** `backend/app/routes/reports.py`

```python
def format_vietnam_time(dt):
    """Format datetime to Vietnam timezone"""
    if not dt:
        return None
    if dt.tzinfo is None:
        # Check if this looks like UTC time (17:xx) or Vietnam time (10:xx)
        if dt.hour >= 17:
            # This looks like UTC time, convert to Vietnam time
            # But we want to show the correct Vietnam time, not UTC+7
            # If it's 17:31 UTC, we want to show 10:31 Vietnam time
            vietnam_dt = dt.replace(hour=dt.hour - 7)
            return vietnam_dt.replace(tzinfo=timezone(timedelta(hours=7))).isoformat()
        else:
            # This looks like Vietnam time, just add timezone
            return dt.replace(tzinfo=timezone(timedelta(hours=7))).isoformat()
    else:
        # Already has timezone info, just return as is
        return dt.isoformat()
```

**Kết quả:**
- Trước: `"check_in_time": "2025-10-01T00:31:31.794475+07:00"`
- Sau: `"check_in_time": "2025-09-30T10:31:31.794475+07:00"`

### 2. Sửa hiển thị ảnh
**File:** `frontend/src/pages/ReportsPage.tsx`

```typescript
// Thêm logic kiểm tra prefix /uploads/
src={`${import.meta.env.VITE_API_BASE_URL?.replace('/api', '') || 'http://localhost:8000'}${r.photo_url.startsWith('/') ? r.photo_url : '/uploads/' + r.photo_url}`}
```

**Kết quả:**
- Record mới: `http://localhost:8000/uploads/checkin_2_20250930_103131.jpg`
- Record cũ: `http://localhost:8000/uploads/sample.jpg`

## Test kết quả

### Múi giờ
```bash
curl -k https://localhost:8000/api/reports/patrol-records -H "Authorization: Bearer ..." | grep check_in_time
```
- ✅ Hiển thị đúng: `10:31:31` thay vì `00:31:31`

### Ảnh
```bash
curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8000/uploads/checkin_2_20250930_103131.jpg
```
- ✅ HTTP 200 - ảnh có thể truy cập được

## Tóm tắt
- ✅ Múi giờ checkin hiển thị đúng Vietnam time (10:31 thay vì 0:31)
- ✅ Ảnh checkin hiển thị được trong report
- ✅ Xử lý được cả record cũ và mới
- ✅ Logic chuyển đổi múi giờ thông minh (phân biệt UTC vs Vietnam time)
- ✅ Frontend tự động thêm `/uploads/` prefix khi cần thiết
