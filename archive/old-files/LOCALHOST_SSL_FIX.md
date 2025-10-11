# 🔒 HƯỚNG DẪN TRUST SSL CERTIFICATE CHO LOCALHOST

## Vấn đề
Browser hiển thị lỗi `ERR_CERT_AUTHORITY_INVALID` khi truy cập `https://localhost:8000`

## Giải pháp

### 1. **Chrome/Edge:**
1. Truy cập `https://localhost:8000`
2. Click "Advanced" → "Proceed to localhost (unsafe)"
3. Hoặc click vào icon khóa → "Certificate" → "Install Certificate"

### 2. **Firefox:**
1. Truy cập `https://localhost:8000`
2. Click "Advanced" → "Accept the Risk and Continue"
3. Hoặc vào Settings → Privacy & Security → Certificates → View Certificates → Import

### 3. **Safari:**
1. Truy cập `https://localhost:8000`
2. Click "Show Details" → "visit this website"
3. Click "visit this website" lần nữa

### 4. **Tự động trust (macOS):**
```bash
# Mở Keychain Access
open /Applications/Utilities/Keychain\ Access.app

# Import certificate
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain backend/cert.pem
```

### 5. **Tự động trust (Windows):**
```cmd
# Import vào Trusted Root Certification Authorities
certlm.msc
# Import file backend/cert.pem
```

## Alternative: Chạy HTTP thay vì HTTPS

Nếu không muốn deal với SSL, có thể chạy HTTP:

```bash
# Backend HTTP
cd backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000

# Frontend HTTP  
cd frontend
npm run dev -- --port 5173 --host 0.0.0.0
```

Sau đó truy cập:
- Frontend: http://localhost:5173
- Backend: http://localhost:8000

## Kiểm tra
Sau khi trust certificate, truy cập:
- Frontend: https://localhost:5173
- Backend: https://localhost:8000

Không còn lỗi SSL nữa!
