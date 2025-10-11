// Generate VAPID keys for push notifications
const webpush = require('web-push');

// Generate new VAPID keys
const vapidKeys = webpush.generateVAPIDKeys();

console.log('🔑 VAPID Keys Generated:');
console.log('========================');
console.log('Public Key:', vapidKeys.publicKey);
console.log('Private Key:', vapidKeys.privateKey);
console.log('');
console.log('📱 Copy these keys to:');
console.log('• Frontend: pushNotificationService.ts');
console.log('• Backend: push_notification.py');

