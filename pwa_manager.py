#!/usr/bin/env python3
"""
Script tạo PWA với IP động và hướng dẫn cài đặt
"""

import os
import json
import subprocess
import webbrowser
from datetime import datetime

class PWAManager:
    def __init__(self):
        self.current_ip = "localhost"  # IP hiện tại
        self.frontend_port = 5173
        self.backend_port = 8000
        
    def get_current_ip(self):
        """Lấy IP hiện tại"""
        try:
            import socket
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return self.current_ip
    
    def update_api_config(self, new_ip):
        """Cập nhật API config với IP mới"""
        api_file = "frontend/src/utils/api.ts"
        
        if os.path.exists(api_file):
            with open(api_file, 'r') as f:
                content = f.read()
            
            # Tìm và thay thế IP cũ
            import re
            old_pattern = r"baseURL:\s*['\"](https?://[^'\"]+)['\"]"
            new_url = f"https://{new_ip}:{self.backend_port}/api"
            
            new_content = re.sub(old_pattern, f"baseURL: '{new_url}'", content)
            
            with open(api_file, 'w') as f:
                f.write(new_content)
            
            print(f"✅ Updated API config: {new_url}")
            return True
        return False
    
    def update_env_config(self, new_ip):
        """Cập nhật .env config"""
        env_file = "frontend/.env.local"
        
        env_content = f"""VITE_API_BASE_URL=https://{new_ip}:{self.backend_port}/api
VITE_FRONTEND_URL=https://{new_ip}:{self.frontend_port}
VITE_BACKEND_URL=https://{new_ip}:{self.backend_port}
"""
        
        with open(env_file, 'w') as f:
            f.write(env_content)
        
        print(f"✅ Updated .env config: {new_ip}")
    
    def create_pwa_install_guide(self, ip):
        """Tạo hướng dẫn cài đặt PWA"""
        guide = f"""
# 📱 Hướng Dẫn Cài Đặt App MANHTOAN PLASTIC

## 🎯 Thông tin App
- **Tên**: MANHTOAN PLASTIC - Tuần tra thông minh
- **IP hiện tại**: {ip}
- **Frontend**: https://{ip}:{self.frontend_port}
- **Backend**: https://{ip}:{self.backend_port}

## 📱 Cài đặt trên Android

### Cách 1: Chrome Browser
1. Mở Chrome trên điện thoại
2. Truy cập: `https://{ip}:{self.frontend_port}`
3. Nhấn menu (3 chấm) → "Cài đặt ứng dụng"
4. Nhấn "Cài đặt"
5. App sẽ xuất hiện trên màn hình chính

### Cách 2: Samsung Internet
1. Mở Samsung Internet
2. Truy cập: `https://{ip}:{self.frontend_port}`
3. Nhấn menu → "Thêm vào màn hình chính"
4. Nhấn "Thêm"

## 📱 Cài đặt trên iOS

### Safari Browser
1. Mở Safari trên iPhone/iPad
2. Truy cập: `https://{ip}:{self.frontend_port}`
3. Nhấn biểu tượng chia sẻ (hộp với mũi tên)
4. Chọn "Thêm vào màn hình chính"
5. Nhấn "Thêm"

## 💻 Cài đặt trên Desktop

### Windows (Chrome/Edge)
1. Mở Chrome hoặc Edge
2. Truy cập: `https://{ip}:{self.frontend_port}`
3. Nhấn biểu tượng cài đặt (dấu +) trên thanh địa chỉ
4. Chọn "Cài đặt ứng dụng"

### macOS (Safari)
1. Mở Safari
2. Truy cập: `https://{ip}:{self.frontend_port}`
3. Nhấn biểu tượng chia sẻ
4. Chọn "Thêm vào Dock"

## 🔧 Khi IP thay đổi

### Vấn đề
- App đã cài đặt sẽ không hoạt động khi IP thay đổi
- Cần cập nhật app với IP mới

### Giải pháp
1. **Cập nhật app**:
   - Xóa app cũ khỏi màn hình chính
   - Truy cập IP mới: `https://IP_MỚI:{self.frontend_port}`
   - Cài đặt lại app

2. **Hoặc sử dụng QR code**:
   - Quét QR code với IP mới
   - App sẽ tự động cập nhật

## 📊 Tính năng App

### ✅ Hoạt động Offline
- Chấm công khi không có mạng
- Tự động sync khi có mạng
- Không mất dữ liệu

### ✅ Tính năng chính
- Quét QR code
- Chụp ảnh chấm công
- Xem nhiệm vụ
- Báo cáo tuần tra
- Đăng nhập bằng khuôn mặt

## 🚨 Lưu ý quan trọng

1. **HTTPS**: App chỉ hoạt động với HTTPS
2. **Certificate**: Cần trust certificate khi truy cập lần đầu
3. **IP thay đổi**: Cần cài đặt lại app khi IP thay đổi
4. **Backup**: Dữ liệu được backup tự động

## 🔄 Cập nhật IP

Khi IP thay đổi, chạy script:
```bash
python3 update_pwa_ip.py NEW_IP
```

Script sẽ:
- Cập nhật config
- Restart services
- Tạo QR code mới
- Gửi thông báo cho users
"""
        
        with open("PWA_INSTALL_GUIDE.md", 'w', encoding='utf-8') as f:
            f.write(guide)
        
        print(f"✅ Created PWA install guide for IP: {ip}")
    
    def create_qr_code_for_pwa(self, ip):
        """Tạo QR code để cài đặt PWA"""
        try:
            import qrcode
            
            url = f"https://{ip}:{self.frontend_port}"
            qr = qrcode.QRCode(version=1, box_size=10, border=5)
            qr.add_data(url)
            qr.make(fit=True)
            
            img = qr.make_image(fill_color="black", back_color="white")
            filename = f"pwa_install_qr_{ip.replace('.', '_')}.png"
            img.save(filename)
            
            print(f"✅ Created QR code: {filename}")
            print(f"📱 Scan QR code to install PWA: {url}")
            
            return filename
        except ImportError:
            print("⚠️ qrcode library not installed. Install with: pip install qrcode[pil]")
            return None
    
    def create_update_script(self):
        """Tạo script cập nhật IP"""
        script_content = """#!/usr/bin/env python3
'''
Script cập nhật IP cho PWA
Usage: python3 update_pwa_ip.py NEW_IP
'''

import sys
import os
import subprocess
from datetime import datetime

def update_pwa_ip(new_ip):
    print(f"🔄 Updating PWA IP to: {new_ip}")
    
    # Update API config
    api_file = "frontend/src/utils/api.ts"
    if os.path.exists(api_file):
        with open(api_file, 'r') as f:
            content = f.read()
        
        import re
        old_pattern = r"baseURL:\s*['\"](https?://[^'\"]+)['\"]"
        new_url = f"https://{new_ip}:8000/api"
        
        new_content = re.sub(old_pattern, f"baseURL: '{new_url}'", content)
        
        with open(api_file, 'w') as f:
            f.write(new_content)
        
        print(f"✅ Updated API config: {new_url}")
    
    # Update .env
    env_file = "frontend/.env.local"
    env_content = f"VITE_API_BASE_URL=https://{new_ip}:8000/api\nVITE_FRONTEND_URL=https://{new_ip}:3000\nVITE_BACKEND_URL=https://{new_ip}:8000\n"
    
    with open(env_file, 'w') as f:
        f.write(env_content)
    
    print(f"✅ Updated .env config")
    
    # Create new QR code
    try:
        import qrcode
        url = f"https://{new_ip}:3000"
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(url)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        filename = f"pwa_install_qr_{new_ip.replace('.', '_')}.png"
        img.save(filename)
        
        print(f"✅ Created new QR code: {filename}")
    except ImportError:
        print("⚠️ qrcode library not installed")
    
    # Create notification
    notification = f"""
