import React, { useState, useEffect } from 'react';
import { Bell, BellOff, CheckCircle, AlertCircle, TestTube, Settings } from 'lucide-react';
import { pushNotificationService } from '../services/pushNotificationService';

const PushNotificationsPage: React.FC = () => {
  const [isSupported, setIsSupported] = useState(false);
  const [isSubscribed, setIsSubscribed] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [permission, setPermission] = useState<NotificationPermission>('default');

  useEffect(() => {
    checkSupport();
    checkPermission();
    checkSubscription();
  }, []);

  const checkSupport = () => {
    const supported = 'serviceWorker' in navigator && 'PushManager' in window;
    setIsSupported(supported);
  };

  const checkPermission = () => {
    if ('Notification' in window) {
      setPermission(Notification.permission);
    }
  };

  const checkSubscription = async () => {
    try {
      const subscribed = await pushNotificationService.isSubscribed();
      setIsSubscribed(subscribed);
    } catch (error) {
      console.error('Error checking subscription:', error);
    }
  };

  const handleEnableNotifications = async () => {
    setIsLoading(true);
    try {
      const success = await pushNotificationService.initialize();
      if (success) {
        setIsSubscribed(true);
        pushNotificationService.showNotification(
          '🔔 Thông báo đã được bật!',
          {
            body: 'Bạn sẽ nhận được thông báo khi có nhiệm vụ mới.',
            tag: 'notification-enabled'
          }
        );
      }
    } catch (error) {
      console.error('Error enabling notifications:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDisableNotifications = async () => {
    setIsLoading(true);
    try {
      await pushNotificationService.unsubscribe();
      setIsSubscribed(false);
    } catch (error) {
      console.error('Error disabling notifications:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleTestNotification = async () => {
    try {
      setIsLoading(true);
      const success = await pushNotificationService.testNotification();
      if (success) {
        pushNotificationService.showNotification(
          '✅ Test thành công!',
          {
            body: 'Thông báo test đã được gửi từ server.',
            tag: 'test-success'
          }
        );
      } else {
        pushNotificationService.showNotification(
          '❌ Test thất bại',
          {
            body: 'Không thể gửi thông báo test từ server.',
            tag: 'test-failed'
          }
        );
      }
    } catch (error) {
      console.error('Error testing notification:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="bg-white rounded-lg shadow-lg p-6">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center">
            <Bell className="w-8 h-8 text-blue-600 mr-3" />
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Push Notifications</h1>
              <p className="text-gray-600">Quản lý thông báo đẩy cho ứng dụng</p>
            </div>
          </div>
          <div className="flex items-center">
            {isSubscribed ? (
              <CheckCircle className="w-6 h-6 text-green-500" />
            ) : (
              <BellOff className="w-6 h-6 text-gray-400" />
            )}
          </div>
        </div>

        {/* Support Status */}
        <div className="mb-6">
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="flex items-center">
              {isSupported ? (
                <CheckCircle className="w-5 h-5 text-green-500 mr-2" />
              ) : (
                <AlertCircle className="w-5 h-5 text-red-500 mr-2" />
              )}
              <span className="text-sm font-medium">
                {isSupported ? 'Trình duyệt hỗ trợ push notifications' : 'Trình duyệt không hỗ trợ push notifications'}
              </span>
            </div>
          </div>
        </div>

        {/* Permission Status */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Trạng thái quyền</h3>
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="flex items-center">
              {permission === 'granted' ? (
                <CheckCircle className="w-5 h-5 text-green-500 mr-2" />
              ) : permission === 'denied' ? (
                <AlertCircle className="w-5 h-5 text-red-500 mr-2" />
              ) : (
                <AlertCircle className="w-5 h-5 text-yellow-500 mr-2" />
              )}
              <span className="text-sm font-medium">
                Quyền thông báo: {
                  permission === 'granted' ? 'Đã cấp' :
                  permission === 'denied' ? 'Bị từ chối' : 'Chưa xác định'
                }
              </span>
            </div>
          </div>
        </div>

        {/* Subscription Status */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Trạng thái đăng ký</h3>
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="flex items-center">
              {isSubscribed ? (
                <CheckCircle className="w-5 h-5 text-green-500 mr-2" />
              ) : (
                <BellOff className="w-5 h-5 text-gray-400 mr-2" />
              )}
              <span className="text-sm font-medium">
                {isSubscribed ? 'Đã đăng ký push notifications' : 'Chưa đăng ký push notifications'}
              </span>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">Hành động</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {!isSubscribed ? (
              <button
                onClick={handleEnableNotifications}
                disabled={isLoading || permission === 'denied' || !isSupported}
                className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center"
              >
                {isLoading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Đang bật...
                  </>
                ) : (
                  <>
                    <Bell className="w-4 h-4 mr-2" />
                    Bật thông báo
                  </>
                )}
              </button>
            ) : (
              <>
                <button
                  onClick={handleTestNotification}
                  disabled={isLoading}
                  className="bg-gray-100 text-gray-700 px-6 py-3 rounded-lg hover:bg-gray-200 disabled:bg-gray-100 disabled:cursor-not-allowed flex items-center justify-center"
                >
                  <TestTube className="w-4 h-4 mr-2" />
                  Test thông báo
                </button>
                
                <button
                  onClick={handleDisableNotifications}
                  disabled={isLoading}
                  className="bg-red-100 text-red-700 px-6 py-3 rounded-lg hover:bg-red-200 disabled:bg-gray-100 disabled:cursor-not-allowed flex items-center justify-center"
                >
                  <BellOff className="w-4 h-4 mr-2" />
                  Tắt thông báo
                </button>
              </>
            )}
          </div>
        </div>

        {/* Information */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div className="flex items-start">
            <Settings className="w-5 h-5 text-blue-600 mr-2 mt-0.5" />
            <div>
              <h4 className="text-sm font-semibold text-blue-900 mb-1">Thông tin</h4>
              <p className="text-sm text-blue-800">
                Push notifications cho phép bạn nhận thông báo ngay cả khi không mở ứng dụng. 
                Thông báo sẽ được gửi khi có nhiệm vụ mới được giao cho bạn.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PushNotificationsPage;






