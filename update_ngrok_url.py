#!/usr/bin/env python3
"""
Script tự động cập nhật ngrok URL vào frontend
"""

import requests
import json
import os
import time

def get_ngrok_url():
    """Lấy ngrok URL từ API"""
    try:
        response = requests.get("http://localhost:4040/api/tunnels")
        data = response.json()
        
        for tunnel in data['tunnels']:
            if tunnel['proto'] == 'https':
                return tunnel['public_url']
        
        return None
    except Exception as e:
        print(f"Error getting ngrok URL: {e}")
        return None

def update_frontend_config(ngrok_url):
    """Cập nhật config frontend với ngrok URL mới"""
    try:
        # Cập nhật file config frontend
        config_file = "/Users/maybe/Documents/shopee/frontend/src/config/api.ts"
        
        if os.path.exists(config_file):
            with open(config_file, 'r') as f:
                content = f.read()
            
            # Thay thế URL cũ bằng URL mới
            import re
            new_content = re.sub(
                r'const API_BASE_URL = ["\']https://[^"\']+["\']',
                f'const API_BASE_URL = "{ngrok_url}"',
                content
            )
            
            with open(config_file, 'w') as f:
                f.write(new_content)
            
            print(f"✅ Updated frontend config with: {ngrok_url}")
            return True
        else:
            print("❌ Frontend config file not found")
            return False
            
    except Exception as e:
        print(f"Error updating frontend config: {e}")
        return False

def main():
    """Main function"""
    print("🔄 Checking ngrok URL...")
    
    # Đợi ngrok khởi động
    time.sleep(3)
    
    ngrok_url = get_ngrok_url()
    
    if ngrok_url:
        print(f"🌍 Ngrok URL: {ngrok_url}")
        
        # Lưu URL vào file
        with open("/Users/maybe/Documents/shopee/ngrok_url.txt", "w") as f:
            f.write(ngrok_url)
        
        # Cập nhật frontend config
        update_frontend_config(ngrok_url)
        
        print(f"📱 Access your app at: {ngrok_url}")
        print(f"🔧 Backend API: {ngrok_url}/api/")
        
    else:
        print("❌ Could not get ngrok URL")

if __name__ == "__main__":
    main()
