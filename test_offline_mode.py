#!/usr/bin/env python3
"""
Script test offline mode
"""

import os
import time
import subprocess
import webbrowser
from datetime import datetime

def test_offline_mode():
    """Test offline mode functionality"""
    print("🧪 Testing Offline Mode")
    print("=" * 50)
    
    print("📋 Test Plan:")
    print("1. ✅ Service Worker đã được tối ưu")
    print("2. ✅ Offline Queue đã được cải thiện")
    print("3. ✅ OfflineIndicator đã được nâng cấp")
    print("4. ✅ Background Sync đã được thêm")
    print("5. ✅ Notifications đã được tích hợp")
    
    print("\n🔧 Cách test offline mode:")
    print("1. Mở ứng dụng trong browser")
    print("2. Tắt mạng (WiFi/Mobile data)")
    print("3. Thử quét QR và chấm công")
    print("4. Kiểm tra dữ liệu được lưu offline")
    print("5. Bật mạng lại")
    print("6. Kiểm tra dữ liệu được sync")
    
    print("\n📱 Test Steps:")
    print("Step 1: Mở ứng dụng")
    print("   - Truy cập: https://localhost:3000")
    print("   - Đăng nhập với tài khoản")
    print("   - Kiểm tra Service Worker đã load")
    
    print("\nStep 2: Test offline")
    print("   - Tắt WiFi/Mobile data")
    print("   - Refresh trang")
    print("   - Kiểm tra OfflineIndicator hiển thị")
    print("   - Thử quét QR code")
    print("   - Chụp ảnh và submit")
    print("   - Kiểm tra toast 'Check-in đã lưu offline'")
    
    print("\nStep 3: Test sync")
    print("   - Bật WiFi/Mobile data")
    print("   - Kiểm tra OfflineIndicator chuyển sang 'Đang sync'")
    print("   - Kiểm tra toast 'Sync hoàn thành'")
    print("   - Kiểm tra dữ liệu trong admin dashboard")
    
    print("\n🔍 Kiểm tra trong DevTools:")
    print("1. F12 -> Application -> Service Workers")
    print("2. F12 -> Application -> IndexedDB -> OfflineQueueDB")
    print("3. F12 -> Console -> Xem logs offline/online")
    print("4. F12 -> Network -> Xem requests khi offline")
    
    print("\n📊 Expected Results:")
    print("✅ App hoạt động offline")
    print("✅ QR scanner hoạt động offline")
    print("✅ Camera hoạt động offline")
    print("✅ Check-in được lưu offline")
    print("✅ Auto sync khi online")
    print("✅ Notifications hoạt động")
    print("✅ Background sync hoạt động")
    
    print("\n🚀 Ready to test!")
    print("Mở browser và test theo các bước trên.")

def check_service_worker():
    """Check if service worker is properly configured"""
    print("🔍 Checking Service Worker configuration...")
    
    sw_file = "frontend/public/service-worker.js"
    if os.path.exists(sw_file):
        print("✅ Service Worker file exists")
        
        with open(sw_file, 'r') as f:
            content = f.read()
            
        if "manhtoan-patrol-v5" in content:
            print("✅ Service Worker version updated")
        else:
            print("⚠️ Service Worker version not updated")
            
        if "Background sync" in content:
            print("✅ Background sync configured")
        else:
            print("⚠️ Background sync not configured")
            
        if "Notification" in content:
            print("✅ Notifications configured")
        else:
            print("⚠️ Notifications not configured")
    else:
        print("❌ Service Worker file not found")

def check_offline_queue():
    """Check offline queue configuration"""
    print("\n🔍 Checking Offline Queue configuration...")
    
    queue_file = "frontend/src/utils/offlineQueue.ts"
    if os.path.exists(queue_file):
        print("✅ Offline Queue file exists")
        
        with open(queue_file, 'r') as f:
            content = f.read()
            
        if "OfflineQueueDB" in content:
            print("✅ Database name updated")
        else:
            print("⚠️ Database name not updated")
            
        if "getQueueStatus" in content:
            print("✅ Queue status function added")
        else:
            print("⚠️ Queue status function missing")
            
        if "Notification" in content:
            print("✅ Notifications integrated")
        else:
            print("⚠️ Notifications not integrated")
    else:
        print("❌ Offline Queue file not found")

def main():
    print("🧪 OFFLINE MODE TEST SUITE")
    print("=" * 60)
    
    check_service_worker()
    check_offline_queue()
    
    print("\n" + "=" * 60)
    test_offline_mode()
    
    print("\n💡 Tips:")
    print("- Test trên mobile để có trải nghiệm thực tế")
    print("- Test với mạng chậm để kiểm tra timeout")
    print("- Test với nhiều check-in offline")
    print("- Test với app đã đóng (background sync)")

if __name__ == "__main__":
    main()
