#!/usr/bin/env python3
"""
Test script để kiểm tra API endpoint /checkin/admin/all-records
"""

import requests
import json
import sys

def test_admin_records_api():
    """Test API endpoint /checkin/admin/all-records"""
    
    # Login để lấy token
    login_url = "https://127.0.0.1:8000/api/auth/login"
    login_data = {
        "username": "admin",
        "password": "admin123"
    }
    
    try:
        print("🔍 Testing admin records API...")
        
        # Login
        login_response = requests.post(login_url, json=login_data, verify=False, timeout=10)
        if login_response.status_code != 200:
            print(f"❌ Login failed: {login_response.status_code}")
            return
        
        token = login_response.json().get('access_token')
        if not token:
            print("❌ No access token received")
            return
        
        print("✅ Login successful")
        
        # Get admin records
        records_url = "https://127.0.0.1:8000/api/checkin/admin/all-records"
        headers = {"Authorization": f"Bearer {token}"}
        
        records_response = requests.get(records_url, headers=headers, verify=False, timeout=10)
        if records_response.status_code != 200:
            print(f"❌ Records API failed: {records_response.status_code}")
            return
        
        records = records_response.json()
        print(f"✅ Records API successful: {len(records)} records")
        
        # Tìm record với task_id=28, location_id=37
        target_record = None
        for record in records:
            if record.get('task_id') == 28 and record.get('location_id') == 37:
                target_record = record
                break
        
        if target_record:
            print(f"✅ Found target record:")
            print(f"  ID: {target_record.get('id')}")
            print(f"  Task ID: {target_record.get('task_id')}")
            print(f"  Location ID: {target_record.get('location_id')}")
            print(f"  Check in time: {target_record.get('check_in_time')}")
            print(f"  Photo URL: {target_record.get('photo_url')}")
            print(f"  Notes: {target_record.get('notes')}")
        else:
            print("❌ Target record not found")
            print("Available records:")
            for record in records:
                print(f"  ID: {record.get('id')}, Task ID: {record.get('task_id')}, Location ID: {record.get('location_id')}")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_admin_records_api()
