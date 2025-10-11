import React, { useState, useEffect } from 'react';
import { Download, Smartphone, X } from 'lucide-react';

interface BeforeInstallPromptEvent extends Event {
  readonly platforms: string[];
  readonly userChoice: Promise<{
    outcome: 'accepted' | 'dismissed';
    platform: string;
  }>;
  prompt(): Promise<void>;
}

const PWAInstallButton: React.FC = () => {
  const [deferredPrompt, setDeferredPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [showInstallButton, setShowInstallButton] = useState(false);
  const [isInstalled, setIsInstalled] = useState(false);

  useEffect(() => {
    // Kiểm tra xem app đã được cài đặt chưa
    const checkInstalled = () => {
      if (window.matchMedia('(display-mode: standalone)').matches) {
        setIsInstalled(true);
        return;
      }
      
      // Kiểm tra trên iOS
      if ((window.navigator as any).standalone === true) {
        setIsInstalled(true);
        return;
      }
    };

    checkInstalled();

    // Lắng nghe sự kiện beforeinstallprompt
    const handleBeforeInstallPrompt = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e as BeforeInstallPromptEvent);
      setShowInstallButton(true);
    };

    // Lắng nghe sự kiện appinstalled
    const handleAppInstalled = () => {
      setIsInstalled(true);
      setShowInstallButton(false);
      setDeferredPrompt(null);
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    window.addEventListener('appinstalled', handleAppInstalled);

    return () => {
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
      window.removeEventListener('appinstalled', handleAppInstalled);
    };
  }, []);

  const handleInstallClick = async () => {
    if (!deferredPrompt) return;

    try {
      await deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      
      if (outcome === 'accepted') {
        console.log('PWA: User accepted the install prompt');
      } else {
        console.log('PWA: User dismissed the install prompt');
      }
      
      setDeferredPrompt(null);
      setShowInstallButton(false);
    } catch (error) {
      console.error('PWA: Error during install:', error);
    }
  };

  const handleDismiss = () => {
    setShowInstallButton(false);
    // Lưu vào localStorage để không hiển thị lại trong 24h
    localStorage.setItem('pwa-install-dismissed', Date.now().toString());
  };

  // Không hiển thị nếu đã cài đặt hoặc đã dismiss trong 24h
  if (isInstalled || !showInstallButton) {
    return null;
  }

  const dismissedTime = localStorage.getItem('pwa-install-dismissed');
  if (dismissedTime) {
    const timeDiff = Date.now() - parseInt(dismissedTime);
    if (timeDiff < 24 * 60 * 60 * 1000) { // 24 hours
      return null;
    }
  }

  return (
    <div className="fixed bottom-4 right-4 z-50 animate-bounce">
      <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-4 max-w-sm">
        <div className="flex items-start justify-between mb-3">
          <div className="flex items-center space-x-2">
            <Smartphone className="w-5 h-5 text-blue-600" />
            <h3 className="font-semibold text-gray-900 text-sm">
              Cài đặt App
            </h3>
          </div>
          <button
            onClick={handleDismiss}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
        
        <p className="text-gray-600 text-xs mb-3">
          Cài đặt ManhToan Patrol để truy cập nhanh hơn và sử dụng offline!
        </p>
        
        <div className="flex space-x-2">
          <button
            onClick={handleInstallClick}
            className="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-xs font-medium py-2 px-3 rounded-md transition-colors flex items-center justify-center space-x-1"
          >
            <Download className="w-3 h-3" />
            <span>Cài đặt</span>
          </button>
          <button
            onClick={handleDismiss}
            className="px-3 py-2 text-gray-500 hover:text-gray-700 text-xs transition-colors"
          >
            Bỏ qua
          </button>
        </div>
      </div>
    </div>
  );
};

export default PWAInstallButton;
