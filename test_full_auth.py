#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))

from backend.app.database import get_db
from backend.app.auth import authenticate_user, create_access_token
from backend.app.models import User
from backend.app.schemas import LoginRequest
from datetime import timedelta

def test_full_auth():
    print("🔍 Testing full authentication flow...")
    
    try:
        # Get database session
        db = next(get_db())
        print("✅ Database connection OK")
        
        # Test login request
        login_data = LoginRequest(username="admin", password="admin123")
        print(f"✅ Login request: {login_data.username}")
        
        # Test authentication
        user = authenticate_user(db, login_data.username, login_data.password)
        if not user:
            print("❌ Authentication failed")
            return
        
        print(f"✅ User authenticated: {user.username}")
        
        if not user.is_active:
            print("❌ User inactive")
            return
        
        print("✅ User is active")
        
        # Test JWT creation
        access_token_expires = timedelta(minutes=30)
        access_token = create_access_token(
            data={"sub": user.username}, expires_delta=access_token_expires
        )
        
        print(f"✅ JWT created: {access_token[:50]}...")
        
        # Test response
        response = {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user
        }
        
        print("✅ Full authentication flow successful")
        print(f"✅ Response keys: {list(response.keys())}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_full_auth()

