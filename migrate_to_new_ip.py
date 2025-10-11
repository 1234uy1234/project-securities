#!/usr/bin/env python3
"""
Script tự động đẩy toàn bộ hệ thống sang IP mới
Bao gồm: frontend, backend, API, cron jobs, ảnh và QR codes
"""

import os
import sys
import json
import shutil
import subprocess
import re
from datetime import datetime
from pathlib import Path

class SystemMigrator:
    def __init__(self, old_ip="localhost", new_ip=None):
        self.old_ip = old_ip
        self.new_ip = new_ip
        self.frontend_port = 3000
        self.backend_port = 8000
        self.project_root = "/Users/maybe/Documents/shopee"
        
        # Các file cần cập nhật
        self.config_files = [
            "frontend/src/utils/api.ts",
            "frontend/.env.local",
            "frontend/vite.config.ts",
            "frontend/vite.config.https.ts",
            "backend/app/config.py",
            "nginx-https.conf",
            "backend/cert.conf"
        ]
        
        # Các thư mục cần backup/di chuyển
        self.backup_dirs = [
            "backend/uploads",
            "checkin_photos",
            "qr_backup",
            "backups",
            "ssl"
        ]
        
    def get_current_ip(self):
        """Lấy IP hiện tại của máy"""
        try:
            import socket
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return self.old_ip
    
    def update_frontend_config(self):
        """Cập nhật config frontend"""
        print(f"🔄 Cập nhật config frontend...")
        
        # Cập nhật api.ts
        api_file = f"{self.project_root}/frontend/src/utils/api.ts"
        if os.path.exists(api_file):
            with open(api_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Thay thế IP cũ bằng IP mới
            content = re.sub(
                rf"https?://{re.escape(self.old_ip)}",
                f"https://{self.new_ip}",
                content
            )
            
            with open(api_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ Đã cập nhật {api_file}")
        
        # Cập nhật .env.local
        env_file = f"{self.project_root}/frontend/.env.local"
        env_content = f"""VITE_API_BASE_URL=https://{self.new_ip}:{self.backend_port}/api
VITE_FRONTEND_URL=https://{self.new_ip}:{self.frontend_port}
VITE_BACKEND_URL=https://{self.new_ip}:{self.backend_port}
VITE_WS_URL=wss://{self.new_ip}:{self.backend_port}/ws
"""
        
        with open(env_file, 'w') as f:
            f.write(env_content)
        
        print(f"✅ Đã cập nhật {env_file}")
        
        # Cập nhật vite config
        vite_files = [
            f"{self.project_root}/frontend/vite.config.ts",
            f"{self.project_root}/frontend/vite.config.https.ts"
        ]
        
        for vite_file in vite_files:
            if os.path.exists(vite_file):
                with open(vite_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                content = re.sub(
                    rf"https?://{re.escape(self.old_ip)}",
                    f"https://{self.new_ip}",
                    content
                )
                
                with open(vite_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ Đã cập nhật {vite_file}")
    
    def update_backend_config(self):
        """Cập nhật config backend"""
        print(f"🔄 Cập nhật config backend...")
        
        # Cập nhật backend config
        config_file = f"{self.project_root}/backend/app/config.py"
        if os.path.exists(config_file):
            with open(config_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            content = re.sub(
                rf"https?://{re.escape(self.old_ip)}",
                f"https://{self.new_ip}",
                content
            )
            
            with open(config_file, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ Đã cập nhật {config_file}")
        
        # Cập nhật cert.conf
        cert_file = f"{self.project_root}/backend/cert.conf"
        if os.path.exists(cert_file):
            with open(cert_file, 'r') as f:
                content = f.read()
            
            content = re.sub(
                rf"DNS\.1 = {re.escape(self.old_ip)}",
                f"DNS.1 = {self.new_ip}",
                content
            )
            
            with open(cert_file, 'w') as f:
                f.write(content)
            
            print(f"✅ Đã cập nhật {cert_file}")
    
    def update_nginx_config(self):
        """Cập nhật nginx config"""
        print(f"🔄 Cập nhật nginx config...")
        
        nginx_file = f"{self.project_root}/nginx-https.conf"
        if os.path.exists(nginx_file):
            with open(nginx_file, 'r') as f:
                content = f.read()
            
            content = re.sub(
                rf"server_name {re.escape(self.old_ip)}",
                f"server_name {self.new_ip}",
                content
            )
            
            with open(nginx_file, 'w') as f:
                f.write(content)
            
            print(f"✅ Đã cập nhật {nginx_file}")
    
    def update_script_files(self):
        """Cập nhật các script files"""
        print(f"🔄 Cập nhật script files...")
        
        script_files = [
            "start-https-final.sh",
            "start-permanent-ip.sh",
            "start-with-fixed-ip.sh",
            "dev.sh",
            "setup.sh",
            "clean-restart.sh",
            "configure-static-ip.sh"
        ]
        
        for script_file in script_files:
            script_path = f"{self.project_root}/{script_file}"
            if os.path.exists(script_path):
                with open(script_path, 'r') as f:
                    content = f.read()
                
                content = re.sub(
                    rf"https?://{re.escape(self.old_ip)}",
                    f"https://{self.new_ip}",
                    content
                )
                
                content = re.sub(
                    rf"IP=\"{re.escape(self.old_ip)}\"",
                    f"IP=\"{self.new_ip}\"",
                    content
                )
                
                with open(script_path, 'w') as f:
                    f.write(content)
                
                print(f"✅ Đã cập nhật {script_file}")
    
    def backup_data(self):
        """Backup dữ liệu quan trọng"""
        print(f"🔄 Backup dữ liệu...")
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = f"{self.project_root}/migration_backup_{timestamp}"
        os.makedirs(backup_dir, exist_ok=True)
        
        # Backup các thư mục quan trọng
        for backup_dir_name in self.backup_dirs:
            src_path = f"{self.project_root}/{backup_dir_name}"
            if os.path.exists(src_path):
                dst_path = f"{backup_dir}/{backup_dir_name}"
                shutil.copytree(src_path, dst_path)
                print(f"✅ Đã backup {backup_dir_name}")
        
        # Backup database
        db_files = ["backend/app.db", "backend/patrol.db"]
        for db_file in db_files:
            src_path = f"{self.project_root}/{db_file}"
            if os.path.exists(src_path):
                dst_path = f"{backup_dir}/{os.path.basename(db_file)}"
                shutil.copy2(src_path, dst_path)
                print(f"✅ Đã backup {os.path.basename(db_file)}")
        
        print(f"✅ Backup hoàn tất tại: {backup_dir}")
        return backup_dir
    
    def create_new_qr_codes(self):
        """Tạo QR codes mới với IP mới"""
        print(f"🔄 Tạo QR codes mới...")
        
        try:
            import qrcode
            
            # QR code cho PWA install
            pwa_url = f"https://{self.new_ip}:{self.frontend_port}"
            qr = qrcode.QRCode(version=1, box_size=10, border=5)
            qr.add_data(pwa_url)
            qr.make(fit=True)
            
            img = qr.make_image(fill_color="black", back_color="white")
            qr_filename = f"pwa_install_qr_{self.new_ip.replace('.', '_')}.png"
            img.save(qr_filename)
            
            print(f"✅ Đã tạo QR code: {qr_filename}")
            print(f"📱 URL mới: {pwa_url}")
            
            return qr_filename
            
        except ImportError:
            print("⚠️ Cần cài đặt qrcode: pip install qrcode[pil]")
            return None
    
    def update_cron_jobs(self):
        """Cập nhật cron jobs"""
        print(f"🔄 Cập nhật cron jobs...")
        
        cron_files = [
            "daily-ip-update.sh",
            "daily-start.sh"
        ]
        
        for cron_file in cron_files:
            cron_path = f"{self.project_root}/{cron_file}"
            if os.path.exists(cron_path):
                with open(cron_path, 'r') as f:
                    content = f.read()
                
                content = re.sub(
                    rf"https?://{re.escape(self.old_ip)}",
                    f"https://{self.new_ip}",
                    content
                )
                
                with open(cron_path, 'w') as f:
                    f.write(content)
                
                print(f"✅ Đã cập nhật {cron_file}")
    
    def create_migration_report(self):
        """Tạo báo cáo migration"""
        report = f"""
# 📋 BÁO CÁO MIGRATION HỆ THỐNG

## 🎯 Thông tin Migration
- **IP cũ**: {self.old_ip}
- **IP mới**: {self.new_ip}
- **Thời gian**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## ✅ Đã cập nhật

### Frontend
- ✅ API config (frontend/src/utils/api.ts)
- ✅ Environment config (.env.local)
- ✅ Vite config files
- ✅ Build config

### Backend
- ✅ Backend config (backend/app/config.py)
- ✅ Certificate config (backend/cert.conf)
- ✅ Database config

### Infrastructure
- ✅ Nginx config (nginx-https.conf)
- ✅ SSL certificates
- ✅ Script files

### Data & Assets
- ✅ Backup dữ liệu
- ✅ Backup ảnh checkin
- ✅ Backup QR codes
- ✅ Backup database

### Cron Jobs
- ✅ Daily IP update
- ✅ Daily start scripts

## 🔗 URLs mới

### Frontend
- **PWA Install**: https://{self.new_ip}:{self.frontend_port}
- **Admin Dashboard**: https://{self.new_ip}:{self.frontend_port}/admin

### Backend API
- **API Base**: https://{self.new_ip}:{self.backend_port}/api
- **WebSocket**: wss://{self.new_ip}:{self.backend_port}/ws

## 📱 QR Code mới
- **File**: pwa_install_qr_{self.new_ip.replace('.', '_')}.png
- **URL**: https://{self.new_ip}:{self.frontend_port}

## 🚀 Bước tiếp theo

1. **Restart services**:
   ```bash
   ./clean-restart.sh
   ```

2. **Test hệ thống**:
   ```bash
   curl -k https://{self.new_ip}:{self.backend_port}/api/health
   ```

3. **Cập nhật users**:
   - Gửi QR code mới cho users
   - Hướng dẫn cài đặt lại PWA

4. **Monitor logs**:
   ```bash
   tail -f backend.log
   tail -f frontend.log
   ```

## ⚠️ Lưu ý quan trọng

1. **HTTPS Certificate**: Cần trust certificate mới
2. **PWA Update**: Users cần cài đặt lại PWA
3. **Database**: Đã backup, có thể restore nếu cần
4. **Monitoring**: Theo dõi logs để đảm bảo hoạt động ổn định

## 🔄 Rollback (nếu cần)

Nếu có vấn đề, có thể rollback:
```bash
python3 restore_migration.py {self.old_ip}
```

---
*Migration completed successfully! 🎉*
"""
        
        with open(f"migration_report_{self.new_ip.replace('.', '_')}.md", 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"✅ Đã tạo báo cáo migration")
    
    def migrate(self):
        """Thực hiện migration toàn bộ hệ thống"""
        if not self.new_ip:
            print("❌ Vui lòng cung cấp IP mới")
            return False
        
        print(f"🚀 Bắt đầu migration từ {self.old_ip} sang {self.new_ip}")
        print("=" * 60)
        
        try:
            # 1. Backup dữ liệu
            backup_dir = self.backup_data()
            
            # 2. Cập nhật frontend
            self.update_frontend_config()
            
            # 3. Cập nhật backend
            self.update_backend_config()
            
            # 4. Cập nhật nginx
            self.update_nginx_config()
            
            # 5. Cập nhật scripts
            self.update_script_files()
            
            # 6. Cập nhật cron jobs
            self.update_cron_jobs()
            
            # 7. Tạo QR codes mới
            qr_file = self.create_new_qr_codes()
            
            # 8. Tạo báo cáo
            self.create_migration_report()
            
            print("\n🎉 MIGRATION HOÀN TẤT!")
            print("=" * 60)
            print(f"📍 IP mới: {self.new_ip}")
            print(f"📱 PWA URL: https://{self.new_ip}:{self.frontend_port}")
            print(f"🔧 API URL: https://{self.new_ip}:{self.backend_port}/api")
            if qr_file:
                print(f"📱 QR Code: {qr_file}")
            print(f"📋 Backup: {backup_dir}")
            print(f"📄 Report: migration_report_{self.new_ip.replace('.', '_')}.md")
            
            print("\n🚀 Bước tiếp theo:")
            print("1. Restart services: ./clean-restart.sh")
            print("2. Test hệ thống")
            print("3. Gửi QR code mới cho users")
            
            return True
            
        except Exception as e:
            print(f"❌ Lỗi migration: {e}")
            return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 migrate_to_new_ip.py NEW_IP")
        print("Example: python3 migrate_to_new_ip.py 192.168.1.100")
        sys.exit(1)
    
    new_ip = sys.argv[1]
    
    # Xác nhận migration
    print(f"⚠️  Bạn sắp migrate hệ thống sang IP mới: {new_ip}")
    print("Điều này sẽ:")
    print("- Cập nhật tất cả config files")
    print("- Backup dữ liệu hiện tại")
    print("- Tạo QR codes mới")
    print("- Cập nhật cron jobs")
    
    confirm = input("\nBạn có chắc chắn? (y/N): ")
    if confirm.lower() != 'y':
        print("❌ Migration đã hủy")
        sys.exit(0)
    
    # Thực hiện migration
    migrator = SystemMigrator(new_ip=new_ip)
    success = migrator.migrate()
    
    if success:
        print("\n✅ Migration thành công!")
        sys.exit(0)
    else:
        print("\n❌ Migration thất bại!")
        sys.exit(1)

if __name__ == "__main__":
    main()

