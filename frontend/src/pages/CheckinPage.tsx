import React, { useState, useEffect, useRef } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { api } from '../utils/api';
import { useAuthStore } from '../stores/authStore';
import toast from 'react-hot-toast';
import SimpleCamera from '../components/SimpleCamera';

const CheckinPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const [taskId, setTaskId] = useState<string | null>(null);
  const [taskInfo, setTaskInfo] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [photo, setPhoto] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [showCamera, setShowCamera] = useState(false);
  const [checkinSuccess, setCheckinSuccess] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [facingMode, setFacingMode] = useState<'user' | 'environment'>('user'); // Default to selfie camera
  const videoRef = useRef<HTMLVideoElement>(null); // Ref for video element

  useEffect(() => {
    const taskIdParam = searchParams.get('task_id');
    if (taskIdParam) {
      setTaskId(taskIdParam);
      fetchTaskInfo(taskIdParam);
    }
  }, [searchParams]);

  const fetchTaskInfo = async (id: string) => {
    try {
      setLoading(true);
      const response = await api.get(`/patrol-tasks/${id}`);
      setTaskInfo(response.data);
    } catch (error) {
      console.error('Error fetching task info:', error);
      toast.error('Không thể tải thông tin nhiệm vụ');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckin = async () => {
    if (!taskId || !photo) {
      toast.error('Vui lòng chụp ảnh trước khi check-in');
        return;
      }
      
    try {
      setLoading(true);
      const formData = new FormData();
      formData.append('task_id', taskId);
      formData.append('photo', photo);
      formData.append('notes', message);

      await api.post('/patrol-records/checkin', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      setCheckinSuccess(true);
      toast.success('Check-in thành công!');
    } catch (error) {
      console.error('Check-in error:', error);
      toast.error('Lỗi khi check-in');
    } finally {
      setLoading(false);
    }
  };

  const capturePhoto = () => {
    const videoElement = videoRef.current;
    if (!videoElement) {
      toast.error('Không tìm thấy video element');
      return;
    }

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    
    if (!ctx) {
      toast.error('Không thể tạo canvas context');
      return;
    }

    canvas.width = videoElement.videoWidth;
    canvas.height = videoElement.videoHeight;
    ctx.drawImage(videoElement, 0, 0, canvas.width, canvas.height);
        
        canvas.toBlob((blob) => {
          if (blob) {
            const file = new File([blob], 'checkin-photo.jpg', { type: 'image/jpeg' });
            setPhoto(file);
            setPreview(URL.createObjectURL(blob));
        toast.success('Đã chụp ảnh thành công!');
      }
    }, 'image/jpeg', 0.9);
  };

  const toggleCamera = () => {
    setShowCamera(!showCamera);
    if (showCamera) {
      setCameraError(null);
    }
  };

  const toggleFacingMode = () => {
    setFacingMode(prevMode => prevMode === 'user' ? 'environment' : 'user');
  };

  if (loading && !taskInfo) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Đang tải thông tin nhiệm vụ...</p>
        </div>
      </div>
    );
  }

  if (!taskInfo) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-800 mb-4">Không tìm thấy nhiệm vụ</h1>
          <button
            onClick={() => navigate('/dashboard')}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
          >
            Quay lại Dashboard
          </button>
        </div>
      </div>
    );
  }

  if (checkinSuccess) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md text-center max-w-md">
          <div className="text-6xl mb-4">✅</div>
          <h1 className="text-2xl font-bold text-green-600 mb-4">Check-in thành công!</h1>
          <p className="text-gray-600 mb-6">Bạn đã hoàn thành nhiệm vụ này.</p>
          <button
            onClick={() => navigate('/dashboard')}
            className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
          >
            Quay lại Dashboard
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-2xl mx-auto">
        <div className="bg-white rounded-lg shadow-md p-6">
          <h1 className="text-2xl font-bold text-gray-800 mb-6">Check-in Nhiệm vụ</h1>
          
          {/* Task Info */}
          <div className="mb-6 p-4 bg-blue-50 rounded-lg">
            <h2 className="text-lg font-semibold text-blue-800 mb-2">{taskInfo.title}</h2>
            <p className="text-blue-600">{taskInfo.description}</p>
            <p className="text-sm text-blue-500 mt-2">
              Vị trí: {taskInfo.location?.name || 'Không xác định'}
            </p>
          </div>

          {/* Camera Section */}
        <div className="mb-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold">Chụp ảnh xác thực</h3>
              <div className="flex gap-2">
                <button
                  onClick={toggleFacingMode}
                  className="px-3 py-1 bg-gray-500 text-white rounded text-sm hover:bg-gray-600"
                >
                  {facingMode === 'user' ? '📱 Selfie' : '📷 Back'}
                </button>
                <button
                  onClick={toggleCamera}
                  className={`px-4 py-2 rounded-lg font-medium ${
                    showCamera 
                      ? 'bg-red-500 text-white hover:bg-red-600' 
                      : 'bg-green-500 text-white hover:bg-green-600'
                  }`}
                >
                  {showCamera ? '⏹️ Tắt Camera' : '📷 Bật Camera'}
                </button>
              </div>
            </div>

            {showCamera ? (
              <div className="relative">
                <SimpleCamera
                  isActive={showCamera}
                  onError={(error) => {
                    setCameraError(error);
                    console.error('Camera error:', error);
                  }}
                  onReady={() => {
                    setCameraError(null);
                    console.log('Camera ready');
                  }}
                  className="w-full h-64 rounded-lg"
                  facingMode={facingMode}
                />
                <div className="mt-4 flex gap-2">
                <button
                    onClick={capturePhoto}
                    className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 font-medium"
                >
                    📸 Chụp ảnh
                </button>
              </div>
            </div>
          ) : (
              <div className="w-full h-64 bg-gray-200 rounded-lg flex items-center justify-center">
                <div className="text-center">
                  <div className="text-4xl mb-2">📷</div>
                  <p className="text-gray-600">Nhấn "Bật Camera" để chụp ảnh</p>
                </div>
            </div>
          )}

            {cameraError && (
              <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                <p className="text-red-700">{cameraError}</p>
          </div>
        )}

            {preview && (
              <div className="mt-4">
                <h4 className="font-semibold mb-2">Ảnh đã chụp:</h4>
                <img 
                  src={preview} 
                  alt="Captured" 
                  className="w-full max-w-md h-48 object-cover rounded-lg border"
                />
              </div>
            )}
          </div>

          {/* Notes Section */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Ghi chú (tùy chọn):
            </label>
            <textarea
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              rows={3}
              placeholder="Nhập ghi chú..."
            />
          </div>

          {/* Submit Button */}
          <div className="flex gap-4">
            <button
              onClick={() => navigate('/dashboard')}
              className="flex-1 px-6 py-3 bg-gray-500 text-white rounded-lg hover:bg-gray-600 font-medium"
            >
              Hủy
          </button>
          <button
              onClick={handleCheckin}
              disabled={loading || !photo}
              className={`flex-1 px-6 py-3 rounded-lg font-medium ${
                loading || !photo
                  ? 'bg-gray-400 text-gray-600 cursor-not-allowed'
                  : 'bg-green-500 text-white hover:bg-green-600'
              }`}
            >
              {loading ? '⏳ Đang xử lý...' : '✅ Check-in'}
          </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CheckinPage;
