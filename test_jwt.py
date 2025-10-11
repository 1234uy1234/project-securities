#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))

from backend.app.auth import create_access_token
from backend.app.config import settings
from datetime import timedelta

def test_jwt():
    print("🔍 Testing JWT creation...")
    
    try:
        # Test JWT creation
        access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
        access_token = create_access_token(
            data={"sub": "admin"}, expires_delta=access_token_expires
        )
        
        print(f"✅ JWT created: {access_token[:50]}...")
        print(f"✅ Secret key: {settings.secret_key}")
        print(f"✅ Algorithm: {settings.algorithm}")
        print(f"✅ Expire minutes: {settings.access_token_expire_minutes}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_jwt()

