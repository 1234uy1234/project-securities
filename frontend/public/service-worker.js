// Service Worker for MANHTOAN PLASTIC PWA - Optimized for Offline
const CACHE_NAME = 'manhtoan-patrol-v5';
const STATIC_CACHE = 'manhtoan-static-v5';
const DYNAMIC_CACHE = 'manhtoan-dynamic-v5';

// Static assets to cache immediately
const STATIC_URLS = [
  '/',
  '/manifest.json',
  '/logo.svg',
  '/static/js/bundle.js',
  '/static/css/main.css',
  '/static/media/',
  // Add more static assets as needed
];

// API endpoints that should be cached
const API_CACHE_PATTERNS = [
  '/api/qr-codes/',
  '/api/locations/',
  '/api/patrol-tasks/',
  '/api/patrol-records/',
  '/api/users/',
];

// Install event - Cache static assets
self.addEventListener('install', (event) => {
  console.log('🔧 Service Worker installing...');
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then((cache) => {
        console.log('📦 Caching static assets...');
        return cache.addAll(STATIC_URLS);
      })
      .then(() => {
        console.log('✅ Service Worker installed');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('❌ Service Worker install failed:', error);
      })
  );
});

// Activate event - Clean up old caches
self.addEventListener('activate', (event) => {
  console.log('🚀 Service Worker activating...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE) {
            console.log('🗑️ Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('✅ Service Worker activated');
      return self.clients.claim();
    })
  );
});

// Fetch event - Smart caching strategy
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }

  // Handle different types of requests
  if (isStaticAsset(request)) {
    // Static assets: Cache first, then network
    event.respondWith(cacheFirst(request));
  } else if (isAPIRequest(request)) {
    // API requests: Network first, then cache
    event.respondWith(networkFirst(request));
  } else if (isHTMLRequest(request)) {
    // HTML requests: Network first, then cache
    event.respondWith(networkFirst(request));
  } else {
    // Other requests: Network only
    event.respondWith(fetch(request));
  }
});

// Cache first strategy (for static assets)
async function cacheFirst(request) {
  try {
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
      console.log('📦 Serving from cache:', request.url);
      return cachedResponse;
    }

    console.log('🌐 Fetching from network:', request.url);
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      const cache = await caches.open(STATIC_CACHE);
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    console.error('❌ Cache first failed:', error);
    return new Response('Offline - Resource not available', { status: 503 });
  }
}

// Network first strategy (for API and HTML)
async function networkFirst(request) {
  try {
    console.log('🌐 Fetching from network:', request.url);
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      const cache = await caches.open(DYNAMIC_CACHE);
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    console.log('📦 Network failed, trying cache:', request.url);
    const cachedResponse = await caches.match(request);
    
    if (cachedResponse) {
      console.log('✅ Serving from cache:', request.url);
      return cachedResponse;
    }
    
    // Return offline page for HTML requests
    if (isHTMLRequest(request)) {
      return caches.match('/') || new Response('Offline - App not available', { status: 503 });
    }
    
    return new Response('Offline - Resource not available', { status: 503 });
  }
}

// Helper functions
function isStaticAsset(request) {
  const url = new URL(request.url);
  return url.pathname.startsWith('/static/') ||
         url.pathname.endsWith('.js') ||
         url.pathname.endsWith('.css') ||
         url.pathname.endsWith('.png') ||
         url.pathname.endsWith('.jpg') ||
         url.pathname.endsWith('.jpeg') ||
         url.pathname.endsWith('.gif') ||
         url.pathname.endsWith('.svg') ||
         url.pathname.endsWith('.ico');
}

function isAPIRequest(request) {
  const url = new URL(request.url);
  return url.pathname.startsWith('/api/');
}

function isHTMLRequest(request) {
  return request.headers.get('accept')?.includes('text/html');
}

// Background sync for offline check-ins
self.addEventListener('sync', (event) => {
  console.log('🔄 Background sync triggered:', event.tag);
  
  if (event.tag === 'checkin-sync') {
    event.waitUntil(syncOfflineCheckins());
  }
});

// Sync offline check-ins when back online
async function syncOfflineCheckins() {
  try {
    console.log('🔄 Syncing offline check-ins...');
    
    // Get offline queue from IndexedDB
    const db = await openDB();
    const transaction = db.transaction(['offlineQueue'], 'readonly');
    const store = transaction.objectStore('offlineQueue');
    const all = await store.getAll();
    
    if (all.length === 0) {
      console.log('📱 No offline check-ins to sync');
      return;
    }
    
    console.log(`📱 Found ${all.length} offline check-ins to sync`);
    
    // Sync each check-in
    for (const item of all) {
      try {
        const form = new FormData();
        form.append('qr_data', item.notes || '');
        
        if (item.photoDataUrl) {
          const blob = await (await fetch(item.photoDataUrl)).blob();
          form.append('photo', blob, `offline-scan-${item.createdAt}.jpg`);
        }

        const response = await fetch('/api/simple', {
          method: 'POST',
          body: form,
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });

        if (response.ok) {
          console.log('✅ Synced offline check-in:', item.createdAt);
          await store.delete(item.createdAt);
        } else {
          console.error('❌ Failed to sync check-in:', response.status);
          break; // Stop syncing if one fails
        }
      } catch (error) {
        console.error('❌ Error syncing check-in:', error);
        break;
      }
    }
    
    console.log('✅ Offline sync completed');
  } catch (error) {
    console.error('❌ Background sync failed:', error);
  }
}

// Helper function to open IndexedDB
function openDB() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open('OfflineQueueDB', 1);
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    
    request.onupgradeneeded = (event) => {
      const db = event.target.result;
      if (!db.objectStoreNames.contains('offlineQueue')) {
        db.createObjectStore('offlineQueue', { keyPath: 'createdAt' });
      }
    };
  });
}

// Handle app install prompt
self.addEventListener('beforeinstallprompt', (event) => {
  console.log('📱 PWA install prompt available');
  event.preventDefault();
  self.deferredPrompt = event;
});

// Handle app installed
self.addEventListener('appinstalled', (event) => {
  console.log('🎉 PWA app installed successfully');
  self.deferredPrompt = null;
});

// Handle push notifications (if needed in future)
self.addEventListener('push', (event) => {
  console.log('📱 Push notification received');
  
  const options = {
    body: event.data ? event.data.text() : 'New notification',
    icon: '/logo.svg',
    badge: '/logo.svg',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    }
  };
  
  event.waitUntil(
    self.registration.showNotification('MANHTOAN PLASTIC', options)
  );
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('📱 Notification clicked');
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow('/')
  );
});

console.log('🔧 Service Worker loaded successfully');