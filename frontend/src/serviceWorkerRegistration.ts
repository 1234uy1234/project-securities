// Service Worker Registration cho PWA
const isLocalhost = Boolean(
  window.location.hostname === 'localhost' ||
  window.location.hostname === '[::1]' ||
  window.location.hostname.match(
    /^127(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/
  )
);

type Config = {
  onSuccess?: (registration: ServiceWorkerRegistration) => void;
  onUpdate?: (registration: ServiceWorkerRegistration) => void;
};

export function register(config?: Config) {
  if ('serviceWorker' in navigator) {
    const publicUrl = new URL(process.env.PUBLIC_URL || '', window.location.href);
    if (publicUrl.origin !== window.location.origin) {
      return;
    }

    window.addEventListener('load', () => {
      const swUrl = `${process.env.PUBLIC_URL || ''}/sw.js`;

      if (isLocalhost) {
        checkValidServiceWorker(swUrl, config);
        navigator.serviceWorker.ready.then(() => {
          console.log(
            'PWA: Service worker đã sẵn sàng. ' +
            'Ứng dụng có thể hoạt động offline.'
          );
        });
      } else {
        registerValidSW(swUrl, config);
      }
    });
  }
}

function registerValidSW(swUrl: string, config?: Config) {
  navigator.serviceWorker
    .register(swUrl)
    .then((registration) => {
      console.log('PWA: Service Worker đã đăng ký thành công');
      
      registration.onupdatefound = () => {
        const installingWorker = registration.installing;
        if (installingWorker == null) {
          return;
        }
        installingWorker.onstatechange = () => {
          if (installingWorker.state === 'installed') {
            if (navigator.serviceWorker.controller) {
              console.log(
                'PWA: Nội dung mới đã có sẵn và sẽ được tải khi ' +
                'tất cả các tab đang mở được đóng.'
              );
              if (config && config.onUpdate) {
                config.onUpdate(registration);
              }
            } else {
              console.log('PWA: Nội dung đã được cache để sử dụng offline.');
              if (config && config.onSuccess) {
                config.onSuccess(registration);
              }
            }
          }
        };
      };
    })
    .catch((error) => {
      console.error('PWA: Lỗi đăng ký Service Worker:', error);
    });
}

function checkValidServiceWorker(swUrl: string, config?: Config) {
  fetch(swUrl, {
    headers: { 'Service-Worker': 'script' },
  })
    .then((response) => {
      const contentType = response.headers.get('content-type');
      if (
        response.status === 404 ||
        (contentType != null && contentType.indexOf('javascript') === -1)
      ) {
        navigator.serviceWorker.ready.then((registration) => {
          registration.unregister().then(() => {
            window.location.reload();
          });
        });
      } else {
        registerValidSW(swUrl, config);
      }
    })
    .catch(() => {
      console.log(
        'PWA: Không có kết nối internet. Ứng dụng đang chạy ở chế độ offline.'
      );
    });
}

export function unregister() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.ready
      .then((registration) => {
        registration.unregister();
      })
      .catch((error) => {
        console.error(error.message);
      });
  }
}

// PWA Install Prompt
let deferredPrompt: any;

window.addEventListener('beforeinstallprompt', (e) => {
  console.log('PWA: Install prompt triggered');
  e.preventDefault();
  deferredPrompt = e;
  
  // Hiển thị nút cài đặt
  showInstallButton();
});

function showInstallButton() {
  // Tạo nút cài đặt PWA
  const installButton = document.createElement('button');
  installButton.textContent = '📱 Cài đặt App';
  installButton.style.cssText = `
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: #1e40af;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 25px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(30, 64, 175, 0.3);
    z-index: 1000;
    transition: all 0.3s ease;
  `;
  
  installButton.addEventListener('click', async () => {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      console.log(`PWA: User choice: ${outcome}`);
      deferredPrompt = null;
      installButton.remove();
    }
  });
  
  installButton.addEventListener('mouseenter', () => {
    installButton.style.transform = 'translateY(-2px)';
    installButton.style.boxShadow = '0 6px 16px rgba(30, 64, 175, 0.4)';
  });
  
  installButton.addEventListener('mouseleave', () => {
    installButton.style.transform = 'translateY(0)';
    installButton.style.boxShadow = '0 4px 12px rgba(30, 64, 175, 0.3)';
  });
  
  document.body.appendChild(installButton);
  
  // Tự động ẩn sau 10 giây
  setTimeout(() => {
    if (installButton.parentNode) {
      installButton.remove();
    }
  }, 10000);
}

// PWA Install Success
window.addEventListener('appinstalled', () => {
  console.log('PWA: App đã được cài đặt thành công!');
  deferredPrompt = null;
  
  // Hiển thị thông báo thành công
  const successMessage = document.createElement('div');
  successMessage.textContent = '🎉 App đã được cài đặt thành công!';
  successMessage.style.cssText = `
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    background: #10b981;
    color: white;
    padding: 12px 24px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    z-index: 1000;
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
  `;
  
  document.body.appendChild(successMessage);
  
  setTimeout(() => {
    successMessage.remove();
  }, 3000);
});