# 🔒 HƯỚNG DẪN TRUST SSL CERTIFICATES

## 🚨 Vấn đề hiện tại:
- Backend: https://localhost:8000 ✅ (đã trust)
- Frontend: https://localhost:5173 ❌ (chưa trust)

## 🔧 Giải pháp:

### **Cách 1: Trust trong Browser (Nhanh nhất)**

1. **Truy cập https://localhost:5173**
2. **Click "Advanced" → "Proceed to localhost (unsafe)"**
3. **Refresh trang**

### **Cách 2: Trust Certificate trong macOS (Vĩnh viễn)**

```bash
# Trust frontend certificate
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /Users/maybe/Documents/shopee/frontend/cert.pem

# Trust backend certificate (nếu chưa)
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /Users/maybe/Documents/shopee/backend/cert.pem
```

### **Cách 3: Trust qua Keychain Access**

1. **Mở Keychain Access:**
   ```bash
   open /Applications/Utilities/Keychain\ Access.app
   ```

2. **Import certificates:**
   - File → Import Items
   - Chọn `/Users/maybe/Documents/shopee/frontend/cert.pem`
   - Chọn `/Users/maybe/Documents/shopee/backend/cert.pem`
   - Double-click certificate → Trust → Always Trust

## 🧪 Test sau khi trust:

```bash
# Test frontend
curl https://localhost:5173 | head -c 100

# Test backend  
curl https://localhost:8000/api/auth/login -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}'
```

## 📝 Lưu ý:
- Cần trust cả 2 certificates (frontend và backend)
- Frontend certificate: `/Users/maybe/Documents/shopee/frontend/cert.pem`
- Backend certificate: `/Users/maybe/Documents/shopee/backend/cert.pem`
- Sau khi trust, login sẽ hoạt động bình thường

## 🎯 Kết quả mong đợi:
- Không còn lỗi `ERR_CERT_AUTHORITY_INVALID`
- Login thành công với admin/admin123
- Tất cả API calls hoạt động
- QR codes load được
- Admin dashboard hoạt động đầy đủ
