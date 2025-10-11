#!/usr/bin/env python3
"""
Script tổng hợp để thực hiện migration hoàn chỉnh sang IP mới
Bao gồm: config, data, services, QR codes, cron jobs
"""

import os
import sys
import subprocess
import time
from datetime import datetime

class CompleteMigrator:
    def __init__(self, new_ip):
        self.new_ip = new_ip
        self.old_ip = "localhost"
        self.project_root = "/Users/maybe/Documents/shopee"
        
    def run_script(self, script_path, args=None):
        """Chạy script với error handling"""
        try:
            cmd = ["python3", script_path]
            if args:
                cmd.extend(args)
            
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.project_root)
            
            if result.returncode == 0:
                print(f"✅ {script_path} completed successfully")
                return True
            else:
                print(f"❌ {script_path} failed: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"❌ Error running {script_path}: {e}")
            return False
    
    def run_shell_script(self, script_path, args=None):
        """Chạy shell script với error handling"""
        try:
            cmd = ["bash", script_path]
            if args:
                cmd.extend(args)
            
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=self.project_root)
            
            if result.returncode == 0:
                print(f"✅ {script_path} completed successfully")
                return True
            else:
                print(f"❌ {script_path} failed: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"❌ Error running {script_path}: {e}")
            return False
    
    def check_prerequisites(self):
        """Kiểm tra prerequisites"""
        print("🔍 Kiểm tra prerequisites...")
        
        # Check Python
        try:
            result = subprocess.run(["python3", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Python: {result.stdout.strip()}")
            else:
                print("❌ Python3 not found")
                return False
        except:
            print("❌ Python3 not found")
            return False
        
        # Check Node.js
        try:
            result = subprocess.run(["node", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Node.js: {result.stdout.strip()}")
            else:
                print("❌ Node.js not found")
                return False
        except:
            print("❌ Node.js not found")
            return False
        
        # Check npm
        try:
            result = subprocess.run(["npm", "--version"], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ npm: {result.stdout.strip()}")
            else:
                print("❌ npm not found")
                return False
        except:
            print("❌ npm not found")
            return False
        
        # Check required directories
        required_dirs = ["frontend", "backend"]
        for dir_name in required_dirs:
            if os.path.exists(f"{self.project_root}/{dir_name}"):
                print(f"✅ Directory: {dir_name}")
            else:
                print(f"❌ Directory not found: {dir_name}")
                return False
        
        print("✅ Prerequisites check passed")
        return True
    
    def stop_existing_services(self):
        """Dừng các services hiện tại"""
        print("🛑 Dừng các services hiện tại...")
        
        try:
            # Kill frontend processes
            subprocess.run(["pkill", "-f", "npm.*dev"], capture_output=True)
            subprocess.run(["pkill", "-f", "vite"], capture_output=True)
            
            # Kill backend processes
            subprocess.run(["pkill", "-f", "uvicorn"], capture_output=True)
            subprocess.run(["pkill", "-f", "python.*main:app"], capture_output=True)
            
            # Kill nginx
            subprocess.run(["pkill", "-f", "nginx"], capture_output=True)
            
            time.sleep(3)
            print("✅ Services stopped")
            return True
            
        except Exception as e:
            print(f"⚠️ Error stopping services: {e}")
            return True  # Continue anyway
    
    def migrate_system(self):
        """Thực hiện migration hệ thống"""
        print("🔄 Thực hiện migration hệ thống...")
        
        # 1. Migrate config và data
        if not self.run_script("migrate_to_new_ip.py", [self.new_ip]):
            return False
        
        # 2. Backup và migrate data
        if not self.run_script("backup_and_migrate_data.py", [self.new_ip]):
            return False
        
        print("✅ System migration completed")
        return True
    
    def restart_services(self):
        """Restart services với IP mới"""
        print("🚀 Restart services với IP mới...")
        
        # Make script executable
        os.chmod(f"{self.project_root}/restart_after_migration.sh", 0o755)
        
        # Run restart script
        if not self.run_shell_script("restart_after_migration.sh", [self.new_ip]):
            return False
        
        print("✅ Services restarted")
        return True
    
    def test_system(self):
        """Test hệ thống sau migration"""
        print("🧪 Test hệ thống sau migration...")
        
        import requests
        import urllib3
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
        
        # Test backend API
        try:
            response = requests.get(f"https://{self.new_ip}:8000/api/health", verify=False, timeout=10)
            if response.status_code == 200:
                print("✅ Backend API: OK")
            else:
                print(f"❌ Backend API: HTTP {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Backend API: {e}")
            return False
        
        # Test frontend
        try:
            response = requests.get(f"https://{self.new_ip}:3000", verify=False, timeout=10)
            if response.status_code == 200:
                print("✅ Frontend: OK")
            else:
                print(f"❌ Frontend: HTTP {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Frontend: {e}")
            return False
        
        # Test PWA manifest
        try:
            response = requests.get(f"https://{self.new_ip}:3000/manifest.json", verify=False, timeout=10)
            if response.status_code == 200:
                print("✅ PWA Manifest: OK")
            else:
                print(f"❌ PWA Manifest: HTTP {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ PWA Manifest: {e}")
            return False
        
        print("✅ System tests passed")
        return True
    
    def create_final_report(self):
        """Tạo báo cáo cuối cùng"""
        report = f"""
# 🎉 MIGRATION HOÀN TẤT - BÁO CÁO CUỐI CÙNG

## 📊 Thông tin Migration
- **IP cũ**: {self.old_ip}
- **IP mới**: {self.new_ip}
- **Thời gian hoàn thành**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Trạng thái**: ✅ THÀNH CÔNG

## 🔗 URLs mới
- **PWA Install**: https://{self.new_ip}:3000
- **Admin Dashboard**: https://{self.new_ip}:3000/admin
- **API Base**: https://{self.new_ip}:8000/api
- **WebSocket**: wss://{self.new_ip}:8000/ws

## 📱 QR Code mới
- **File**: pwa_install_qr_{self.new_ip.replace('.', '_')}.png
- **URL**: https://{self.new_ip}:3000

## ✅ Đã hoàn thành

### 1. System Migration
- ✅ Cập nhật frontend config
- ✅ Cập nhật backend config
- ✅ Cập nhật nginx config
- ✅ Cập nhật script files
- ✅ Cập nhật cron jobs

### 2. Data Migration
- ✅ Backup toàn bộ dữ liệu
- ✅ Migrate database URLs
- ✅ Migrate file paths
- ✅ Tạo migration package
- ✅ Tạo deployment guide

### 3. Services Restart
- ✅ Generate SSL certificates mới
- ✅ Start backend service
- ✅ Start frontend service
- ✅ Start nginx service

### 4. System Testing
- ✅ Backend API health check
- ✅ Frontend accessibility
- ✅ PWA manifest validation

## 📋 Files đã tạo
- `migration_package_{self.new_ip.replace('.', '_')}_*.zip` - Migration package
- `migration_backup_*` - Backup data
- `pwa_install_qr_{self.new_ip.replace('.', '_')}.png` - QR code mới
- `migration_report_{self.new_ip.replace('.', '_')}.md` - Migration report
- `DEPLOYMENT_GUIDE_{self.new_ip.replace('.', '_')}.md` - Deployment guide
- `migration_status_{self.new_ip.replace('.', '_')}.txt` - Status report

## 🚀 Bước tiếp theo

### 1. Thông báo cho Users
- Gửi QR code mới: `pwa_install_qr_{self.new_ip.replace('.', '_')}.png`
- Hướng dẫn cài đặt lại PWA
- Thông báo IP mới

### 2. Monitoring
```bash
# Check logs
tail -f backend.log
tail -f frontend.log

# Check services
ps aux | grep uvicorn
ps aux | grep npm
ps aux | grep nginx

# Health check
curl -k https://{self.new_ip}:8000/api/health
```

### 3. Backup Strategy
- Backup data hàng ngày
- Monitor disk space
- Test restore procedures

## 🆘 Troubleshooting

### Nếu có vấn đề:
1. Check logs: `tail -f backend.log frontend.log`
2. Restart services: `./restart_after_migration.sh {self.new_ip}`
3. Rollback nếu cần: Sử dụng backup data

### Common Issues:
- **SSL Certificate**: Trust certificate trong browser
- **PWA Update**: Users cần cài đặt lại PWA
- **Database**: Check integrity với `sqlite3 backend/app.db "PRAGMA integrity_check;"`

## 📞 Support Information
- **Project Root**: {self.project_root}
- **Backup Location**: migration_backup_*
- **Migration Package**: migration_package_{self.new_ip.replace('.', '_')}_*.zip
- **Logs**: backend.log, frontend.log, nginx_access.log

---
## 🎊 MIGRATION THÀNH CÔNG!

Hệ thống đã được migration hoàn toàn sang IP mới: **{self.new_ip}**

Tất cả services đang hoạt động bình thường và sẵn sàng phục vụ users.

**PWA URL mới**: https://{self.new_ip}:3000
**QR Code**: pwa_install_qr_{self.new_ip.replace('.', '_')}.png

---
*Migration completed successfully at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}* 🎉
"""
        
        with open(f"FINAL_MIGRATION_REPORT_{self.new_ip.replace('.', '_')}.md", 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"✅ Đã tạo báo cáo cuối cùng: FINAL_MIGRATION_REPORT_{self.new_ip.replace('.', '_')}.md")
    
    def migrate(self):
        """Thực hiện migration hoàn chỉnh"""
        print(f"🚀 BẮT ĐẦU MIGRATION HOÀN CHỈNH SANG IP MỚI: {self.new_ip}")
        print("=" * 80)
        
        try:
            # 1. Check prerequisites
            if not self.check_prerequisites():
                print("❌ Prerequisites check failed")
                return False
            
            # 2. Stop existing services
            self.stop_existing_services()
            
            # 3. Migrate system
            if not self.migrate_system():
                print("❌ System migration failed")
                return False
            
            # 4. Restart services
            if not self.restart_services():
                print("❌ Services restart failed")
                return False
            
            # 5. Test system
            if not self.test_system():
                print("❌ System tests failed")
                return False
            
            # 6. Create final report
            self.create_final_report()
            
            print("\n🎉 MIGRATION HOÀN CHỈNH THÀNH CÔNG!")
            print("=" * 80)
            print(f"📍 IP mới: {self.new_ip}")
            print(f"📱 PWA URL: https://{self.new_ip}:3000")
            print(f"🔧 API URL: https://{self.new_ip}:8000/api")
            print(f"📱 QR Code: pwa_install_qr_{self.new_ip.replace('.', '_')}.png")
            print(f"📋 Final Report: FINAL_MIGRATION_REPORT_{self.new_ip.replace('.', '_')}.md")
            
            print("\n🚀 Hệ thống đã sẵn sàng!")
            print("1. Share QR code với users")
            print("2. Monitor logs và performance")
            print("3. Test các tính năng chính")
            
            return True
            
        except Exception as e:
            print(f"❌ Lỗi migration: {e}")
            return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 complete_migration.py NEW_IP")
        print("Example: python3 complete_migration.py 192.168.1.100")
        sys.exit(1)
    
    new_ip = sys.argv[1]
    
    # Xác nhận migration
    print(f"⚠️  BẠN SẮP THỰC HIỆN MIGRATION HOÀN CHỈNH SANG IP MỚI: {new_ip}")
    print("\nĐiều này sẽ:")
    print("- Dừng tất cả services hiện tại")
    print("- Cập nhật toàn bộ config files")
    print("- Backup và migrate dữ liệu")
    print("- Restart services với IP mới")
    print("- Test hệ thống")
    print("- Tạo QR codes và reports mới")
    
    print(f"\n⚠️  QUAN TRỌNG: Hệ thống sẽ tạm thời không khả dụng trong quá trình migration!")
    
    confirm = input("\nBạn có chắc chắn muốn tiếp tục? (y/N): ")
    if confirm.lower() != 'y':
        print("❌ Migration đã hủy")
        sys.exit(0)
    
    # Thực hiện migration
    migrator = CompleteMigrator(new_ip)
    success = migrator.migrate()
    
    if success:
        print("\n✅ MIGRATION HOÀN CHỈNH THÀNH CÔNG!")
        print("🎉 Hệ thống đã sẵn sàng với IP mới!")
        sys.exit(0)
    else:
        print("\n❌ MIGRATION THẤT BẠI!")
        print("🔧 Vui lòng check logs và thử lại")
        sys.exit(1)

if __name__ == "__main__":
    main()

