# 🚀 Hướng dẫn chạy nhanh

## ⚡ Cách 1: Chạy không cần ngrok (đơn giản nhất)

### Bước 1: Khởi động backend
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Bước 2: Khởi động frontend (terminal mới)
```bash
cd frontend
npm run dev
```

### Bước 3: Truy cập
- Mở trình duyệt: `http://localhost:5173`
- **Lưu ý:** Chỉ hoạt động trên máy tính, không thể truy cập từ điện thoại

---

## 🌐 Cách 2: Chạy với ngrok (truy cập từ điện thoại)

### Bước 1: Cấu hình ngrok (chỉ cần làm 1 lần)
1. Truy cập: https://dashboard.ngrok.com/signup
2. Đăng ký tài khoản miễn phí
3. Lấy authtoken từ: https://dashboard.ngrok.com/get-started/your-authtoken
4. Chạy lệnh:
```bash
ngrok config add-authtoken YOUR_TOKEN_HERE
```

### Bước 2: Khởi động ngrok
```bash
ngrok http 8000
```
- Giữ terminal này mở
- Lấy URL từ ngrok (ví dụ: `https://abc123.ngrok.io`)

### Bước 3: Cập nhật file .env
```bash
# Thay YOUR_NGROK_URL bằng URL thực tế từ ngrok
echo "NGROK_URL=https://abc123.ngrok.io" > .env
echo "VITE_API_URL=https://abc123.ngrok.io" >> .env
```

### Bước 4: Khởi động backend
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Bước 5: Khởi động frontend (terminal mới)
```bash
cd frontend
npm run dev
```

### Bước 6: Truy cập
- Mở trình duyệt: `https://abc123.ngrok.io`
- Hoặc mở trình duyệt điện thoại với cùng URL

---

## 🔧 Troubleshooting

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

### Lỗi: "ngrok authentication failed"
- Làm theo Bước 1 của Cách 2 để cấu hình authtoken

### Lỗi: "File .env chưa cập nhật"
- Làm theo Bước 3 của Cách 2 để cập nhật .env

---

## 💡 Khuyến nghị

**Nếu chỉ test trên máy tính:** Dùng Cách 1
**Nếu muốn test từ điện thoại:** Dùng Cách 2

