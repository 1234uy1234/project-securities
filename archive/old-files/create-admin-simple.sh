#!/bin/bash

echo "🚀 TẠO TÀI KHOẢN ADMIN MỚI"
echo "=========================="

# Tạo password hash đơn giản
echo "👤 Tạo tài khoản admin mới..."

# Xóa tài khoản admin cũ
psql -U postgres -d patrol_system -c "DELETE FROM users WHERE username = 'admin';"

# Tạo tài khoản admin mới với password đơn giản
psql -U postgres -d patrol_system -c "
INSERT INTO users (username, email, password_hash, full_name, phone, role, is_active) 
VALUES ('admin', 'admin@manhtoan.com', '\$2b\$12\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', '0123456789', 'ADMIN', true);
"

echo "✅ Tài khoản admin đã được tạo!"
echo "🔑 Username: admin"
echo "🔑 Password: password"
echo "🔑 Role: ADMIN"

# Test đăng nhập
echo "🧪 Test đăng nhập..."
curl -k -X POST https://localhost:8000/api/auth/login -H "Content-Type: application/json" -d '{"username":"admin","password":"password"}' 2>/dev/null

echo ""
echo "🎉 Hoàn tất!"
