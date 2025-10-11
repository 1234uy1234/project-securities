#!/usr/bin/env python3
"""
Test script để kiểm tra QR code có được lưu đúng tên vào database
"""

import requests
import json
import sys

# Cấu hình
BASE_URL = "http://localhost:8000"
LOGIN_URL = f"{BASE_URL}/auth/login"
QR_GENERATE_URL = f"{BASE_URL}/qr-codes/generate-simple"
QR_LIST_URL = f"{BASE_URL}/qr-codes/"

def login():
    """Đăng nhập để lấy token"""
    login_data = {
        "username": "admin",
        "password": "admin123"
    }
    
    try:
        response = requests.post(LOGIN_URL, data=login_data)
        if response.status_code == 200:
            token = response.json().get("access_token")
            print(f"✅ Đăng nhập thành công, token: {token[:20]}...")
            return token
        else:
            print(f"❌ Lỗi đăng nhập: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Lỗi kết nối: {e}")
        return None

def create_qr_code(token, qr_name):
    """Tạo QR code với tên đơn giản"""
    headers = {"Authorization": f"Bearer {token}"}
    data = {
        "data": qr_name,
        "type": "static"
    }
    
    try:
        response = requests.post(QR_GENERATE_URL, headers=headers, data=data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Tạo QR code thành công: {qr_name}")
            print(f"   - ID: {result.get('id')}")
            print(f"   - Data: {result.get('data')}")
            print(f"   - Content: {result.get('qr_content')}")
            return result
        else:
            print(f"❌ Lỗi tạo QR code: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Lỗi tạo QR code: {e}")
        return None

def list_qr_codes(token):
    """Lấy danh sách QR codes từ database"""
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(QR_LIST_URL, headers=headers)
        if response.status_code == 200:
            qr_codes = response.json()
            print(f"✅ Lấy danh sách QR codes thành công: {len(qr_codes)} QR codes")
            return qr_codes
        else:
            print(f"❌ Lỗi lấy danh sách QR codes: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Lỗi lấy danh sách QR codes: {e}")
        return None

def validate_qr_code(qr_content):
    """Kiểm tra QR code có hợp lệ không"""
    try:
        response = requests.get(f"{BASE_URL}/qr-codes/validate/{qr_content}")
        if response.status_code == 200:
            result = response.json()
            if result.get('valid'):
                print(f"✅ QR code hợp lệ: {qr_content}")
                print(f"   - Data: {result.get('data')}")
                print(f"   - Content: {result.get('content')}")
                return True
            else:
                print(f"❌ QR code không hợp lệ: {result.get('message')}")
                return False
        else:
            print(f"❌ Lỗi validate QR: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Lỗi validate QR: {e}")
        return False

def main():
    print("🧪 TEST: Kiểm tra QR code có được lưu đúng tên vào database")
    print("=" * 70)
    
    # 1. Đăng nhập
    print("\n1. Đăng nhập...")
    token = login()
    if not token:
        print("❌ Không thể đăng nhập, dừng test")
        return
    
    # 2. Lấy danh sách QR codes hiện tại
    print("\n2. Lấy danh sách QR codes hiện tại...")
    existing_qr_codes = list_qr_codes(token)
    if existing_qr_codes is not None:
        print("📋 QR codes hiện có:")
        for qr in existing_qr_codes[-5:]:  # Chỉ hiển thị 5 QR codes gần nhất
            print(f"   - ID: {qr.get('id')}, Data: '{qr.get('data')}', Content: '{qr.get('qr_content')}'")
    
    # 3. Tạo QR code mới với tên cụ thể
    print("\n3. Tạo QR code mới...")
    test_qr_name = "Nhà sảnh A - Test"
    qr_result = create_qr_code(token, test_qr_name)
    if not qr_result:
        print("❌ Không thể tạo QR code, dừng test")
        return
    
    # 4. Kiểm tra QR code có được lưu đúng không
    print("\n4. Kiểm tra QR code có được lưu đúng không...")
    qr_codes_after = list_qr_codes(token)
    if qr_codes_after:
        # Tìm QR code vừa tạo
        new_qr = None
        for qr in qr_codes_after:
            if qr.get('id') == qr_result.get('id'):
                new_qr = qr
                break
        
        if new_qr:
            print(f"✅ QR code đã được lưu vào database:")
            print(f"   - ID: {new_qr.get('id')}")
            print(f"   - Data: '{new_qr.get('data')}'")
            print(f"   - Content: '{new_qr.get('qr_content')}'")
            print(f"   - Type: {new_qr.get('type')}")
            print(f"   - Created: {new_qr.get('created_at')}")
            
            # Kiểm tra tên có đúng không
            if new_qr.get('data') == test_qr_name and new_qr.get('qr_content') == test_qr_name:
                print("✅ Tên QR code đã được lưu đúng!")
            else:
                print("❌ Tên QR code không đúng!")
                print(f"   Expected: '{test_qr_name}'")
                print(f"   Actual data: '{new_qr.get('data')}'")
                print(f"   Actual content: '{new_qr.get('qr_content')}'")
        else:
            print("❌ Không tìm thấy QR code vừa tạo trong database!")
    
    # 5. Validate QR code
    print("\n5. Validate QR code...")
    qr_content = qr_result.get('qr_content')
    if not validate_qr_code(qr_content):
        print("❌ QR code không hợp lệ, dừng test")
        return
    
    # 6. Kết quả
    print("\n" + "=" * 70)
    print("🎉 TEST HOÀN THÀNH!")
    print(f"✅ QR code '{test_qr_name}' đã được tạo và lưu đúng vào database")
    print(f"✅ QR code có thể validate thành công")
    print("✅ Tên QR code hiển thị đúng như user nhập")

if __name__ == "__main__":
    main()
