# MANHTOAN PLASTIC - Progressive Web App (PWA)

## Tổng quan

Ứng dụng MANHTOAN PLASTIC đã được chuyển đổi thành Progressive Web App (PWA), cho phép người dùng cài đặt và sử dụng như một ứng dụng native trên thiết bị di động và máy tính.

## Tính năng PWA

### ✅ Đã triển khai
- **Cài đặt trên thiết bị**: Có thể cài đặt trực tiếp từ trình duyệt
- **Hoạt động offline**: Sử dụng service worker để cache dữ liệu
- **Giao diện responsive**: Tối ưu hóa cho mobile và desktop
- **Navigation mobile**: Menu hamburger và bottom navigation
- **Cập nhật tự động**: Thông báo khi có phiên bản mới
- **Trạng thái online/offline**: Hiển thị trạng thái kết nối
- **Install prompt**: Gợi ý cài đặt app

### 🚀 Lợi ích
- **Truy cập nhanh**: Từ màn hình chính thiết bị
- **Tiết kiệm dữ liệu**: Cache thông minh
- **Trải nghiệm native**: Giao diện như app thật
- **Không cần app store**: Cài đặt trực tiếp từ web

## Hướng dẫn cài đặt

### Trên Android
1. Mở Chrome hoặc Samsung Internet
2. Truy cập ứng dụng
3. Nhấn menu (3 chấm) → "Cài đặt ứng dụng"
4. Xác nhận cài đặt

### Trên iOS
1. Mở Safari
2. Truy cập ứng dụng
3. Nhấn biểu tượng chia sẻ
4. Chọn "Thêm vào màn hình chính"

### Trên Windows
1. Mở Edge hoặc Chrome
2. Truy cập ứng dụng
3. Nhấn biểu tượng cài đặt
4. Chọn "Cài đặt ứng dụng"

### Trên macOS
1. Mở Safari
2. Truy cập ứng dụng
3. Nhấn biểu tượng chia sẻ
4. Chọn "Thêm vào Dock"

## Cấu trúc PWA

### Components
- `PWAInstallPrompt`: Gợi ý cài đặt app
- `PWAInstallButton`: Nút cài đặt PWA
- `PWAStatus`: Hiển thị trạng thái PWA
- `PWAInfo`: Thông tin chi tiết PWA
- `PWAFeatures`: Giới thiệu tính năng
- `OfflineIndicator`: Thông báo offline
- `PWAUpdateNotification`: Thông báo cập nhật
- `MobileBottomNavigation`: Navigation dưới cùng mobile

### Pages
- `PWAInfoPage`: Trang thông tin PWA đầy đủ

### Configuration
- `vite.config.ts`: Cấu hình PWA plugin
- `manifest.json`: Manifest file cho PWA
- `index.html`: Meta tags PWA

## Công nghệ sử dụng

- **Vite PWA Plugin**: Tự động tạo service worker
- **Workbox**: Quản lý cache và offline
- **Tailwind CSS**: Responsive design
- **Lucide React**: Icons
- **TypeScript**: Type safety

## Service Worker

Service worker được tự động tạo bởi Vite PWA plugin với các tính năng:

- **Runtime caching**: Cache API calls
- **Font caching**: Cache Google Fonts
- **Asset caching**: Cache static files
- **Update handling**: Tự động cập nhật

## Manifest

File manifest.json chứa:
- Tên và mô tả app
- Icons cho các kích thước khác nhau
- Theme color và background color
- Display mode (standalone)
- Orientation (portrait-primary)

## Responsive Design

### Mobile (< 768px)
- Header với menu hamburger
- Bottom navigation
- Sidebar overlay
- Touch-friendly buttons

### Tablet (768px - 1024px)
- Responsive grid
- Adaptive spacing
- Touch-friendly interface

### Desktop (> 1024px)
- Sidebar cố định
- Full navigation menu
- Desktop-optimized layout

## Testing PWA

### Chrome DevTools
1. Mở DevTools → Application tab
2. Kiểm tra Manifest
3. Kiểm tra Service Workers
4. Test offline mode

### Lighthouse
1. Mở DevTools → Lighthouse
2. Chọn PWA category
3. Generate report
4. Kiểm tra score

### Mobile Testing
1. Sử dụng Chrome DevTools mobile emulation
2. Test trên thiết bị thật
3. Kiểm tra install prompt
4. Test offline functionality

## Troubleshooting

### PWA không cài đặt được
- Kiểm tra HTTPS
- Kiểm tra manifest.json
- Kiểm tra service worker
- Kiểm tra browser support

### Offline không hoạt động
- Kiểm tra service worker registration
- Kiểm tra cache strategy
- Kiểm tra network requests

### Update không hoạt động
- Kiểm tra service worker lifecycle
- Kiểm tra cache versioning
- Kiểm tra update flow

## Performance

### Caching Strategy
- **API calls**: Network first với fallback cache
- **Static assets**: Cache first
- **Fonts**: Cache first với long expiration

### Bundle Optimization
- Code splitting
- Tree shaking
- Lazy loading
- Compression

## Security

- HTTPS required
- Content Security Policy
- Service worker scope
- Secure headers

## Browser Support

- **Chrome**: Full support
- **Edge**: Full support
- **Firefox**: Full support
- **Safari**: Partial support (iOS 11.3+)
- **Samsung Internet**: Full support

## Deployment

### Build
```bash
npm run build
```

### Preview
```bash
npm run preview
```

### Production
- Deploy dist folder
- Ensure HTTPS
- Test PWA functionality
- Monitor performance

## Monitoring

### Metrics
- Install rate
- Offline usage
- Update success rate
- Performance scores

### Tools
- Google Analytics
- Lighthouse CI
- Web Vitals
- Service Worker logs

## Future Enhancements

- [ ] Background sync
- [ ] Push notifications
- [ ] Advanced caching strategies
- [ ] Performance monitoring
- [ ] A/B testing
- [ ] Analytics integration

## Support

Nếu gặp vấn đề với PWA, vui lòng:
1. Kiểm tra console logs
2. Kiểm tra service worker status
3. Test trên browser khác
4. Liên hệ team development

---

**Lưu ý**: PWA yêu cầu HTTPS để hoạt động đầy đủ. Trong môi trường development, localhost được coi là secure context.
