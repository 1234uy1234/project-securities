# 🔄 Hướng Dẫn Đổi IP Hàng Ngày

## 🎯 **Tổng Quan**
Khi IP máy tính thay đổi, bạn cần cập nhật IP trong các file sau để hệ thống hoạt động bình thường.

## 📁 **Danh Sách File Cần Đổi IP**

### **1. 🔧 Backend Files (Quan trọng nhất)**

#### **`backend/app/config.py`**
```python
# CORS settings
allowed_origins: list = [
    "https://[IP_MỚI]:5173",
    "https://[IP_MỚI]:5174", 
    "https://[IP_MỚI]:5175",
    "https://[IP_MỚI]:8000",
    "http://[IP_MỚI]:5173",
    "http://[IP_MỚI]:5174",
    "http://[IP_MỚI]:5175", 
    "http://[IP_MỚI]:8000",
]

# Frontend base URL
frontend_base_url: str = "https://[IP_MỚI]:5173"
```

#### **`backend/app.py`**
```python
# CORS origins
origins = [
    "https://[IP_MỚI]:5173",
    "https://[IP_MỚI]:5174",
    "https://[IP_MỚI]:5175",
    "https://[IP_MỚI]:8000",
    "http://[IP_MỚI]:5173",
    "http://[IP_MỚI]:5174", 
    "http://[IP_MỚI]:5175",
    "http://[IP_MỚI]:8000",
]
```

### **2. 🎨 Frontend Files**

#### **`frontend/config.js`**
```javascript
export const config = {
  API_BASE_URL: 'https://[IP_MỚI]:8000',
  // ...
}
```

#### **`frontend/vite.config.https.ts`**
```typescript
const backendUrl = env.VITE_API_BASE_URL || 'https://[IP_MỚI]:8000'
```

#### **`frontend/vite.config.http.ts`**
```typescript
const backendUrl = env.VITE_API_BASE_URL || 'http://[IP_MỚI]:8000'
```

#### **`frontend/vite.config.ts`**
```typescript
const backendUrl = env.VITE_API_BASE_URL || 'https://[IP_MỚI]:8000'
```

### **3. 🚀 Script Files**

#### **Start Scripts:**
- `start-https.sh`
- `start-http.sh` 
- `start-frontend-https.sh`
- `start-backend-https.sh`
- `start-app.sh`
- `start-app-simple.sh`
- `start-app-fixed.sh`
- `start-final.sh`
- `start-for-users.sh`

#### **Run Scripts:**
- `run-https.sh`
- `run-http.sh`
- `run-frontend.sh`
- `run-backend.sh`

#### **Final Scripts:**
- `final-start-https.sh`

### **4. 🐳 Docker Files**

#### **`docker-compose.yml`**
```yaml
environment:
  - VITE_API_BASE_URL=https://[IP_MỚI]:8000
```

## 🛠️ **Cách Đổi IP Tự Động**

### **Phương pháp 1: Sử dụng script có sẵn**
```bash
# Chạy script tự động
./update-all-ip.sh [IP_MỚI]

# Ví dụ:
./update-all-ip.sh 192.168.1.100
```

### **Phương pháp 2: Sử dụng sed command**
```bash
# Thay thế tất cả IP cũ bằng IP mới
OLD_IP="localhost"
NEW_IP="192.168.1.100"

# Cập nhật tất cả file
find . -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" -o -name "*.yml" -o -name "*.md" | xargs sed -i "s/$OLD_IP/$NEW_IP/g"
```

### **Phương pháp 3: Sử dụng script auto-detect**
```bash
# Tạo script auto-detect IP
cat > auto-update-ip.sh << 'EOF'
#!/bin/bash
NEW_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
echo "🔍 Phát hiện IP mới: $NEW_IP"
./update-all-ip.sh $NEW_IP
EOF

chmod +x auto-update-ip.sh
./auto-update-ip.sh
```

## 🔍 **Kiểm Tra Sau Khi Đổi IP**

### **1. Kiểm tra backend:**
```bash
# Khởi động backend
cd backend && source venv/bin/activate && python app.py

# Test API
curl -k https://[IP_MỚI]:8000/health
```

### **2. Kiểm tra frontend:**
```bash
# Khởi động frontend
cd frontend && npm run dev

# Test frontend
curl -k https://[IP_MỚI]:5173
```

### **3. Kiểm tra kết nối:**
```bash
# Test từ browser
https://[IP_MỚI]:5173
https://[IP_MỚI]:8000/health
```

## ⚠️ **Lưu Ý Quan Trọng**

### **1. Thứ tự ưu tiên:**
1. **Backend config** (`backend/app/config.py`) - Quan trọng nhất
2. **Frontend config** (`frontend/config.js`) - Quan trọng thứ 2
3. **Vite configs** - Quan trọng thứ 3
4. **Script files** - Có thể bỏ qua nếu không dùng

### **2. CORS Issues:**
- Nếu gặp lỗi CORS, kiểm tra `backend/app/config.py`
- Đảm bảo IP mới có trong `allowed_origins`

### **3. SSL Issues:**
- Nếu dùng HTTPS, đảm bảo SSL certificate hợp lệ
- Có thể cần tạo lại SSL certificate cho IP mới

### **4. Cache Issues:**
- Clear browser cache sau khi đổi IP
- Restart browser nếu cần

## 🚨 **Troubleshooting**

### **Lỗi CORS:**
```bash
# Kiểm tra CORS config
grep -r "allowed_origins" backend/app/config.py
```

### **Lỗi kết nối API:**
```bash
# Kiểm tra API URL
grep -r "API_BASE_URL" frontend/config.js
```

### **Lỗi SSL:**
```bash
# Tạo lại SSL certificate
./generate-ssl.sh [IP_MỚI]
```

## 📝 **Checklist Đổi IP**

- [ ] 1. Lấy IP mới: `ifconfig | grep "inet "`
- [ ] 2. Chạy script: `./update-all-ip.sh [IP_MỚI]`
- [ ] 3. Kiểm tra backend: `curl -k https://[IP_MỚI]:8000/health`
- [ ] 4. Kiểm tra frontend: `curl -k https://[IP_MỚI]:5173`
- [ ] 5. Test từ browser
- [ ] 6. Test chức năng đăng nhập
- [ ] 7. Test chức năng chấm công
- [ ] 8. Test admin dashboard

## 🎉 **Kết Luận**

**Với script `update-all-ip.sh`, việc đổi IP trở nên đơn giản:**
```bash
./update-all-ip.sh [IP_MỚI]
```

**Chỉ cần 1 lệnh để cập nhật tất cả file!** 🚀
