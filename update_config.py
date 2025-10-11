#!/usr/bin/env python3
import sys
import re

if len(sys.argv) != 2:
    print("Usage: python3 update_config.py <ngrok_url>")
    print("Example: python3 update_config.py https://abc123.ngrok-free.app")
    sys.exit(1)

ngrok_url = sys.argv[1].rstrip('/')

print(f"Updating config with ngrok URL: {ngrok_url}")

# Update backend config
print("Updating backend config...")
with open('backend/app/config.py', 'r') as f:
    content = f.read()

# Update allowed_origins
allowed_origins = f"['{ngrok_url}', '{ngrok_url}:5173']"
content = re.sub(r"allowed_origins = .*", f"allowed_origins = {allowed_origins}", content)

# Update frontend_base_url
content = re.sub(r"frontend_base_url = .*", f"frontend_base_url = '{ngrok_url}'", content)

with open('backend/app/config.py', 'w') as f:
    f.write(content)

print("✅ Backend config updated")

# Update frontend config
print("Updating frontend config...")

# Update .env.local
env_content = f"""VITE_API_BASE_URL={ngrok_url}/api
VITE_FRONTEND_URL={ngrok_url}
VITE_BACKEND_URL={ngrok_url}
VITE_WS_URL={ngrok_url}/ws
"""

with open('frontend/.env.local', 'w') as f:
    f.write(env_content)

print("✅ Frontend .env.local updated")

# Update .env
with open('frontend/.env', 'w') as f:
    f.write(env_content)

print("✅ Frontend .env updated")

# Update vite config
print("Updating vite config...")
with open('frontend/vite.config.ts', 'r') as f:
    vite_content = f.read()

vite_content = re.sub(r"backendUrl.*=.*", f"backendUrl = '{ngrok_url}'", vite_content)

with open('frontend/vite.config.ts', 'w') as f:
    f.write(vite_content)

print("✅ Vite config updated")

print("")
print("🎉 CONFIG UPDATE COMPLETE!")
print(f"Backend URL: {ngrok_url}")
print(f"Frontend URL: {ngrok_url}")
print("")
print("Now restart your services:")
print("1. Restart backend: cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload")
print("2. Restart frontend: cd frontend && npm run dev")
print("")
print("You can now access your app from mobile devices!")
print(f"Backend API: {ngrok_url}/api")
print(f"Frontend App: {ngrok_url}")

