# 🚀 Hướng dẫn chạy thủ công với ngrok

## Cách 1: Chạy tự động (khuyến nghị)
```bash
./run-simple.sh
```

## Cách 2: Chạy thủ công từng bước

### Bước 1: Khởi động ngrok
```bash
ngrok http 8000
```
- Giữ terminal này mở
- Lấy URL từ ngrok (ví dụ: `https://abc123.ngrok.io`)

### Bước 2: Cập nhật file .env
```bash
# Thay YOUR_NGROK_URL bằng URL thực tế từ ngrok
echo "NGROK_URL=https://abc123.ngrok.io" > .env
echo "VITE_API_URL=https://abc123.ngrok.io" >> .env
```

### Bước 3: Khởi động backend
```bash
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- Giữ terminal này mở

### Bước 4: Khởi động frontend (terminal mới)
```bash
cd frontend
npm run dev
```

### Bước 5: Truy cập
- Mở trình duyệt
- Truy cập: `https://abc123.ngrok.io` (URL từ ngrok)
- Hoặc truy cập từ điện thoại với cùng URL

## Cách 3: Chạy không cần ngrok (IP cũ)

### Chỉ cần chạy backend và frontend:
```bash
# Terminal 1: Backend
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Terminal 2: Frontend  
cd frontend
npm run dev
```

- Truy cập: `http://localhost:5173` (chỉ trên máy tính)
- Không thể truy cập từ điện thoại

## 🔧 Troubleshooting

### Lỗi: "ngrok: command not found"
```bash
# Cài đặt ngrok
brew install ngrok

# Hoặc tải từ: https://ngrok.com/download
```

### Lỗi: "authentication failed"
```bash
# Cấu hình authtoken
ngrok config add-authtoken YOUR_TOKEN

# Lấy token từ: https://dashboard.ngrok.com/get-started/your-authtoken
```

### Lỗi: "npm run dev not found"
```bash
# Cài đặt dependencies
cd frontend
npm install
```

### Lỗi: "python not found"
```bash
# Cài đặt Python dependencies
cd backend
pip install -r requirements.txt
```

