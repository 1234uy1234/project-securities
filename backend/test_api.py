#!/usr/bin/env python3

import requests
import json

def test_login():
    print("Testing login API...")
    
    url = "https://10.10.68.22:8000/auth/login"
    data = {
        "username": "admin",
        "password": "admin123"
    }
    
    try:
        response = requests.post(url, json=data, headers={"Content-Type": "application/json"})
        print(f"Status code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"Login successful! Token: {result.get('access_token', 'No token')}")
        else:
            print("Login failed")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_login()
