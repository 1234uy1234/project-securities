# 🔒 HƯỚNG DẪN TRUST SSL CERTIFICATE CHO LOCALHOST

## ✅ Services đang chạy HTTPS:
- **Backend:** https://localhost:8000
- **Frontend:** https://localhost:5173

## 🚨 Vấn đề: ERR_CERT_AUTHORITY_INVALID

Browser không tin tưởng SSL certificate tự tạo. Cần trust certificate này.

## 🔧 Giải pháp:

### **Cách 1: Trust trong Browser (Nhanh nhất)**

#### **Chrome/Edge:**
1. Truy cập https://localhost:8000
2. Click "Advanced" 
3. Click "Proceed to localhost (unsafe)"
4. Làm tương tự cho https://localhost:5173

#### **Firefox:**
1. Truy cập https://localhost:8000
2. Click "Advanced"
3. Click "Accept the Risk and Continue"
4. Làm tương tự cho https://localhost:5173

#### **Safari:**
1. Truy cập https://localhost:8000
2. Click "Show Details"
3. Click "visit this website"
4. Click "visit this website" lần nữa

### **Cách 2: Trust Certificate trong macOS (Vĩnh viễn)**

```bash
# Mở Keychain Access
open /Applications/Utilities/Keychain\ Access.app

# Import certificate vào System Keychain
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /Users/maybe/Documents/shopee/backend/cert.pem
```

### **Cách 3: Trust Certificate trong Windows (Vĩnh viễn)**

```cmd
# Mở Certificate Manager
certlm.msc

# Import file backend/cert.pem vào "Trusted Root Certification Authorities"
```

## 🧪 Test sau khi trust:

```bash
# Test backend
curl https://localhost:8000/api/auth/login -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"admin123"}'

# Test frontend
open https://localhost:5173
```

## 📝 Lưu ý:
- Certificate được tạo cho `localhost` và `127.0.0.1`
- Có Subject Alternative Name (SAN) cho cả DNS và IP
- Valid trong 365 ngày
- Chỉ cần trust một lần, sau đó sẽ hoạt động bình thường

## 🎯 Kết quả mong đợi:
- Không còn lỗi SSL
- Login thành công
- Tất cả API calls hoạt động
- QR codes load được
- Admin dashboard hoạt động đầy đủ
