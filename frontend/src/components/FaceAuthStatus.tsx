import React, { useState, useEffect } from 'react';
import { User, Camera, CheckCircle, AlertCircle, Settings } from 'lucide-react';
import SimpleFaceAuthModal from './SimpleFaceAuthModal';
import { useAuthStore } from '../stores/authStore';

interface FaceAuthStatusProps {
  onFaceLogin?: (userData: any) => void;
}

const FaceAuthStatus: React.FC<FaceAuthStatusProps> = ({ onFaceLogin }) => {
  const { user } = useAuthStore(); // Lấy user từ auth store
  const [faceStatus, setFaceStatus] = useState<{
    has_face_data: boolean;
    registered_at?: string;
    image_path?: string;
  } | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [showRegisterModal, setShowRegisterModal] = useState(false);
  const [showVerifyModal, setShowVerifyModal] = useState(false);

  const fetchFaceStatus = async () => {
    try {
      // Sử dụng axios với authentication
      const { api } = await import('../utils/api');
      const response = await api.get('/face-auth/status');
      const data = response.data;
      
      console.log('📸 Face status for current user:', data);
      setFaceStatus(data);
    } catch (error) {
      console.error('Error fetching face status:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchFaceStatus();
  }, []);

  const handleRegisterSuccess = () => {
    fetchFaceStatus();
  };

  const handleFaceLoginSuccess = (userData: any) => {
    if (onFaceLogin) {
      onFaceLogin(userData);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center space-x-2 text-gray-500">
        <div className="w-4 h-4 border-2 border-gray-300 border-t-blue-600 rounded-full animate-spin"></div>
        <span className="text-sm">Đang kiểm tra...</span>
      </div>
    );
  }

  return (
    <>
      <div className="space-y-3">
        {/* Face Auth Status */}
        <div className="bg-white rounded-lg border p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-blue-100 rounded-lg">
                <User className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <h3 className="font-medium text-gray-900">Xác thực khuôn mặt</h3>
                <p className="text-sm text-gray-500">
                  {faceStatus?.has_face_data 
                    ? `Đã đăng ký lúc ${new Date(faceStatus.registered_at!).toLocaleString('vi-VN')}`
                    : 'Chưa đăng ký khuôn mặt'
                  }
                </p>
              </div>
            </div>
            
            <div className="flex items-center space-x-2">
              {faceStatus?.has_face_data ? (
                <div className="flex items-center space-x-2">
                  <CheckCircle className="w-5 h-5 text-green-500" />
                  <button
                    onClick={() => setShowVerifyModal(true)}
                    className="px-3 py-1 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700"
                  >
                    Đăng nhập
                  </button>
                </div>
              ) : (
                <div className="flex items-center space-x-2">
                  <AlertCircle className="w-5 h-5 text-orange-500" />
                  <button
                    onClick={() => setShowRegisterModal(true)}
                    className="px-3 py-1 bg-orange-600 text-white text-sm rounded-lg hover:bg-orange-700"
                  >
                    Đăng ký
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        {faceStatus?.has_face_data && (
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => setShowVerifyModal(true)}
              className="flex items-center justify-center space-x-2 p-3 bg-blue-50 text-blue-700 rounded-lg hover:bg-blue-100 transition-colors"
            >
              <Camera className="w-4 h-4" />
              <span className="text-sm font-medium">Đăng nhập nhanh</span>
            </button>
            
            <button
              onClick={() => setShowRegisterModal(true)}
              className="flex items-center justify-center space-x-2 p-3 bg-gray-50 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <Settings className="w-4 h-4" />
              <span className="text-sm font-medium">Cập nhật</span>
            </button>
          </div>
        )}
      </div>

      {/* Modals */}
      <SimpleFaceAuthModal
        isOpen={showRegisterModal}
        onClose={() => setShowRegisterModal(false)}
        onSuccess={handleFaceLoginSuccess}
        onRegisterSuccess={handleRegisterSuccess}
        mode="register"
        username={user?.username} // Truyền username từ auth store
      />

      <SimpleFaceAuthModal
        isOpen={showVerifyModal}
        onClose={() => setShowVerifyModal(false)}
        onSuccess={handleFaceLoginSuccess}
        mode="verify"
      />
    </>
  );
};

export default FaceAuthStatus;
