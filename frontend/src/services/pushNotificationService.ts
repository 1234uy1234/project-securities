// Push Notification Service for PWA
export class PushNotificationService {
  private static instance: PushNotificationService;
  private registration: ServiceWorkerRegistration | null = null;
  private subscription: PushSubscription | null = null;

  private constructor() {}

  public static getInstance(): PushNotificationService {
    if (!PushNotificationService.instance) {
      PushNotificationService.instance = new PushNotificationService();
    }
    return PushNotificationService.instance;
  }

  // Khởi tạo push notifications
  public async initialize(): Promise<boolean> {
    console.log('📱 Initializing push notifications...');
    
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      console.log('❌ Push messaging is not supported');
      return false;
    }

    try {
      console.log('📱 Getting service worker registration...');
      
      // Kiểm tra xem service worker có sẵn không
      if (!navigator.serviceWorker.controller) {
        console.log('📱 No service worker controller, trying to register...');
        try {
          await navigator.serviceWorker.register('/sw.js');
          console.log('✅ Service worker registered');
        } catch (regError) {
          console.log('⚠️ Service worker registration failed, continuing without push...');
          // Fallback: chỉ bật local notifications
          return this.enableLocalNotifications();
        }
      }
      
      // Đăng ký service worker với timeout
      const registrationPromise = navigator.serviceWorker.ready;
      const timeoutPromise = new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Service worker timeout')), 5000)
      );
      
      this.registration = await Promise.race([registrationPromise, timeoutPromise]) as ServiceWorkerRegistration;
      console.log('✅ Service worker ready');
      
      console.log('📱 Requesting notification permission...');
      // Kiểm tra quyền notification
      const permission = await Notification.requestPermission();
      console.log('📱 Permission result:', permission);
      
      if (permission !== 'granted') {
        console.log('❌ Notification permission denied');
        return false;
      }
      console.log('✅ Notification permission granted');

      console.log('📱 Creating push subscription...');
      
      // Kiểm tra xem push manager có sẵn không
      if (!this.registration.pushManager) {
        console.log('⚠️ Push manager not available, using local notifications...');
        return this.enableLocalNotifications();
      }
      
      try {
        // Đăng ký push subscription với VAPID key hợp lệ
        this.subscription = await this.registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: this.urlBase64ToUint8Array(
            'BGSuFsu3HNKp0o88tO-gWVzv2WCtmndy4hnkua0hN8EJUmTwJnBos8XwikcVXCRegKdPDcGtIP2JKiHYjiGNHV4'
          )
        });
        console.log('✅ Push subscription created');
      } catch (pushError) {
        console.log('⚠️ Push subscription failed:', pushError);
        console.log('📱 Falling back to local notifications...');
        return this.enableLocalNotifications();
      }

      console.log('📱 Sending subscription to server...');
      // Gửi subscription lên server
      await this.sendSubscriptionToServer(this.subscription);
      
      console.log('✅ Push notifications initialized successfully');
      return true;
    } catch (error) {
      console.error('❌ Error initializing push notifications:', error);
      return false;
    }
  }

  // Gửi subscription lên server
  private async sendSubscriptionToServer(subscription: PushSubscription): Promise<void> {
    try {
      console.log('📱 Sending subscription to server...');
      
      const response = await fetch('/api/push/subscribe', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('access_token')}`
        },
        body: JSON.stringify({
          endpoint: subscription.endpoint,
          keys: {
            p256dh: subscription.getKey('p256dh') ? btoa(String.fromCharCode(...new Uint8Array(subscription.getKey('p256dh')!))) : '',
            auth: subscription.getKey('auth') ? btoa(String.fromCharCode(...new Uint8Array(subscription.getKey('auth')!))) : ''
          },
          user_agent: navigator.userAgent
        }),
        // Thêm timeout
        signal: AbortSignal.timeout(10000) // 10 giây timeout
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Server response error:', response.status, errorText);
        throw new Error(`Server error: ${response.status} - ${errorText}`);
      }

      const result = await response.json();
      console.log('✅ Subscription sent to server successfully:', result);
    } catch (error) {
      console.error('❌ Error sending subscription to server:', error);
      // Không throw error để không làm fail toàn bộ quá trình
    }
  }

  // Fallback: chỉ bật local notifications
  private async enableLocalNotifications(): Promise<boolean> {
    try {
      console.log('📱 Enabling local notifications only...');
      
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        console.log('❌ Notification permission denied');
        return false;
      }
      
      console.log('✅ Local notifications enabled');
      
      // Hiển thị thông báo test
      this.showNotification(
        '🔔 Thông báo đã được bật!',
        {
          body: 'Bạn sẽ nhận được thông báo local khi có nhiệm vụ mới.',
          tag: 'notification-enabled'
        }
      );
      
      return true;
    } catch (error) {
      console.error('❌ Error enabling local notifications:', error);
      return false;
    }
  }

  // Chuyển đổi VAPID key
  private urlBase64ToUint8Array(base64String: string): Uint8Array {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding)
      .replace(/-/g, '+')
      .replace(/_/g, '/');

    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  }

  // Kiểm tra xem đã đăng ký push chưa
  public async isSubscribed(): Promise<boolean> {
    if (!this.registration) {
      this.registration = await navigator.serviceWorker.ready;
    }
    
    const subscription = await this.registration.pushManager.getSubscription();
    return subscription !== null;
  }

  // Hủy đăng ký push notifications
  public async unsubscribe(): Promise<boolean> {
    try {
      if (this.subscription) {
        await this.subscription.unsubscribe();
        this.subscription = null;
        console.log('Unsubscribed from push notifications');
        return true;
      }
      return false;
    } catch (error) {
      console.error('Error unsubscribing from push notifications:', error);
      return false;
    }
  }

  // Hiển thị notification thủ công (cho testing)
  public showNotification(title: string, options?: NotificationOptions): void {
    if (this.registration) {
      this.registration.showNotification(title, {
        icon: '/icon-192x192.png',
        badge: '/icon-96x96.png',
        vibrate: [100, 50, 100],
        ...options
      });
    }
  }

  // Test gửi thông báo từ server
  public async testNotification(): Promise<boolean> {
    try {
      console.log('📱 Testing notification...');
      
      const token = localStorage.getItem('access_token');
      if (!token) {
        console.log('❌ No authentication token found');
        throw new Error('No authentication token');
      }
      
      const response = await fetch('/api/push/test', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      console.log('📱 Test response status:', response.status);

      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Test failed:', response.status, errorText);
        throw new Error(`Test failed: ${response.status} - ${errorText}`);
      }

      const result = await response.json();
      console.log('✅ Test notification result:', result);
      return result.success;
    } catch (error) {
      console.error('❌ Error testing notification:', error);
      return false;
    }
  }
}

// Export singleton instance
export const pushNotificationService = PushNotificationService.getInstance();
