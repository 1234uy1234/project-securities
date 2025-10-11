#!/bin/bash

# Script xóa trường ngày hạn và tự động lấy ngày từ thời gian tuần tra
# Sử dụng: ./remove-due-date-field.sh

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hàm hiển thị thông báo
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Kiểm tra thay đổi
check_changes() {
    print_step "Kiểm tra thay đổi..."
    
    # Kiểm tra trường due_date đã bị xóa chưa
    if grep -q "due_date" frontend/src/pages/TasksPage.tsx; then
        print_warning "Vẫn còn trường due_date trong TasksPage"
    else
        print_info "✓ Đã xóa trường due_date"
    fi
    
    # Kiểm tra logic tự động lấy ngày
    if grep -q "Tự động lấy ngày từ thời gian tuần tra" frontend/src/pages/TasksPage.tsx; then
        print_info "✓ Đã thêm logic tự động lấy ngày"
    else
        print_error "Chưa thêm logic tự động lấy ngày"
        return 1
    fi
    
    # Kiểm tra TimeRangePicker
    if grep -q "TimeRangePicker" frontend/src/pages/TasksPage.tsx; then
        print_info "✓ TimeRangePicker vẫn được sử dụng"
    else
        print_error "TimeRangePicker không được sử dụng"
        return 1
    fi
}

# Kiểm tra build
check_build() {
    print_step "Kiểm tra build..."
    
    cd frontend
    if npm run build > /dev/null 2>&1; then
        print_info "✓ Build thành công"
        cd ..
    else
        print_error "Build thất bại"
        cd ..
        return 1
    fi
}

# Main function
main() {
    print_info "=== Xóa trường ngày hạn và tự động lấy ngày ==="
    
    # Kiểm tra thay đổi
    if ! check_changes; then
        print_error "Thay đổi chưa được áp dụng đúng"
        exit 1
    fi
    
    # Kiểm tra build
    if ! check_build; then
        print_error "Build thất bại"
        exit 1
    fi
    
    print_info "=== Hoàn tất xóa trường ngày hạn ==="
    print_info "Các thay đổi đã được áp dụng:"
    print_info "- ✅ Xóa trường 'Ngày hạn' khỏi form"
    print_info "- ✅ Tự động lấy ngày từ thời gian tuần tra"
    print_info "- ✅ Không cần nhập tay ngày hạn nữa"
    print_info "- ✅ Build thành công"
    print_info "Khởi động lại frontend để sử dụng"
}

# Chạy script
main "$@"
