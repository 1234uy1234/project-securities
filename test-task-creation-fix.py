#!/usr/bin/env python3
"""
Test script để kiểm tra việc tạo task và QR code đã được sửa
"""

import requests
import json
import sys

# Cấu hình
BASE_URL = "http://localhost:8000"
LOGIN_URL = f"{BASE_URL}/auth/login"
QR_GENERATE_URL = f"{BASE_URL}/qr-codes/generate-simple"
TASK_CREATE_URL = f"{BASE_URL}/patrol-tasks/"

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

def create_task(token, task_title, location_name, stops):
    """Tạo task với location và stops đơn giản"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    task_data = {
        "title": task_title,
        "description": f"Nhiệm vụ test: {task_title}",
        "assigned_to": 1,
        "location_id": location_name,  # Đơn giản: chỉ cần tên
        "schedule_week": {
            "date": "2025-01-20",
            "startTime": "08:00",
            "endTime": "17:00"
        },
        "stops": stops
    }
    
    try:
        response = requests.post(TASK_CREATE_URL, headers=headers, json=task_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Tạo task thành công: {task_title}")
            print(f"   - Task ID: {result.get('id')}")
            print(f"   - Location: {result.get('location_name', 'N/A')}")
            print(f"   - Stops: {len(result.get('stops', []))}")
            return result
        else:
            print(f"❌ Lỗi tạo task: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Lỗi tạo task: {e}")
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
    print("🧪 TEST: Kiểm tra việc tạo task và QR code đã được sửa")
    print("=" * 60)
    
    # 1. Đăng nhập
    print("\n1. Đăng nhập...")
    token = login()
    if not token:
        print("❌ Không thể đăng nhập, dừng test")
        return
    
    # 2. Tạo QR code
    print("\n2. Tạo QR code...")
    qr_name = "Nhà sảnh A"
    qr_result = create_qr_code(token, qr_name)
    if not qr_result:
        print("❌ Không thể tạo QR code, dừng test")
        return
    
    # 3. Validate QR code
    print("\n3. Kiểm tra QR code...")
    qr_content = qr_result.get('qr_content')
    if not validate_qr_code(qr_content):
        print("❌ QR code không hợp lệ, dừng test")
        return
    
    # 4. Tạo task với stops
    print("\n4. Tạo task với stops...")
    stops = [
        {
            "qr_code_name": "Nhà sảnh A",
            "scheduled_time": "08:00",
            "required": True
        },
        {
            "qr_code_name": "Khu vực B",
            "scheduled_time": "10:00",
            "required": True
        }
    ]
    
    task_result = create_task(token, "Test Task Đơn Giản", "Vị trí chính", stops)
    if not task_result:
        print("❌ Không thể tạo task, dừng test")
        return
    
    # 5. Kết quả
    print("\n" + "=" * 60)
    print("🎉 TEST HOÀN THÀNH!")
    print(f"✅ QR code '{qr_name}' đã được tạo và validate thành công")
    print(f"✅ Task '{task_result.get('title')}' đã được tạo với {len(task_result.get('stops', []))} stops")
    print("✅ Logic đã được đơn giản hóa - không cần location_id validation phức tạp")

if __name__ == "__main__":
    main()