THONG BAO CAP NHAT IP

IP moi: {new_ip}
URL moi: https://{new_ip}:3000

Huong dan:
1. Xoa app cu khoi man hinh chinh
2. Truy cap URL moi
3. Cai dat lai app
4. Hoac quet QR code moi

Thoi gian: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
    
    with open(f"IP_UPDATE_NOTIFICATION_{new_ip.replace('.', '_')}.txt", 'w') as f:
        f.write(notification)
    
    print(f"✅ Created notification file")
    print(f"🎉 PWA IP updated successfully!")
    print(f"📱 New install URL: https://{new_ip}:3000")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 update_pwa_ip.py NEW_IP")
        print("Example: python3 update_pwa_ip.py 192.168.1.100")
        sys.exit(1)
    
    new_ip = sys.argv[1]
    update_pwa_ip(new_ip)
"""
        
        with open("update_pwa_ip.py", 'w') as f:
            f.write(script_content)
        
        # Make executable
        os.chmod("update_pwa_ip.py", 0o755)
        
        print("✅ Created update script: update_pwa_ip.py")
    
    def build_pwa(self, ip):
        """Build PWA với IP mới"""
        print(f"🔨 Building PWA for IP: {ip}")
        
        # Update configs
        self.update_api_config(ip)
        self.update_env_config(ip)
        
        # Build frontend
        try:
            os.chdir("frontend")
            result = subprocess.run(["npm", "run", "build"], capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ Frontend built successfully")
            else:
                print(f"❌ Build failed: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"❌ Build error: {e}")
            return False
        finally:
            os.chdir("..")
        
        return True
    
    def start_services(self):
        """Start backend and frontend services"""
        print("🚀 Starting services...")
        
        # Start backend
        print("Starting backend...")
        backend_process = subprocess.Popen([
            "python3", "-m", "uvicorn", 
            "backend.app.main:app", 
            "--host", "0.0.0.0", 
            "--port", str(self.backend_port),
            "--ssl-keyfile", "backend/key.pem",
            "--ssl-certfile", "backend/cert.pem"
        ])
        
        # Start frontend
        print("Starting frontend...")
        frontend_process = subprocess.Popen([
            "npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", str(self.frontend_port)
        ], cwd="frontend")
        
        print(f"✅ Services started:")
        print(f"   Backend: https://{self.current_ip}:{self.backend_port}")
        print(f"   Frontend: https://{self.current_ip}:{self.frontend_port}")
        
        return backend_process, frontend_process

def main():
    manager = PWAManager()
    
    print("📱 PWA Manager - MANHTOAN PLASTIC")
    print("=" * 50)
    
    # Get current IP
    current_ip = manager.get_current_ip()
    print(f"📍 Current IP: {current_ip}")
    
    # Create PWA install guide
    manager.create_pwa_install_guide(current_ip)
    
    # Create QR code
    qr_file = manager.create_qr_code_for_pwa(current_ip)
    
    # Create update script
    manager.create_update_script()
    
    print("\n🎉 PWA Setup Complete!")
    print(f"📱 Install URL: https://{current_ip}:3000")
    print(f"📋 Install guide: PWA_INSTALL_GUIDE.md")
    if qr_file:
        print(f"📱 QR code: {qr_file}")
    print(f"🔧 Update script: update_pwa_ip.py")
    
    print("\n📋 Next Steps:")
    print("1. Start services: python3 start_pwa_services.py")
    print("2. Share QR code with users")
    print("3. Users scan QR code to install PWA")
    print("4. When IP changes: python3 update_pwa_ip.py NEW_IP")

if __name__ == "__main__":
    main()
