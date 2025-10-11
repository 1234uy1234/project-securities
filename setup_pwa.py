#!/usr/bin/env python3
"""
Script tạo PWA với IP động
"""

import os
import json
import subprocess
from datetime import datetime

def get_current_ip():
    """Lấy IP hiện tại"""
    try:
        import socket
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "localhost"

def get_frontend_port():
    """Lấy port frontend hiện tại"""
    import subprocess
    try:
        # Kiểm tra port nào đang được sử dụng
        result = subprocess.run(['lsof', '-i', ':3000'], capture_output=True, text=True)
        if result.returncode == 0:
            return 3000
        
        result = subprocess.run(['lsof', '-i', ':5173'], capture_output=True, text=True)
        if result.returncode == 0:
            return 5173
            
        result = subprocess.run(['lsof', '-i', ':5174'], capture_output=True, text=True)
        if result.returncode == 0:
            return 5174
            
        return 3000  # Default
    except:
        return 3000

def update_api_config(new_ip):
    """Cập nhật API config"""
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
        return True
    return False

def update_env_config(new_ip):
    """Cập nhật .env config"""
    env_file = "frontend/.env.local"
    
    env_content = f"VITE_API_BASE_URL=https://{new_ip}:8000/api\nVITE_FRONTEND_URL=https://{new_ip}:3000\nVITE_BACKEND_URL=https://{new_ip}:8000\n"
    
    with open(env_file, 'w') as f:
        f.write(env_content)
    
    print(f"✅ Updated .env config")

def create_qr_code(ip, port):
    """Tạo QR code"""
    try:
        import qrcode
        
        url = f"https://{ip}:{port}"
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(url)
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        filename = f"pwa_install_qr_{ip.replace('.', '_')}_{port}.png"
        img.save(filename)
        
        print(f"✅ Created QR code: {filename}")
        return filename
    except ImportError:
        print("⚠️ qrcode library not installed. Install with: pip install qrcode[pil]")
        return None

def create_install_guide(ip, port):
    """Tạo hướng dẫn cài đặt"""
    guide = f"""# Hướng Dẫn Cài Đặt App MANHTOAN PLASTIC

## Thông tin App
- Tên: MANHTOAN PLASTIC - Tuần tra thông minh
- IP hiện tại: {ip}
- Frontend: https://{ip}:{port}
- Backend: https://{ip}:8000

## Cài đặt trên Android

### Chrome Browser
1. Mở Chrome trên điện thoại
2. Truy cập: https://{ip}:3000
3. Nhấn menu (3 chấm) → "Cài đặt ứng dụng"
4. Nhấn "Cài đặt"
5. App sẽ xuất hiện trên màn hình chính

### Samsung Internet
1. Mở Samsung Internet
2. Truy cập: https://{ip}:3000
3. Nhấn menu → "Thêm vào màn hình chính"
4. Nhấn "Thêm"

## Cài đặt trên iOS

### Safari Browser
1. Mở Safari trên iPhone/iPad
2. Truy cập: https://{ip}:3000
3. Nhấn biểu tượng chia sẻ (hộp với mũi tên)
4. Chọn "Thêm vào màn hình chính"
5. Nhấn "Thêm"

## Khi IP thay đổi

### Vấn đề
- App đã cài đặt sẽ không hoạt động khi IP thay đổi
- Cần cập nhật app với IP mới

### Giải pháp
1. Xóa app cũ khỏi màn hình chính
2. Truy cập IP mới: https://IP_MỚI:3000
3. Cài đặt lại app
4. Hoặc quét QR code mới

## Tính năng App

### Hoạt động Offline
- Chấm công khi không có mạng
- Tự động sync khi có mạng
- Không mất dữ liệu

### Tính năng chính
- Quét QR code
- Chụp ảnh chấm công
- Xem nhiệm vụ
- Báo cáo tuần tra
- Đăng nhập bằng khuôn mặt

## Lưu ý quan trọng

1. HTTPS: App chỉ hoạt động với HTTPS
2. Certificate: Cần trust certificate khi truy cập lần đầu
3. IP thay đổi: Cần cài đặt lại app khi IP thay đổi
4. Backup: Dữ liệu được backup tự động
"""
    
    with open("PWA_INSTALL_GUIDE.md", 'w', encoding='utf-8') as f:
        f.write(guide)
    
    print(f"✅ Created install guide: PWA_INSTALL_GUIDE.md")

def main():
    print("📱 PWA Manager - MANHTOAN PLASTIC")
    print("=" * 50)
    
    # Get current IP
    current_ip = get_current_ip()
    print(f"📍 Current IP: {current_ip}")
    
    # Update configs
    update_api_config(current_ip)
    update_env_config(current_ip)
    
    # Create QR code
    qr_file = create_qr_code(current_ip)
    
    # Create install guide
    create_install_guide(current_ip)
    
    print("\n🎉 PWA Setup Complete!")
    print(f"📱 Install URL: https://{current_ip}:3000")
    print(f"📋 Install guide: PWA_INSTALL_GUIDE.md")
    if qr_file:
        print(f"📱 QR code: {qr_file}")
    
    print("\n📋 Next Steps:")
    print("1. Start services: python3 start_pwa_services.py")
    print("2. Share QR code with users")
    print("3. Users scan QR code to install PWA")
    print("4. When IP changes: Update configs and create new QR")

if __name__ == "__main__":
    main()
