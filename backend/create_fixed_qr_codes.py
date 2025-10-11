#!/usr/bin/env python3
"""
Script để tạo 8 QR codes cố định cho 8 vị trí trong nhà máy
"""

import qrcode
import os
from datetime import datetime

# 8 vị trí cố định trong nhà máy
FIXED_LOCATIONS = [
    {"id": 1, "name": "Cổng chính", "description": "Vị trí cổng chính vào nhà máy"},
    {"id": 2, "name": "Khu vực sản xuất A", "description": "Khu vực sản xuất chính"},
    {"id": 3, "name": "Khu vực sản xuất B", "description": "Khu vực sản xuất phụ"},
    {"id": 4, "name": "Kho nguyên liệu", "description": "Kho chứa nguyên liệu"},
    {"id": 5, "name": "Kho thành phẩm", "description": "Kho chứa sản phẩm hoàn thành"},
    {"id": 6, "name": "Phòng máy", "description": "Phòng điều khiển máy móc"},
    {"id": 7, "name": "Khu vực bảo trì", "description": "Khu vực bảo trì thiết bị"},
    {"id": 8, "name": "Khu vực văn phòng", "description": "Khu vực văn phòng làm việc"}
]

def create_qr_code(data: str, filename: str) -> str:
    """Tạo QR code và lưu file"""
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(data)
    qr.make(fit=True)
    
    # Tạo ảnh
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Lưu file
    file_path = f"uploads/qr_codes/{filename}"
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    img.save(file_path)
    
    return file_path

def main():
    print("🏭 Tạo 8 QR codes cố định cho nhà máy...")
    
    # Tạo thư mục nếu chưa có
    os.makedirs("uploads/qr_codes", exist_ok=True)
    
    for location in FIXED_LOCATIONS:
        # Tạo nội dung QR code
        qr_content = f"https://localhost:5173/checkin?location_id={location['id']}&name={location['name']}"
        
        # Tạo tên file
        filename = f"location_{location['id']:02d}_{location['name'].replace(' ', '_').lower()}.png"
        
        # Tạo QR code
        file_path = create_qr_code(qr_content, filename)
        
        print(f"✅ Tạo QR code cho {location['name']} (ID: {location['id']})")
        print(f"   📁 File: {file_path}")
        print(f"   🔗 URL: {qr_content}")
        print()
    
    print("🎉 Hoàn thành! Đã tạo 8 QR codes cố định.")
    print("📋 Danh sách QR codes:")
    for location in FIXED_LOCATIONS:
        print(f"   {location['id']}. {location['name']} - {location['description']}")

if __name__ == "__main__":
    main()
