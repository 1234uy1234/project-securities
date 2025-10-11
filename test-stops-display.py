#!/usr/bin/env python3
"""
Test script để kiểm tra vấn đề stops hiển thị sai tên QR
"""

import requests
import json
import sys

# Cấu hình
BASE_URL = "http://localhost:8000"
LOGIN_URL = f"{BASE_URL}/auth/login"
QR_GENERATE_URL = f"{BASE_URL}/qr-codes/generate-simple"
QR_LIST_URL = f"{BASE_URL}/qr-codes/"
TASK_CREATE_URL = f"{BASE_URL}/patrol-tasks/"
TASK_LIST_URL = f"{BASE_URL}/patrol-tasks/"

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

def create_qr_codes(token):
    """Tạo một số QR codes để test"""
    qr_names = ["Nhà sảnh A", "Khu vực B", "Tầng 3"]
    created_qrs = []
    
    for qr_name in qr_names:
        headers = {"Authorization": f"Bearer {token}"}
        data = {
            "data": qr_name,
            "type": "static"
        }
        
        try:
            response = requests.post(QR_GENERATE_URL, headers=headers, data=data)
            if response.status_code == 200:
                result = response.json()
                created_qrs.append(result)
                print(f"✅ Tạo QR code: {qr_name} (ID: {result.get('id')})")
            else:
                print(f"❌ Lỗi tạo QR code {qr_name}: {response.status_code}")
        except Exception as e:
            print(f"❌ Lỗi tạo QR code {qr_name}: {e}")
    
    return created_qrs

def list_qr_codes(token):
    """Lấy danh sách QR codes"""
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(QR_LIST_URL, headers=headers)
        if response.status_code == 200:
            qr_codes = response.json()
            print(f"✅ Lấy danh sách QR codes: {len(qr_codes)} QR codes")
            return qr_codes
        else:
            print(f"❌ Lỗi lấy danh sách QR codes: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Lỗi lấy danh sách QR codes: {e}")
        return None

def create_task_with_stops(token, qr_codes):
    """Tạo task với stops từ QR codes"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Tạo stops từ QR codes
    stops = []
    for i, qr in enumerate(qr_codes[:2]):  # Chỉ lấy 2 QR codes đầu
        stops.append({
            "qr_code_name": qr.get('data'),  # Sử dụng data thay vì content
            "scheduled_time": f"0{i+8}:00",  # 08:00, 09:00
            "required": True
        })
    
    task_data = {
        "title": "Test Task với Stops",
        "description": "Task để test stops hiển thị đúng tên QR",
        "assigned_to": 1,
        "location_id": "Vị trí chính test",
        "schedule_week": {
            "date": "2025-01-20",
            "startTime": "08:00",
            "endTime": "17:00"
        },
        "stops": stops
    }
    
    print(f"🔍 Tạo task với stops: {stops}")
    
    try:
        response = requests.post(TASK_CREATE_URL, headers=headers, json=task_data)
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Tạo task thành công: {result.get('title')}")
            print(f"   - Task ID: {result.get('id')}")
            print(f"   - Stops: {len(result.get('stops', []))}")
            
            # Kiểm tra stops
            for stop in result.get('stops', []):
                print(f"   - Stop: {stop.get('location_name')} (ID: {stop.get('location_id')})")
            
            return result
        else:
            print(f"❌ Lỗi tạo task: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"❌ Lỗi tạo task: {e}")
        return None

def get_task_details(token, task_id):
    """Lấy chi tiết task để kiểm tra stops"""
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{TASK_LIST_URL}{task_id}", headers=headers)
        if response.status_code == 200:
            task = response.json()
            print(f"✅ Lấy chi tiết task: {task.get('title')}")
            print(f"   - Stops: {len(task.get('stops', []))}")
            
            for stop in task.get('stops', []):
                print(f"   - Stop: {stop.get('location_name')} (ID: {stop.get('location_id')})")
            
            return task
        else:
            print(f"❌ Lỗi lấy chi tiết task: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ Lỗi lấy chi tiết task: {e}")
        return None

def main():
    print("🧪 TEST: Kiểm tra vấn đề stops hiển thị sai tên QR")
    print("=" * 70)
    
    # 1. Đăng nhập
    print("\n1. Đăng nhập...")
    token = login()
    if not token:
        print("❌ Không thể đăng nhập, dừng test")
        return
    
    # 2. Tạo QR codes
    print("\n2. Tạo QR codes...")
    created_qrs = create_qr_codes(token)
    if not created_qrs:
        print("❌ Không thể tạo QR codes, dừng test")
        return
    
    # 3. Lấy danh sách QR codes
    print("\n3. Lấy danh sách QR codes...")
    all_qrs = list_qr_codes(token)
    if not all_qrs:
        print("❌ Không thể lấy danh sách QR codes, dừng test")
        return
    
    # Hiển thị QR codes
    print("📋 QR codes hiện có:")
    for qr in all_qrs[-5:]:  # 5 QR codes gần nhất
        print(f"   - ID: {qr.get('id')}, Data: '{qr.get('data')}', Content: '{qr.get('qr_content')}'")
    
    # 4. Tạo task với stops
    print("\n4. Tạo task với stops...")
    task_result = create_task_with_stops(token, created_qrs)
    if not task_result:
        print("❌ Không thể tạo task, dừng test")
        return
    
    # 5. Kiểm tra chi tiết task
    print("\n5. Kiểm tra chi tiết task...")
    task_details = get_task_details(token, task_result.get('id'))
    if not task_details:
        print("❌ Không thể lấy chi tiết task, dừng test")
        return
    
    # 6. Kết quả
    print("\n" + "=" * 70)
    print("🎉 TEST HOÀN THÀNH!")
    
    # Kiểm tra xem stops có hiển thị đúng tên không
    stops = task_details.get('stops', [])
    if stops:
        print("📋 Stops trong task:")
        for stop in stops:
            location_name = stop.get('location_name', 'N/A')
            print(f"   - {location_name}")
            
            # Kiểm tra xem tên có đúng không
            if any(qr.get('data') in location_name for qr in created_qrs):
                print(f"     ✅ Tên đúng!")
            else:
                print(f"     ❌ Tên có thể sai!")
    else:
        print("❌ Không có stops trong task!")

if __name__ == "__main__":
    main()
