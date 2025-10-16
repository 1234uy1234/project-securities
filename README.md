# 🚀 Smart Patrol System - Development Setup

## 📋 Tổng quan

Hệ thống tuần tra thông minh với khả năng tự động chuyển đổi giữa Ngrok và Cloudflare Tunnel.

### 🏗️ Kiến trúc

- **Frontend**: React + Tailwind CSS (localhost:5173)
- **Backend**: Python FastAPI + Uvicorn (0.0.0.0:8000)
- **Tunnel**: Ngrok (ưu tiên) → Cloudflare Tunnel (fallback)

## 🚀 Cách sử dụng

### 1. Cài đặt dependencies

```bash
# Cài đặt tất cả dependencies
npm run setup

# Hoặc cài đặt riêng lẻ
cd frontend && npm install
cd backend && pip install -r requirements.txt
```

### 2. Khởi động development environment

```bash
# Cách 1: Sử dụng script tự động (Khuyến nghị)
npm run dev
# hoặc
bash run-dev.sh

# Cách 2: Khởi động từng service riêng lẻ
npm run backend    # Backend only
npm run frontend   # Frontend only
npm run ngrok      # Ngrok only
npm run cloudflare # Cloudflare only
```

### 3. Truy cập ứng dụng

Sau khi chạy `npm run dev`, bạn sẽ thấy:

```
✅ Backend đã chạy trên http://0.0.0.0:8000
✅ Frontend đã chạy trên http://localhost:5173
🌍 Public URL: https://abc123.ngrok-free.app
```

## 🔧 Tính năng tự động

### 🔄 Auto Tunnel Switching

Script sẽ tự động:

1. **Khởi động Ngrok** (ưu tiên)
2. **Theo dõi lỗi ERR_NGROK_725** → Tự động chuyển sang Cloudflare Tunnel
3. **Khi Ngrok hồi lại** → Tự động chuyển về Ngrok
4. **Lưu URL hiện tại** vào file `current_url.txt`

### 📊 Monitoring

- **Ngrok Dashboard**: http://localhost:4040
- **Logs**: 
  - `backend.log` - Backend logs
  - `frontend.log` - Frontend logs
  - `ngrok.log` - Ngrok logs
  - `cloudflare.log` - Cloudflare logs

## 🌐 CORS Configuration

Backend đã được cấu hình CORS cho:

```python
CORS_ORIGINS = [
    'https://*.ngrok-free.app',
    'https://*.ngrok.io', 
    'http://localhost:5173',
    'http://127.0.0.1:5173'
]
```

## 📁 Cấu trúc thư mục

```
shopee/
├── run-dev.sh          # Script chính
├── package.json        # NPM scripts
├── README.md          # Hướng dẫn này
├── current_url.txt    # URL hiện tại (auto-generated)
├── backend.log        # Backend logs (auto-generated)
├── frontend.log       # Frontend logs (auto-generated)
├── ngrok.log          # Ngrok logs (auto-generated)
├── cloudflare.log     # Cloudflare logs (auto-generated)
├── frontend/          # React app
└── backend/           # FastAPI app
```

## 🛠️ Troubleshooting

### Lỗi thường gặp

1. **Port đã được sử dụng**
   ```bash
   # Script sẽ tự động kill process cũ
   # Hoặc kill thủ công:
   lsof -ti:5173 | xargs kill -9
   lsof -ti:8000 | xargs kill -9
   ```

2. **Ngrok không khởi động**
   ```bash
   # Kiểm tra ngrok đã cài đặt
   ngrok version
   
   # Cài đặt ngrok
   brew install ngrok/ngrok/ngrok  # macOS
   ```

3. **Cloudflare Tunnel không khởi động**
   ```bash
   # Cài đặt cloudflared
   brew install cloudflared  # macOS
   # hoặc tải từ: https://github.com/cloudflare/cloudflared/releases
   ```

4. **Backend không khởi động**
   ```bash
   # Kiểm tra dependencies
   cd backend
   pip install -r requirements.txt
   
   # Kiểm tra port 8000
   lsof -i:8000
   ```

5. **Frontend không khởi động**
   ```bash
   # Kiểm tra dependencies
   cd frontend
   npm install
   
   # Kiểm tra port 5173
   lsof -i:5173
   ```

### 🔍 Debug

```bash
# Xem logs real-time
tail -f backend.log
tail -f frontend.log
tail -f ngrok.log
tail -f cloudflare.log

# Kiểm tra processes
ps aux | grep uvicorn
ps aux | grep "npm run dev"
ps aux | grep ngrok
ps aux | grep cloudflared
```

## 📱 Mobile Testing

1. **Lấy URL public** từ console hoặc `current_url.txt`
2. **Mở trên mobile** và test các tính năng
3. **URL sẽ tự động cập nhật** khi chuyển đổi tunnel

## 🔐 Security Notes

- **Không commit** file `current_url.txt` vào git
- **Ngrok URLs** có thể thay đổi mỗi lần restart
- **Cloudflare URLs** ổn định hơn cho testing

## 📞 Support

Nếu gặp vấn đề:

1. Kiểm tra logs trong các file `.log`
2. Đảm bảo tất cả dependencies đã được cài đặt
3. Restart script: `Ctrl+C` rồi chạy lại `npm run dev`

---

**Happy Coding! 🎉**