#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))

def test_fastapi():
    print("🔍 Testing FastAPI imports...")
    
    try:
        from backend.app.main import app
        print("✅ FastAPI app imported successfully")
        
        from backend.app.routes.auth import router
        print("✅ Auth router imported successfully")
        
        from backend.app.schemas import LoginRequest
        print("✅ LoginRequest schema imported successfully")
        
        print("✅ All imports successful")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_fastapi()

