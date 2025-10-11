# 🚀 DEPLOY INSTRUCTIONS - VERCEL + RAILWAY

## 📋 **TỔNG QUAN**
- **Frontend**: Vercel (https://your-app.vercel.app)
- **Backend**: Railway (https://your-backend.railway.app)
- **Database**: Railway PostgreSQL
- **URL thực sự**: Không bao giờ hết hạn!

## 🔧 **BƯỚC 1: SETUP RAILWAY (BACKEND)**

### 1.1 Đăng ký Railway
```bash
# Cài đặt Railway CLI
npm install -g @railway/cli

# Đăng nhập Railway
railway login
```

### 1.2 Deploy Backend
```bash
# Tạo project mới
railway init

# Deploy backend
railway up

# Lấy URL backend
railway domain
```

## 🎨 **BƯỚC 2: SETUP VERCEL (FRONTEND)**

### 2.1 Cài đặt Vercel CLI
```bash
# Cài đặt Vercel CLI
npm install -g vercel

# Đăng nhập Vercel
vercel login
```

### 2.2 Deploy Frontend
```bash
# Vào thư mục frontend
cd frontend

# Deploy lên Vercel
vercel --prod

# Lấy URL frontend
vercel ls
```

## 🔗 **BƯỚC 3: CẤU HÌNH KẾT NỐI**

### 3.1 Cập nhật API URL trong Frontend
```bash
# Lấy URL backend từ Railway
railway domain

# Cập nhật trong Vercel
vercel env add VITE_API_URL
# Nhập: https://your-backend.railway.app
```

### 3.2 Redeploy Frontend
```bash
vercel --prod
```

## ✅ **KẾT QUẢ CUỐI CÙNG**
- **Frontend URL**: https://your-app.vercel.app
- **Backend URL**: https://your-backend.railway.app
- **Truy cập từ mọi nơi**: ✅
- **Không bao giờ hết hạn**: ✅
- **HTTPS tự động**: ✅

## 🎯 **LỆNH CHẠY NHANH**

### Deploy Backend (Railway):
```bash
railway login
railway init
railway up
railway domain
```

### Deploy Frontend (Vercel):
```bash
cd frontend
vercel login
vercel --prod
vercel env add VITE_API_URL
vercel --prod
```

## 🔐 **THÔNG TIN ĐĂNG NHẬP**
- Username: admin
- Password: admin

