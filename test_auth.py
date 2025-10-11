#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))

from backend.app.database import get_db
from backend.app.auth import authenticate_user
from backend.app.models import User

def test_auth():
    print("🔍 Testing authentication...")
    
    try:
        # Get database session
        db = next(get_db())
        print("✅ Database connection OK")
        
        # Test user query
        user = db.query(User).filter(User.username == "admin").first()
        if user:
            print(f"✅ User found: {user.username}")
            print(f"✅ User active: {user.is_active}")
            print(f"✅ Password hash: {user.password_hash[:20]}...")
        else:
            print("❌ User not found")
            return
        
        # Test authentication
        result = authenticate_user(db, "admin", "admin123")
        if result:
            print("✅ Authentication successful")
        else:
            print("❌ Authentication failed")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_auth()

