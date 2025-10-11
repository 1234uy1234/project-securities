# 🚀 Hướng dẫn chạy hệ thống

## 📋 Tình trạng hiện tại:
- ✅ **Database:** SQLite local - Không cần thay đổi IP
- ✅ **Backend:** Đã cập nhật CORS cho ngrok
- ✅ **Frontend:** Đã cấu hình sử dụng ngrok URL
- ✅ **Ngrok:** Đã cấu hình authtoken

## 🎯 Cách chạy hệ thống:

### **Cách 1: Chạy tự động (Khuyến nghị)**
```bash
./start-with-short-url.sh
```
- ✅ Tự động khởi động ngrok + backend + frontend
- ✅ URL: `https://manhtoan-patrol.ngrok-free.dev`
- ✅ Truy cập từ bất kỳ đâu

### **Cách 2: Chạy thủ công từng bước**

#### **Bước 1: Khởi động ngrok**
```bash
ngrok http 8000 --domain=manhtoan-patrol.ngrok-free.dev
```
- Giữ terminal này mở
- URL: `https://manhtoan-patrol.ngrok-free.dev`

#### **Bước 2: Cập nhật .env**
```bash
echo "NGROK_URL=https://manhtoan-patrol.ngrok-free.dev" > .env
echo "VITE_API_URL=https://manhtoan-patrol.ngrok-free.dev" >> .env
```

#### **Bước 3: Khởi động backend**
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

#### **Bước 4: Khởi động frontend (terminal mới)**
```bash
cd frontend
npm run dev
```

### **Cách 3: Chạy local (không cần ngrok)**
```bash
./start-local.sh
```
- ✅ Chỉ hoạt động trên máy tính
- ❌ Không thể truy cập từ điện thoại

## 📱 Truy cập hệ thống:

### **Với ngrok (Cách 1 & 2):**
- **Máy tính:** `https://manhtoan-patrol.ngrok-free.dev`
- **Điện thoại:** `https://manhtoan-patrol.ngrok-free.dev`
- **Mạng khác:** `https://manhtoan-patrol.ngrok-free.dev`

### **Với local (Cách 3):**
- **Máy tính:** `http://localhost:5173`
- **Điện thoại:** ❌ Không thể truy cập

## 🔧 Troubleshooting:

### Lỗi: "ngrok domain not found"
```bash
# Thử với domain khác
ngrok http 8000 --domain=mt-patrol.ngrok-free.dev
```

### Lỗi: "CORS error"
- Backend đã được cập nhật CORS cho ngrok
- Restart backend nếu cần

### Lỗi: "npm run dev not found"
```bash
cd frontend
npm install
npm run dev
```

### Lỗi: "python not found"
```bash
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 💡 Lưu ý:

- **Database:** SQLite local, không cần thay đổi
- **URL ngrok:** Thay đổi mỗi lần khởi động (trừ khi có tài khoản trả phí)
- **Để dừng:** Nhấn `Ctrl+C` trong terminal chạy script
- **Ngrok Dashboard:** `http://localhost:4040`

## 🎯 Khuyến nghị:

**Để test từ điện thoại:** Dùng Cách 1 hoặc 2
**Để test nhanh trên máy tính:** Dùng Cách 3

