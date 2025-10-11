#!/usr/bin/env python3
"""
Script backup và migrate dữ liệu sang IP mới
Bao gồm: database, ảnh, QR codes, config files
"""

import os
import sys
import json
import shutil
import sqlite3
import subprocess
from datetime import datetime
from pathlib import Path
import zipfile

class DataMigrator:
    def __init__(self, old_ip="localhost", new_ip=None):
        self.old_ip = old_ip
        self.new_ip = new_ip
        self.project_root = "/Users/maybe/Documents/shopee"
        self.backup_dir = None
        
    def create_backup(self):
        """Tạo backup toàn bộ dữ liệu"""
        print("🔄 Tạo backup dữ liệu...")
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.backup_dir = f"{self.project_root}/migration_backup_{timestamp}"
        os.makedirs(self.backup_dir, exist_ok=True)
        
        # Backup database files
        db_files = [
            "backend/app.db",
            "backend/patrol.db"
        ]
        
        for db_file in db_files:
            src_path = f"{self.project_root}/{db_file}"
            if os.path.exists(src_path):
                dst_path = f"{self.backup_dir}/{os.path.basename(db_file)}"
                shutil.copy2(src_path, dst_path)
                print(f"✅ Đã backup database: {os.path.basename(db_file)}")
        
        # Backup uploads directory
        uploads_src = f"{self.project_root}/backend/uploads"
        if os.path.exists(uploads_src):
            uploads_dst = f"{self.backup_dir}/uploads"
            shutil.copytree(uploads_src, uploads_dst)
            print(f"✅ Đã backup uploads directory")
        
        # Backup checkin photos
        checkin_src = f"{self.project_root}/checkin_photos"
        if os.path.exists(checkin_src):
            checkin_dst = f"{self.backup_dir}/checkin_photos"
            shutil.copytree(checkin_src, checkin_dst)
            print(f"✅ Đã backup checkin photos")
        
        # Backup QR codes
        qr_src = f"{self.project_root}/qr_backup"
        if os.path.exists(qr_src):
            qr_dst = f"{self.backup_dir}/qr_backup"
            shutil.copytree(qr_src, qr_dst)
            print(f"✅ Đã backup QR codes")
        
        # Backup SSL certificates
        ssl_src = f"{self.project_root}/ssl"
        if os.path.exists(ssl_src):
            ssl_dst = f"{self.backup_dir}/ssl"
            shutil.copytree(ssl_src, ssl_dst)
            print(f"✅ Đã backup SSL certificates")
        
        # Backup config files
        config_files = [
            "frontend/src/utils/api.ts",
            "frontend/.env.local",
            "backend/app/config.py",
            "nginx-https.conf"
        ]
        
        config_dir = f"{self.backup_dir}/configs"
        os.makedirs(config_dir, exist_ok=True)
        
        for config_file in config_files:
            src_path = f"{self.project_root}/{config_file}"
            if os.path.exists(src_path):
                dst_path = f"{config_dir}/{os.path.basename(config_file)}"
                shutil.copy2(src_path, dst_path)
                print(f"✅ Đã backup config: {os.path.basename(config_file)}")
        
        # Tạo backup info
        backup_info = {
            "timestamp": timestamp,
            "old_ip": self.old_ip,
            "new_ip": self.new_ip,
            "backup_dir": self.backup_dir,
            "files_backed_up": [
                "app.db",
                "patrol.db", 
                "uploads/",
                "checkin_photos/",
                "qr_backup/",
                "ssl/",
                "configs/"
            ]
        }
        
        with open(f"{self.backup_dir}/backup_info.json", 'w') as f:
            json.dump(backup_info, f, indent=2)
        
        print(f"✅ Backup hoàn tất tại: {self.backup_dir}")
        return self.backup_dir
    
    def migrate_database_urls(self):
        """Migrate URLs trong database"""
        print("🔄 Migrate URLs trong database...")
        
        db_files = [
            f"{self.project_root}/backend/app.db",
            f"{self.project_root}/backend/patrol.db"
        ]
        
        for db_file in db_files:
            if os.path.exists(db_file):
                try:
                    conn = sqlite3.connect(db_file)
                    cursor = conn.cursor()
                    
                    # Lấy danh sách tables
                    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
                    tables = cursor.fetchall()
                    
                    for table in tables:
                        table_name = table[0]
                        
                        # Lấy schema của table
                        cursor.execute(f"PRAGMA table_info({table_name})")
                        columns = cursor.fetchall()
                        
                        # Tìm columns có thể chứa URLs
                        url_columns = []
                        for col in columns:
                            col_name = col[1]
                            if any(keyword in col_name.lower() for keyword in ['url', 'image', 'photo', 'path', 'link']):
                                url_columns.append(col_name)
                        
                        # Update URLs trong các columns này
                        for col in url_columns:
                            try:
                                cursor.execute(f"""
                                    UPDATE {table_name} 
                                    SET {col} = REPLACE({col}, 'https://{self.old_ip}', 'https://{self.new_ip}')
                                    WHERE {col} LIKE '%{self.old_ip}%'
                                """)
                                
                                cursor.execute(f"""
                                    UPDATE {table_name} 
                                    SET {col} = REPLACE({col}, 'http://{self.old_ip}', 'https://{self.new_ip}')
                                    WHERE {col} LIKE '%{self.old_ip}%'
                                """)
                                
                                updated_rows = cursor.rowcount
                                if updated_rows > 0:
                                    print(f"✅ Updated {updated_rows} rows in {table_name}.{col}")
                                    
                            except Exception as e:
                                print(f"⚠️ Error updating {table_name}.{col}: {e}")
                    
                    conn.commit()
                    conn.close()
                    
                    print(f"✅ Đã migrate database: {os.path.basename(db_file)}")
                    
                except Exception as e:
                    print(f"❌ Lỗi migrate database {db_file}: {e}")
    
    def migrate_file_paths(self):
        """Migrate file paths trong hệ thống"""
        print("🔄 Migrate file paths...")
        
        # Cập nhật file paths trong các config files
        config_files = [
            f"{self.project_root}/frontend/src/utils/api.ts",
            f"{self.project_root}/backend/app/config.py"
        ]
        
        for config_file in config_files:
            if os.path.exists(config_file):
                with open(config_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Thay thế IP cũ bằng IP mới
                content = content.replace(f"https://{self.old_ip}", f"https://{self.new_ip}")
                content = content.replace(f"http://{self.old_ip}", f"https://{self.new_ip}")
                
                with open(config_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                print(f"✅ Đã migrate file paths trong: {os.path.basename(config_file)}")
    
    def create_migration_package(self):
        """Tạo package migration để deploy sang server mới"""
        print("🔄 Tạo migration package...")
        
        package_name = f"migration_package_{self.new_ip.replace('.', '_')}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip"
        package_path = f"{self.project_root}/{package_name}"
        
        with zipfile.ZipFile(package_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # Thêm database files
            db_files = ["backend/app.db", "backend/patrol.db"]
            for db_file in db_files:
                src_path = f"{self.project_root}/{db_file}"
                if os.path.exists(src_path):
                    zipf.write(src_path, os.path.basename(db_file))
            
            # Thêm uploads directory
            uploads_path = f"{self.project_root}/backend/uploads"
            if os.path.exists(uploads_path):
                for root, dirs, files in os.walk(uploads_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arc_path = os.path.relpath(file_path, self.project_root)
                        zipf.write(file_path, arc_path)
            
            # Thêm checkin photos
            checkin_path = f"{self.project_root}/checkin_photos"
            if os.path.exists(checkin_path):
                for root, dirs, files in os.walk(checkin_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arc_path = os.path.relpath(file_path, self.project_root)
                        zipf.write(file_path, arc_path)
            
            # Thêm QR codes
            qr_path = f"{self.project_root}/qr_backup"
            if os.path.exists(qr_path):
                for root, dirs, files in os.walk(qr_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arc_path = os.path.relpath(file_path, self.project_root)
                        zipf.write(file_path, arc_path)
            
            # Thêm SSL certificates
            ssl_path = f"{self.project_root}/ssl"
            if os.path.exists(ssl_path):
                for root, dirs, files in os.walk(ssl_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arc_path = os.path.relpath(file_path, self.project_root)
                        zipf.write(file_path, arc_path)
            
            # Thêm config files
            config_files = [
                "frontend/src/utils/api.ts",
                "frontend/.env.local",
                "backend/app/config.py",
                "nginx-https.conf"
            ]
            
            for config_file in config_files:
                src_path = f"{self.project_root}/{config_file}"
                if os.path.exists(src_path):
                    zipf.write(src_path, config_file)
            
            # Thêm migration scripts
            script_files = [
                "migrate_to_new_ip.py",
                "restart_after_migration.sh"
            ]
            
            for script_file in script_files:
                src_path = f"{self.project_root}/{script_file}"
                if os.path.exists(src_path):
                    zipf.write(src_path, script_file)
        
        print(f"✅ Đã tạo migration package: {package_name}")
        return package_path
    
    def create_deployment_guide(self):
        """Tạo hướng dẫn deployment"""
        guide = f"""
# 🚀 HƯỚNG DẪN DEPLOYMENT SANG IP MỚI

## 📋 Thông tin Migration
- **IP cũ**: {self.old_ip}
- **IP mới**: {self.new_ip}
- **Thời gian**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## 📦 Files đã chuẩn bị
- ✅ Migration package: migration_package_{self.new_ip.replace('.', '_')}_*.zip
- ✅ Backup data: {self.backup_dir}
- ✅ Migration scripts
- ✅ QR codes mới

## 🔧 Bước 1: Chuẩn bị server mới

### 1.1 Cài đặt dependencies
```bash
# Cài đặt Python dependencies
pip install -r backend/requirements.txt

# Cài đặt Node.js dependencies
cd frontend && npm install

# Cài đặt SSL tools
sudo apt-get install openssl nginx
```

### 1.2 Tạo thư mục project
```bash
mkdir -p /path/to/new/project
cd /path/to/new/project
```

## 📥 Bước 2: Deploy data

### 2.1 Giải nén migration package
```bash
unzip migration_package_{self.new_ip.replace('.', '_')}_*.zip
```

### 2.2 Restore database
```bash
# Copy database files
cp app.db backend/
cp patrol.db backend/
```

### 2.3 Restore uploads và photos
```bash
# Copy uploads
cp -r uploads backend/

# Copy checkin photos
cp -r checkin_photos ./

# Copy QR codes
cp -r qr_backup ./

# Copy SSL certificates
cp -r ssl ./
```

## ⚙️ Bước 3: Cấu hình hệ thống

### 3.1 Cập nhật config files
```bash
# Chạy migration script
python3 migrate_to_new_ip.py {self.new_ip}
```

### 3.2 Generate SSL certificates mới
```bash
cd backend
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out cert.csr -subj "/C=VN/ST=HCM/L=HCM/O=MANHTOAN/OU=IT/CN={self.new_ip}"
openssl x509 -req -days 365 -in cert.csr -signkey key.pem -out cert.pem
rm cert.csr
```

## 🚀 Bước 4: Start services

### 4.1 Start backend
```bash
cd backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --ssl-keyfile key.pem --ssl-certfile cert.pem
```

### 4.2 Start frontend
```bash
cd frontend
npm run dev -- --host 0.0.0.0 --port 3000
```

### 4.3 Start nginx
```bash
sudo nginx -c /path/to/project/nginx-https.conf
```

## 🧪 Bước 5: Test hệ thống

### 5.1 Test API
```bash
curl -k https://{self.new_ip}:8000/api/health
```

### 5.2 Test Frontend
```bash
curl -k https://{self.new_ip}:3000
```

### 5.3 Test PWA
- Truy cập: https://{self.new_ip}:3000
- Test cài đặt PWA
- Test các tính năng chính

## 📱 Bước 6: Cập nhật users

### 6.1 Gửi QR code mới
- File: pwa_install_qr_{self.new_ip.replace('.', '_')}.png
- URL: https://{self.new_ip}:3000

### 6.2 Hướng dẫn users
1. Xóa app cũ khỏi màn hình chính
2. Quét QR code mới
3. Cài đặt lại PWA
4. Test các tính năng

## 🔍 Bước 7: Monitoring

### 7.1 Check logs
```bash
tail -f backend.log
tail -f frontend.log
tail -f nginx_access.log
```

### 7.2 Monitor services
```bash
ps aux | grep uvicorn
ps aux | grep npm
ps aux | grep nginx
```

## 🆘 Troubleshooting

### Lỗi SSL Certificate
```bash
# Regenerate certificates
cd backend
rm key.pem cert.pem
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out cert.csr -subj "/C=VN/ST=HCM/L=HCM/O=MANHTOAN/OU=IT/CN={self.new_ip}"
openssl x509 -req -days 365 -in cert.csr -signkey key.pem -out cert.pem
```

### Lỗi Database
```bash
# Check database integrity
sqlite3 backend/app.db "PRAGMA integrity_check;"
sqlite3 backend/patrol.db "PRAGMA integrity_check;"
```

### Lỗi Frontend Build
```bash
cd frontend
rm -rf node_modules dist
npm install
npm run build
```

## 📞 Support
- Backup data: {self.backup_dir}
- Migration package: migration_package_{self.new_ip.replace('.', '_')}_*.zip
- Logs: backend.log, frontend.log

---
*Deployment guide completed! 🎉*
"""
        
        with open(f"DEPLOYMENT_GUIDE_{self.new_ip.replace('.', '_')}.md", 'w', encoding='utf-8') as f:
            f.write(guide)
        
        print(f"✅ Đã tạo deployment guide: DEPLOYMENT_GUIDE_{self.new_ip.replace('.', '_')}.md")
    
    def migrate(self):
        """Thực hiện migration dữ liệu"""
        if not self.new_ip:
            print("❌ Vui lòng cung cấp IP mới")
            return False
        
        print(f"🚀 Bắt đầu migration dữ liệu từ {self.old_ip} sang {self.new_ip}")
        print("=" * 60)
        
        try:
            # 1. Tạo backup
            self.create_backup()
            
            # 2. Migrate database URLs
            self.migrate_database_urls()
            
            # 3. Migrate file paths
            self.migrate_file_paths()
            
            # 4. Tạo migration package
            package_path = self.create_migration_package()
            
            # 5. Tạo deployment guide
            self.create_deployment_guide()
            
            print("\n🎉 DATA MIGRATION HOÀN TẤT!")
            print("=" * 60)
            print(f"📍 IP mới: {self.new_ip}")
            print(f"📦 Migration package: {os.path.basename(package_path)}")
            print(f"📋 Backup data: {self.backup_dir}")
            print(f"📄 Deployment guide: DEPLOYMENT_GUIDE_{self.new_ip.replace('.', '_')}.md")
            
            print("\n🚀 Bước tiếp theo:")
            print("1. Copy migration package sang server mới")
            print("2. Follow deployment guide")
            print("3. Test hệ thống")
            print("4. Update users")
            
            return True
            
        except Exception as e:
            print(f"❌ Lỗi migration: {e}")
            return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 backup_and_migrate_data.py NEW_IP")
        print("Example: python3 backup_and_migrate_data.py 192.168.1.100")
        sys.exit(1)
    
    new_ip = sys.argv[1]
    
    # Xác nhận migration
    print(f"⚠️  Bạn sắp migrate dữ liệu sang IP mới: {new_ip}")
    print("Điều này sẽ:")
    print("- Backup toàn bộ dữ liệu")
    print("- Migrate database URLs")
    print("- Tạo migration package")
    print("- Tạo deployment guide")
    
    confirm = input("\nBạn có chắc chắn? (y/N): ")
    if confirm.lower() != 'y':
        print("❌ Migration đã hủy")
        sys.exit(0)
    
    # Thực hiện migration
    migrator = DataMigrator(new_ip=new_ip)
    success = migrator.migrate()
    
    if success:
        print("\n✅ Data migration thành công!")
        sys.exit(0)
    else:
        print("\n❌ Data migration thất bại!")
        sys.exit(1)

if __name__ == "__main__":
    main()

