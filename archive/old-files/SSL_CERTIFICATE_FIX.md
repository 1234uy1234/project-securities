# 🔐 HƯỚNG DẪN SỬA LỖI SSL CERTIFICATE

## 🐛 Vấn đề
Browser hiển thị lỗi: `ERR_CERT_AUTHORITY_INVALID` khi truy cập API
- Frontend: https://localhost:5173 ✅ Hoạt động
- Backend: https://localhost:8000/api ❌ SSL Certificate không được trust

## ✅ Đã sửa
- ✅ Tạo SSL certificate mới với IP đúng: `localhost`
- ✅ Restart backend với certificate mới
- ✅ API hoạt động: `curl -k` thành công

## 🔧 Cách sửa cho Browser

### 1. Chrome/Edge (Windows/Mac)
1. Truy cập: https://localhost:8000/api/auth/login
2. Click "Advanced" → "Proceed to localhost (unsafe)"
3. Hoặc click "Continue to this website (not recommended)"

### 2. Firefox
1. Truy cập: https://localhost:8000/api/auth/login
2. Click "Advanced" → "Accept the Risk and Continue"

### 3. Safari (Mac)
1. Truy cập: https://localhost:8000/api/auth/login
2. Click "Show Details" → "visit this website"

### 4. Cốc Cốc Browser
1. Truy cập: https://localhost:8000/api/auth/login
2. Click "Tiếp tục truy cập" hoặc "Advanced" → "Proceed"

## 🚀 Test sau khi trust certificate

### 1. Test API trực tiếp
```bash
curl -k https://localhost:8000/api/auth/login -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### 2. Test Frontend
- Truy cập: https://localhost:5173
- Login với: admin/admin123
- Kiểm tra Admin Dashboard

### 3. Test Admin Dashboard
- Truy cập: https://localhost:5173/admin-dashboard
- Kiểm tra xem có load được data không

## 📱 URLs hoạt động

### Frontend
- **PWA**: https://localhost:5173
- **Login**: https://localhost:5173/login
- **Admin Dashboard**: https://localhost:5173/admin-dashboard
- **Reports**: https://localhost:5173/reports

### Backend API
- **API Base**: https://localhost:8000/api
- **Login**: https://localhost:8000/api/auth/login
- **Patrol Records**: https://localhost:8000/api/reports/patrol-records
- **Admin Records**: https://localhost:8000/api/checkin/admin/all-records

## 🔍 Troubleshooting

### Nếu vẫn có lỗi SSL:
1. **Clear browser cache**: Ctrl+Shift+Delete
2. **Restart browser**
3. **Try incognito/private mode**
4. **Check firewall**: Port 8000 phải mở

### Nếu API không hoạt động:
```bash
# Check backend status
ps aux | grep uvicorn

# Check logs
tail -f backend.log

# Test API
curl -k https://localhost:8000/api/auth/login
```

## ⚠️ Lưu ý quan trọng

1. **Certificate là self-signed** - Browser sẽ cảnh báo
2. **Cần trust certificate** cho mỗi browser
3. **Dữ liệu hoàn toàn nguyên vẹn** - Chỉ là vấn đề SSL
4. **API hoạt động bình thường** sau khi trust certificate

## 🎯 Kết luận

**VẤN ĐỀ CHỈ LÀ SSL CERTIFICATE!**

- ✅ **Dữ liệu**: Hoàn toàn nguyên vẹn (20 records, 3 tasks, 7 users, 5 locations)
- ✅ **API**: Hoạt động bình thường
- ✅ **Frontend**: Hoạt động bình thường
- ⚠️ **SSL**: Cần trust certificate trong browser

**Sau khi trust certificate, hệ thống sẽ hoạt động hoàn toàn bình thường!** 🎉

---
*SSL Certificate fix completed! 🔐*

