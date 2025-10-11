#!/bin/bash

echo "🔄 KHÔI PHỤC DATABASE HOÀN TOÀN"
echo "================================"
echo ""

# Dừng tất cả process
echo "🛑 Dừng tất cả process..."
pkill -f "python app.py" 2>/dev/null
pkill -f "npm run dev" 2>/dev/null
sleep 3

# Xóa cache Python
echo "🧹 Xóa cache Python..."
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Xóa database cũ
echo "🗑️ Xóa database cũ..."
psql -U postgres -c "DROP DATABASE IF EXISTS patrol_system;" 2>/dev/null || true

# Tạo database mới
echo "🆕 Tạo database mới..."
psql -U postgres -c "CREATE DATABASE patrol_system;"

# Tạo schema
echo "🏗️ Tạo schema..."
cd backend
python create_db.py

# Thêm dữ liệu mẫu
echo "📝 Thêm dữ liệu mẫu..."
psql -U postgres -d patrol_system -c "
-- Thêm users
INSERT INTO users (username, email, password_hash, role, full_name, phone) VALUES
('admin', 'admin@manhtoan.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'ADMIN', 'Administrator', '0123456789'),
('manager', 'manager@manhtoan.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'MANAGER', 'Nguyễn Văn Quản Lý', '0987654321'),
('employee1', 'employee1@manhtoan.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'EMPLOYEE', 'Trần Văn Nhân Viên 1', '0123456780'),
('employee2', 'employee2@manhtoan.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'EMPLOYEE', 'Lê Văn Nhân Viên 2', '0123456781'),
('employee3', 'employee3@manhtoan.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'EMPLOYEE', 'Phạm Văn Nhân Viên 3', '0123456782');

-- Thêm locations
INSERT INTO locations (name, description, qr_code, address, gps_latitude, gps_longitude) VALUES
('Khu vực A - Cổng chính', 'Khu vực cổng chính nhà máy', 'location_1_cong_chinh', 'Cổng chính nhà máy MANHTOAN PLASTIC', 10.762622, 106.660172),
('Khu vực B - Nhà kho', 'Khu vực nhà kho nguyên liệu', 'location_2_nha_kho', 'Nhà kho nguyên liệu', 10.762800, 106.660300),
('Khu vực C - Xưởng sản xuất', 'Khu vực xưởng sản xuất chính', 'location_3_xuong_sx', 'Xưởng sản xuất chính', 10.763000, 106.660500),
('Khu vực D - Bãi xe', 'Khu vực bãi xe nhân viên', 'location_4_bai_xe', 'Bãi xe nhân viên', 10.763200, 106.660700),
('Khu vực E - Văn phòng', 'Khu vực văn phòng hành chính', 'location_5_van_phong', 'Văn phòng hành chính', 10.763400, 106.660900);
"

# Kiểm tra dữ liệu
echo "🔍 Kiểm tra dữ liệu..."
psql -U postgres -d patrol_system -c "
SELECT 'Users:' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Locations:', COUNT(*) FROM locations;
"

echo ""
echo "✅ Database đã được khôi phục thành công!"
echo ""
echo "🚀 Khởi động ứng dụng..."
echo ""

# Khởi động backend
echo "🔧 Khởi động Backend..."
python app.py &
BACKEND_PID=$!

# Đợi backend khởi động
echo "⏳ Đợi backend khởi động..."
sleep 5

# Khởi động frontend
echo "🔧 Khởi động Frontend..."
cd ../frontend
VITE_API_BASE_URL=https://localhost:8000 npm run dev -- --host 0.0.0.0 --port 5173 --https &
FRONTEND_PID=$!

# Đợi frontend khởi động
sleep 3

echo ""
echo "✅ Ứng dụng đã khởi động thành công!"
echo ""
echo "🌐 Truy cập ứng dụng:"
echo "   https://localhost:5173"
echo ""
echo "🔑 Thông tin đăng nhập:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "👥 Danh sách users:"
echo "   - admin (Administrator) - ADMIN"
echo "   - manager (Nguyễn Văn Quản Lý) - MANAGER"
echo "   - employee1 (Trần Văn Nhân Viên 1) - EMPLOYEE"
echo "   - employee2 (Lê Văn Nhân Viên 2) - EMPLOYEE"
echo "   - employee3 (Phạm Văn Nhân Viên 3) - EMPLOYEE"
echo ""
echo "🎉 Database đã được khôi phục hoàn toàn!"
echo "🛑 Để dừng ứng dụng: Ctrl+C"

wait
