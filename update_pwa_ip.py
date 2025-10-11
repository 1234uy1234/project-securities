#!/usr/bin/env python3
"""
Script cập nhật IP cho PWA
Usage: python3 update_pwa_ip.py NEW_IP
"""

import sys
import os
import subprocess
from datetime import datetime

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

def create_qr_code(new_ip):
    """Tạo QR code mới"""
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
        return filename
    except ImportError:
        print("⚠️ qrcode library not installed")
        return None

def create_notification(new_ip):
    """Tạo thông báo cập nhật IP"""
    notification = f"""THONG BAO CAP NHAT IP

IP moi: {new_ip}
URL moi: https://{new_ip}:3000

Huong dan:
1. Xoa app cu khoi man hinh chinh
2. Truy cap URL moi
3. Cai dat lai app
4. Hoac quet QR code moi

Thoi gian: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
    
    filename = f"IP_UPDATE_NOTIFICATION_{new_ip.replace('.', '_')}.txt"
    with open(filename, 'w') as f:
        f.write(notification)
    
    print(f"✅ Created notification: {filename}")

def update_pwa_ip(new_ip):
    """Cập nhật IP cho PWA"""
    print(f"🔄 Updating PWA IP to: {new_ip}")
    
    # Update configs
    update_api_config(new_ip)
    update_env_config(new_ip)
    
    # Create new QR code
    qr_file = create_qr_code(new_ip)
    
    # Create notification
    create_notification(new_ip)
    
    print(f"\n🎉 PWA IP updated successfully!")
    print(f"📱 New install URL: https://{new_ip}:3000")
    print(f"📱 New QR code: {qr_file}")
    
    print(f"\n📋 Instructions for users:")
    print(f"1. Delete old app from home screen")
    print(f"2. Visit: https://{new_ip}:3000")
    print(f"3. Install new app")
    print(f"4. Or scan new QR code")

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 update_pwa_ip.py NEW_IP")
        print("Example: python3 update_pwa_ip.py 192.168.1.100")
        sys.exit(1)
    
    new_ip = sys.argv[1]
    update_pwa_ip(new_ip)

if __name__ == "__main__":
    main()
