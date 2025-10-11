#!/bin/bash

echo "🧹 Dọn dẹp các file cũ không cần thiết..."

# Tạo thư mục archive
mkdir -p archive/old-files

# Di chuyển các file markdown cũ vào archive
find . -name "*.md" -not -name "PROJECT-STATUS-REPORT.md" -not -name "ALL-SCRIPTS-SUMMARY.md" -not -name "ALL-FIXES-SUMMARY.md" -not -name "README.md" | while read file; do
    echo "📁 Moving: $file"
    mv "$file" archive/old-files/
done

# Di chuyển các script cũ vào archive
find . -name "*.sh" -not -name "start-ngrok-system.sh" -not -name "quick-start.sh" -not -name "fix-ultimate.sh" -not -name "CLEANUP-OLD-FILES.sh" | while read file; do
    echo "📁 Moving: $file"
    mv "$file" archive/old-files/
done

echo "✅ Hoàn thành dọn dẹp!"
echo "📁 Các file quan trọng được giữ lại:"
echo "   - PROJECT-STATUS-REPORT.md"
echo "   - ALL-SCRIPTS-SUMMARY.md" 
echo "   - ALL-FIXES-SUMMARY.md"
echo "   - start-ngrok-system.sh"
echo "   - quick-start.sh"
echo "   - fix-ultimate.sh"
echo ""
echo "📦 Các file cũ đã được chuyển vào: archive/old-files/"
