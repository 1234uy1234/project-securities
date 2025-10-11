#!/usr/bin/env python3
"""
Script cuối cùng để tạo tài khoản hung
"""

import sqlite3
import subprocess
import json

def create_hung_final():
    """Tạo tài khoản hung cuối cùng"""
    try:
        print("👤 Tạo tài khoản hung cuối cùng...")
        
        # Kết nối database
        conn = sqlite3.connect('backend/patrol.db')
        cursor = conn.cursor()
        
        # Xóa tài khoản cũ
        cursor.execute('DELETE FROM users WHERE username = ?', ('hung',))
        
        # Copy chính xác từ admin
        cursor.execute('''
        INSERT INTO users (username, email, password_hash, role, full_name, phone, is_active, created_at, updated_at)
        SELECT 'hung', 'hung@example.com', password_hash, 'employee', 'Nguyễn Văn Hùng', '0123456789', 1, datetime('now'), datetime('now')
        FROM users WHERE username = 'admin'
        ''')
        
        conn.commit()
        conn.close()
        
        print("✅ Đã tạo tài khoản hung bằng cách copy từ admin!")
        
        # Test login
        print("🧪 Testing login...")
        result = subprocess.run([
            'curl', '-k', 
            'https://localhost:8000/api/auth/login',
            '-H', 'Content-Type: application/json',
            '-d', '{"username":"hung","password":"admin123"}'
        ], capture_output=True, text=True)
        
        if result.returncode == 0 and 'access_token' in result.stdout:
            print("✅ Login thành công!")
            
            # Test face auth
            try:
                response_data = json.loads(result.stdout)
                token = response_data['access_token']
                
                # Test face auth status
                import requests
                headers = {'Authorization': f'Bearer {token}'}
                status_response = requests.get('https://localhost:8000/api/face-auth/user-status', headers=headers, verify=False)
                
                if status_response.status_code == 200:
                    status_data = status_response.json()
                    print(f"📸 Face status: {status_data}")
                else:
                    print(f"❌ Face status error: {status_response.status_code}")
                    print(f"Response: {status_response.text}")
                    
            except Exception as e:
                print(f"❌ Error testing face auth: {e}")
                
        else:
            print("❌ Login thất bại")
            print(f"Response: {result.stdout}")
        
        print("\n📝 Thông tin đăng nhập:")
        print("   Username: hung")
        print("   Password: admin123")
        
    except Exception as e:
        print(f"❌ Lỗi: {e}")
        sys.exit(1)

if __name__ == "__main__":
    create_hung_final()
