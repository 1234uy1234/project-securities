#!/usr/bin/env python3
"""
Script start PWA services
"""

import subprocess
import time
import signal
import sys
import os

class PWAServices:
    def __init__(self):
        self.backend_process = None
        self.frontend_process = None
        self.backend_port = 8000
        self.frontend_port = 3000
        
    def start_backend(self):
        """Start backend service"""
        print("🚀 Starting backend service...")
        
        try:
            self.backend_process = subprocess.Popen([
                "python3", "-m", "uvicorn", 
                "backend.app.main:app", 
                "--host", "0.0.0.0", 
                "--port", str(self.backend_port),
                "--ssl-keyfile", "backend/key.pem",
                "--ssl-certfile", "backend/cert.pem",
                "--reload"
            ])
            
            print(f"✅ Backend started on port {self.backend_port}")
            return True
            
        except Exception as e:
            print(f"❌ Failed to start backend: {e}")
            return False
    
    def start_frontend(self):
        """Start frontend service"""
        print("🚀 Starting frontend service...")
        
        try:
            os.chdir("frontend")
            self.frontend_process = subprocess.Popen([
                "npm", "run", "dev", "--", 
                "--host", "0.0.0.0", 
                "--port", str(self.frontend_port)
            ])
            os.chdir("..")
            
            print(f"✅ Frontend started on port {self.frontend_port}")
            return True
            
        except Exception as e:
            print(f"❌ Failed to start frontend: {e}")
            os.chdir("..")
            return False
    
    def stop_services(self):
        """Stop all services"""
        print("🛑 Stopping services...")
        
        if self.backend_process:
            self.backend_process.terminate()
            print("✅ Backend stopped")
        
        if self.frontend_process:
            self.frontend_process.terminate()
            print("✅ Frontend stopped")
    
    def check_services(self):
        """Check if services are running"""
        backend_running = self.backend_process and self.backend_process.poll() is None
        frontend_running = self.frontend_process and self.frontend_process.poll() is None
        
        return backend_running, frontend_running
    
    def run(self):
        """Run services"""
        print("📱 PWA Services Manager")
        print("=" * 40)
        
        # Start backend
        if not self.start_backend():
            return False
        
        # Wait a bit for backend to start
        time.sleep(2)
        
        # Start frontend
        if not self.start_frontend():
            self.stop_services()
            return False
        
        # Wait for services to be ready
        time.sleep(3)
        
        print("\n🎉 Services started successfully!")
        print(f"🌐 Backend: https://localhost:{self.backend_port}")
        print(f"📱 Frontend: https://localhost:{self.frontend_port}")
        print(f"📱 PWA Install: https://localhost:{self.frontend_port}")
        
        print("\n📋 PWA Installation:")
        print("1. Open https://localhost:3000 on mobile")
        print("2. Tap 'Install App' or browser menu")
        print("3. App will be installed on home screen")
        
        print("\n⌨️ Press Ctrl+C to stop services")
        
        try:
            # Keep services running
            while True:
                backend_running, frontend_running = self.check_services()
                
                if not backend_running:
                    print("❌ Backend stopped unexpectedly")
                    break
                
                if not frontend_running:
                    print("❌ Frontend stopped unexpectedly")
                    break
                
                time.sleep(1)
                
        except KeyboardInterrupt:
            print("\n🛑 Shutting down...")
            self.stop_services()
            print("✅ Services stopped")

def main():
    services = PWAServices()
    
    # Handle Ctrl+C gracefully
    def signal_handler(sig, frame):
        print("\n🛑 Received interrupt signal")
        services.stop_services()
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    # Run services
    services.run()

if __name__ == "__main__":
    main()
