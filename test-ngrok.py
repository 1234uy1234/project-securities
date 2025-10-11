#!/usr/bin/env python3
"""
Script test ngrok đơn giản
"""

import subprocess
import time
import requests
import json

def test_ngrok():
    print("🧪 Test ngrok...")
    
    # Khởi động ngrok
    print("🚀 Khởi động ngrok...")
    ngrok_process = subprocess.Popen([
        'ngrok', 'http', '8000',
        '--log=stdout'
    ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    
    # Đợi ngrok khởi động
    print("⏳ Đợi ngrok khởi động...")
    time.sleep(5)
    
    # Lấy URL từ ngrok API
    try:
        response = requests.get('http://localhost:4040/api/tunnels')
        data = response.json()
        
        for tunnel in data.get('tunnels', []):
            if tunnel.get('proto') == 'https':
                ngrok_url = tunnel.get('public_url')
                print(f"✅ Ngrok URL: {ngrok_url}")
                
                # Test URL
                test_response = requests.get(f"{ngrok_url}/api/health", timeout=10)
                print(f"✅ Test API: {test_response.status_code}")
                
                return ngrok_url
    except Exception as e:
        print(f"❌ Lỗi: {e}")
    
    return None

if __name__ == "__main__":
    test_ngrok()

