-- Dữ liệu mẫu cho hệ thống tuần tra

-- Admin user (password: admin123)
INSERT INTO users (username, email, password_hash, role, full_name, phone) VALUES
('admin', 'admin@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'admin', 'Administrator', '0123456789');

-- Manager user (password: manager123)
INSERT INTO users (username, email, password_hash, role, full_name, phone) VALUES
('manager', 'manager@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'manager', 'Nguyễn Văn Quản Lý', '0987654321');

-- Employee users (password: employee123)
INSERT INTO users (username, email, password_hash, role, full_name, phone) VALUES
('employee1', 'employee1@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'employee', 'Trần Văn Nhân Viên 1', '0123456780'),
('employee2', 'employee2@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'employee', 'Lê Văn Nhân Viên 2', '0123456781'),
('employee3', 'employee3@manhtoan.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5wJmC', 'employee', 'Phạm Văn Nhân Viên 3', '0123456782');

-- Sample locations
INSERT INTO locations (name, description, qr_code, address, gps_latitude, gps_longitude) VALUES
('Khu vực A - Cổng chính', 'Khu vực cổng chính nhà máy', 'location_1_cong_chinh', 'Cổng chính nhà máy MANHTOAN PLASTIC', 10.762622, 106.660172),
('Khu vực B - Nhà kho', 'Khu vực nhà kho nguyên liệu', 'location_2_nha_kho', 'Nhà kho nguyên liệu', 10.762800, 106.660300),
('Khu vực C - Xưởng sản xuất', 'Khu vực xưởng sản xuất chính', 'location_3_xuong_sx', 'Xưởng sản xuất chính', 10.763000, 106.660500),
('Khu vực D - Bãi xe', 'Khu vực bãi xe nhân viên', 'location_4_bai_xe', 'Bãi xe nhân viên', 10.763200, 106.660700),
('Khu vực E - Văn phòng', 'Khu vực văn phòng hành chính', 'location_5_van_phong', 'Văn phòng hành chính', 10.763400, 106.660900);

-- Sample patrol tasks
INSERT INTO patrol_tasks (title, description, location_id, assigned_to, schedule_week, status, created_by) VALUES
('Tuần tra cổng chính', 'Kiểm tra an ninh cổng chính', 1, 3, '2024-W01', 'pending', 2),
('Tuần tra nhà kho', 'Kiểm tra an toàn nhà kho', 2, 4, '2024-W01', 'pending', 2),
('Tuần tra xưởng sản xuất', 'Kiểm tra an toàn lao động', 3, 5, '2024-W01', 'pending', 2),
('Tuần tra bãi xe', 'Kiểm tra trật tự bãi xe', 4, 3, '2024-W01', 'pending', 2),
('Tuần tra văn phòng', 'Kiểm tra an ninh văn phòng', 5, 4, '2024-W01', 'pending', 2);

-- Sample patrol records
INSERT INTO patrol_records (user_id, task_id, location_id, check_in_time, gps_latitude, gps_longitude, notes) VALUES
(3, 1, 1, CURRENT_TIMESTAMP - INTERVAL '2 hours', 10.762622, 106.660172, 'Tuần tra bình thường'),
(4, 2, 2, CURRENT_TIMESTAMP - INTERVAL '1 hour', 10.762800, 106.660300, 'Không có vấn đề gì'),
(5, 3, 3, CURRENT_TIMESTAMP - INTERVAL '30 minutes', 10.763000, 106.660500, 'Mọi thứ ổn định');
