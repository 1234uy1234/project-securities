#!/usr/bin/env python3
"""
Script giải quyết vấn đề HTTPS bị chặn khi cài đặt PWA
"""

import os
import subprocess
import webbrowser
from datetime import datetime

class HTTPSFixer:
    def __init__(self):
        self.ip = "localhost"
        self.ports = [3000, 5173, 5174, 8000]
        
    def check_services(self):
        """Kiểm tra services đang chạy"""
        print("🔍 Checking running services...")
        
        running_ports = []
        for port in self.ports:
            try:
                result = subprocess.run(['lsof', '-i', f':{port}'], 
                                       capture_output=True, text=True)
                if result.returncode == 0:
                    running_ports.append(port)
                    print(f"✅ Port {port}: Running")
                else:
                    print(f"❌ Port {port}: Not running")
            except:
                print(f"❌ Port {port}: Error checking")
        
        return running_ports
    
    def create_certificate_guide(self):
        """Tạo hướng dẫn trust certificate"""
        guide = f"""# 🔒 Hướng Dẫn Trust Certificate cho PWA

## ⚠️ Vấn đề
HTTPS với self-signed certificate bị browser chặn, không thể cài đặt PWA.

## ✅ Giải pháp

### 📱 Android (Chrome)
1. Truy cập: `https://{self.ip}:5174`
2. Nhấn "Advanced" → "Proceed to {self.ip} (unsafe)"
3. Sau đó cài đặt PWA bình thường

### 📱 Android (Samsung Internet)
1. Truy cập: `https://{self.ip}:5174`
2. Nhấn "Advanced" → "Continue to {self.ip}"
3. Sau đó cài đặt PWA bình thường

### 📱 iOS (Safari)
1. Truy cập: `https://{self.ip}:5174`
2. Nhấn "Advanced" → "Proceed to {self.ip}"
3. Sau đó cài đặt PWA bình thường

### 💻 Desktop (Chrome/Edge)
1. Truy cập: `https://{self.ip}:5174`
2. Nhấn "Advanced" → "Proceed to {self.ip} (unsafe)"
3. Sau đó cài đặt PWA bình thường

## 🔧 Alternative: HTTP Mode

Nếu HTTPS vẫn không hoạt động, có thể chạy HTTP:

### Start HTTP Mode
```bash
cd frontend
npm run dev -- --host 0.0.0.0 --port 5174
```

### Install PWA on HTTP
- URL: `http://{self.ip}:5174`
- PWA sẽ hoạt động trên HTTP (ít bảo mật hơn)

## 🎯 Steps để cài đặt PWA

1. **Trust certificate** (theo hướng dẫn trên)
2. **Truy cập**: `https://{self.ip}:5174`
3. **Cài đặt PWA**:
   - Android: Menu → "Cài đặt ứng dụng"
   - iOS: Chia sẻ → "Thêm vào màn hình chính"
   - Desktop: Biểu tượng cài đặt

## 🚨 Lưu ý

- **Self-signed certificate** không được trust mặc định
- **Cần trust manual** cho mỗi browser
- **PWA vẫn hoạt động offline** sau khi cài đặt
- **HTTP mode** ít bảo mật nhưng dễ cài đặt hơn

## 🔄 Troubleshooting

### Nếu vẫn không cài được:
1. Thử HTTP mode
2. Thử browser khác
3. Thử thiết bị khác
4. Kiểm tra firewall/antivirus

### Test PWA:
1. Cài đặt thành công
2. Tắt mạng
3. Mở app (vẫn hoạt động)
4. Test offline features
"""
        
        with open("HTTPS_CERTIFICATE_GUIDE.md", 'w', encoding='utf-8') as f:
            f.write(guide)
        
        print("✅ Created certificate guide: HTTPS_CERTIFICATE_GUIDE.md")
    
    def create_http_mode_script(self):
        """Tạo script chạy HTTP mode"""
        script_content = """#!/bin/bash
# Script chạy HTTP mode cho PWA

echo "🌐 Starting HTTP mode for PWA..."

# Kill existing processes
pkill -f vite
pkill -f uvicorn

# Start backend with HTTP
echo "🚀 Starting backend..."
cd backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 &
cd ..

# Start frontend with HTTP
echo "🚀 Starting frontend..."
cd frontend
npm run dev -- --host 0.0.0.0 --port 5174 &
cd ..

echo "✅ Services started!"
echo "🌐 Backend: http://localhost:8000"
echo "📱 Frontend: http://localhost:5174"
echo "📱 PWA Install: http://localhost:5174"
echo ""
echo "📋 PWA Installation (HTTP mode):"
echo "1. Open http://localhost:5174 on mobile"
echo "2. Tap 'Install App' or browser menu"
echo "3. App will be installed on home screen"
echo ""
echo "⚠️ Note: HTTP mode is less secure but easier to install"
"""
        
        with open("start_http_mode.sh", 'w') as f:
            f.write(script_content)
        
        os.chmod("start_http_mode.sh", 0o755)
        print("✅ Created HTTP mode script: start_http_mode.sh")
    
    def create_qr_codes(self):
        """Tạo QR codes cho cả HTTP và HTTPS"""
        try:
            import qrcode
            
            # HTTPS QR
            https_url = f"https://{self.ip}:5174"
            qr = qrcode.QRCode(version=1, box_size=10, border=5)
            qr.add_data(https_url)
            qr.make(fit=True)
            img = qr.make_image(fill_color="black", back_color="white")
            img.save("pwa_install_https_5174.png")
            print(f"✅ Created HTTPS QR: pwa_install_https_5174.png")
            
            # HTTP QR
            http_url = f"http://{self.ip}:5174"
            qr = qrcode.QRCode(version=1, box_size=10, border=5)
            qr.add_data(http_url)
            qr.make(fit=True)
            img = qr.make_image(fill_color="black", back_color="white")
            img.save("pwa_install_http_5174.png")
            print(f"✅ Created HTTP QR: pwa_install_http_5174.png")
            
        except ImportError:
            print("⚠️ qrcode library not installed")
    
    def run(self):
        """Chạy HTTPS fixer"""
        print("🔒 HTTPS Certificate Fixer")
        print("=" * 50)
        
        # Check services
        running_ports = self.check_services()
        
        if not running_ports:
            print("❌ No services running. Please start frontend first.")
            return
        
        print(f"✅ Found running services on ports: {running_ports}")
        
        # Create guides and scripts
        self.create_certificate_guide()
        self.create_http_mode_script()
        self.create_qr_codes()
        
        print("\n🎉 HTTPS Fix Complete!")
        print("\n📋 Solutions:")
        print("1. Trust certificate (see HTTPS_CERTIFICATE_GUIDE.md)")
        print("2. Use HTTP mode (run ./start_http_mode.sh)")
        print("3. Try different browser/device")
        
        print("\n📱 QR Codes:")
        print("- HTTPS: pwa_install_https_5174.png")
        print("- HTTP: pwa_install_http_5174.png")

def main():
    fixer = HTTPSFixer()
    fixer.run()

if __name__ == "__main__":
    main()
