// PWA Auto Update Utility
export class PWAUpdateManager {
  private static instance: PWAUpdateManager;
  private registration: ServiceWorkerRegistration | null = null;

  static getInstance(): PWAUpdateManager {
    if (!PWAUpdateManager.instance) {
      PWAUpdateManager.instance = new PWAUpdateManager();
    }
    return PWAUpdateManager.instance;
  }

  async initialize() {
    if ('serviceWorker' in navigator) {
      try {
        this.registration = await navigator.serviceWorker.register('/sw.js');
        console.log('✅ PWA Service Worker registered');

        // Listen for updates
        this.registration.addEventListener('updatefound', () => {
          console.log('🔄 PWA update found');
          this.handleUpdate();
        });

        // Check for updates every 5 minutes
        setInterval(() => {
          this.checkForUpdates();
        }, 5 * 60 * 1000);

      } catch (error) {
        console.error('❌ PWA Service Worker registration failed:', error);
      }
    }
  }

  private async checkForUpdates() {
    if (this.registration) {
      try {
        await this.registration.update();
        console.log('🔄 PWA update check completed');
      } catch (error) {
        console.error('❌ PWA update check failed:', error);
      }
    }
  }

  private handleUpdate() {
    if (this.registration?.waiting) {
      console.log('🔄 PWA update available, activating...');
      
      // Send message to waiting service worker
      this.registration.waiting.postMessage({ type: 'SKIP_WAITING' });
      
      // Reload page when new service worker takes control
      this.registration.waiting.addEventListener('statechange', (e) => {
        const target = e.target as ServiceWorker;
        if (target.state === 'activated') {
          console.log('✅ PWA updated, reloading page...');
          window.location.reload();
        }
      });
    }
  }

  async forceUpdate() {
    if ('serviceWorker' in navigator) {
      try {
        // Unregister all service workers
        const registrations = await navigator.serviceWorker.getRegistrations();
        for (let registration of registrations) {
          await registration.unregister();
        }

        // Clear all caches
        if ('caches' in window) {
          const cacheNames = await caches.keys();
          for (let cacheName of cacheNames) {
            await caches.delete(cacheName);
          }
        }

        // Clear storage
        localStorage.clear();
        sessionStorage.clear();

        // Register new service worker
        this.registration = await navigator.serviceWorker.register('/sw.js');
        console.log('✅ PWA force updated');

        // Reload page
        window.location.reload();

      } catch (error) {
        console.error('❌ PWA force update failed:', error);
      }
    }
  }

  async clearCache() {
    if ('caches' in window) {
      try {
        const cacheNames = await caches.keys();
        for (let cacheName of cacheNames) {
          await caches.delete(cacheName);
        }
        console.log('✅ PWA cache cleared');
      } catch (error) {
        console.error('❌ PWA cache clear failed:', error);
      }
    }
  }
}

// Export singleton instance
export const pwaUpdateManager = PWAUpdateManager.getInstance();
