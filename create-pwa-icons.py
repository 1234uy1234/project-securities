#!/usr/bin/env python3
"""
Tạo icon cho PWA từ một icon gốc
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_pwa_icons():
    print("🎨 Tạo icon cho PWA...")
    
    # Tạo thư mục icons nếu chưa có
    icons_dir = "frontend/public"
    os.makedirs(icons_dir, exist_ok=True)
    
    # Kích thước icon cần tạo
    sizes = [96, 144, 192, 512]
    
    for size in sizes:
        # Tạo icon với nền xanh
        img = Image.new('RGB', (size, size), color='#1e40af')
        draw = ImageDraw.Draw(img)
        
        # Vẽ icon đơn giản (hình vuông với chữ M)
        margin = size // 8
        draw.rectangle([margin, margin, size-margin, size-margin], 
                      outline='white', width=max(2, size//64))
        
        # Vẽ chữ M ở giữa
        try:
            # Thử dùng font hệ thống
            font_size = size // 3
            font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
        except:
            # Fallback font
            font = ImageFont.load_default()
        
        # Tính toán vị trí chữ M
        text = "M"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (size - text_width) // 2
        y = (size - text_height) // 2
        
        draw.text((x, y), text, fill='white', font=font)
        
        # Lưu icon
        icon_path = f"{icons_dir}/icon-{size}x{size}.png"
        img.save(icon_path, 'PNG')
        print(f"   ✅ Tạo icon {size}x{size}: {icon_path}")
    
    # Tạo favicon
    favicon = Image.new('RGB', (32, 32), color='#1e40af')
    draw = ImageDraw.Draw(favicon)
    draw.rectangle([4, 4, 28, 28], outline='white', width=1)
    draw.text((12, 8), "M", fill='white')
    favicon.save(f"{icons_dir}/favicon.ico", 'ICO')
    print(f"   ✅ Tạo favicon: {icons_dir}/favicon.ico")
    
    print("🎉 Hoàn tất tạo icon PWA!")

if __name__ == "__main__":
    create_pwa_icons()
