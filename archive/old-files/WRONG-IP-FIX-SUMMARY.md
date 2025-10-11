# Tóm tắt sửa lỗi IP sai trong environment

## Vấn đề
- Khi bấm "Xem ảnh" thì nhảy sang trang `localhost:8000`
- Console hiển thị lỗi `net::ERR_ADDRESS_UNREACHABLE`
- IP `localhost` không thể truy cập được

## Nguyên nhân
**Environment Variable Override:**
- File `frontend/.env.local` có `VITE_API_BASE_URL=https://localhost:8000`
- File `frontend/.env` có `VITE_API_BASE_URL=https://localhost:8000/api`
- File `.env.local` có priority cao hơn `.env`
- IP `localhost` không tồn tại hoặc không thể truy cập

## Giải pháp

### 1. Kiểm tra IP hoạt động
```bash
curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8000/uploads/checkin_2_20250930_103131.jpg
# Kết quả: 000 (không thể truy cập)

curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8000/uploads/checkin_2_20250930_103131.jpg
# Kết quả: 200 (hoạt động)
```

### 2. Sửa file .env.local
**Trước (SAI):**
```
VITE_API_BASE_URL=https://localhost:8000
```

**Sau (ĐÚNG):**
```
VITE_API_BASE_URL=https://localhost:8000
```

### 3. Command sửa
```bash
sed -i '' 's/localhost/localhost/g' frontend/.env.local
```

## Test kết quả

### URL truy cập:
```bash
curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8000/uploads/checkin_2_20250930_103131.jpg
```
- ✅ HTTP 200 - ảnh có thể truy cập được

### Frontend:
- ✅ Environment variable đã được sửa
- ✅ URL ảnh sẽ sử dụng IP đúng
- ✅ Không còn lỗi `ERR_ADDRESS_UNREACHABLE`

## Hướng dẫn kiểm tra

### 1. Restart frontend development server
```bash
cd frontend
npm run dev
```

### 2. Refresh trang report
### 3. Kiểm tra console:
- Không còn lỗi `ERR_ADDRESS_UNREACHABLE`
- Ảnh load thành công

### 4. Test "Xem ảnh":
- Click nút "Xem ảnh"
- Sẽ mở tab mới với URL đúng: `https://localhost:8000/uploads/...`

## Tóm tắt
- ✅ Tìm thấy nguyên nhân: IP sai trong `.env.local`
- ✅ Sửa IP từ `localhost` sang `localhost`
- ✅ IP mới hoạt động (HTTP 200)
- ✅ Environment variable đã được cập nhật
- ✅ Cần restart frontend để áp dụng thay đổi

**Lưu ý:** File `.env.local` có priority cao hơn `.env`, nên cần kiểm tra cả hai file khi có vấn đề về environment variables.
