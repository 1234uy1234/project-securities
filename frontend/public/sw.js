// Service Worker TEMPORARILY DISABLED for Camera Testing
console.log('Service Worker: TEMPORARILY DISABLED for Camera Testing');

const CACHE_NAME = 'patrol-app-v6.0.0';

// Install event - do nothing
self.addEventListener('install', (event) => {
  console.log('Service Worker: Install - DISABLED');
  event.waitUntil(self.skipWaiting());
});

// Activate event - do nothing
self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activate - DISABLED');
  event.waitUntil(self.clients.claim());
});

// Push event - do nothing
self.addEventListener('push', (event) => {
  console.log('Service Worker: Push - DISABLED');
  // Do nothing
});

// Notification click event - do nothing
self.addEventListener('notificationclick', (event) => {
  console.log('Service Worker: Notification click - DISABLED');
  // Do nothing
});

// Fetch event - do nothing (let browser handle all requests)
self.addEventListener('fetch', (event) => {
  console.log('Service Worker: Fetch - DISABLED');
  // Do nothing - let browser handle all requests normally
  return;
});