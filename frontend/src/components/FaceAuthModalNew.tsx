import React, { useRef, useEffect, useState, useCallback } from 'react';
import { Camera, X, AlertCircle, CheckCircle } from 'lucide-react';

interface FaceAuthModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (userData: any) => void;
  mode: 'register' | 'verify';
  onRegisterSuccess?: () => void;
}

const FaceAuthModalNew: React.FC<FaceAuthModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
  mode,
  onRegisterSuccess
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [isCapturing, setIsCapturing] = useState(false);

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      
      // Camera settings ổn định hoàn toàn
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 640, min: 320, max: 1280 },
          height: { ideal: 480, min: 240, max: 720 },
          facingMode: 'user',
          frameRate: { ideal: 15, min: 10, max: 30 },
          aspectRatio: { ideal: 4/3 }
        }
      });
      
      setStream(mediaStream);
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        
        videoRef.current.onloadedmetadata = () => {
          if (videoRef.current) {
            videoRef.current.play().catch(console.error);
            console.log('Video metadata loaded, playing...');
          }
        };
        
        videoRef.current.oncanplay = () => {
          console.log('Video can play');
        };
        
        videoRef.current.onplaying = () => {
          console.log('Video is playing');
        };
        
        videoRef.current.onwaiting = () => {
          console.log('Video is waiting for data');
        };
        
        videoRef.current.onerror = (e) => {
          console.error('Video error:', e);
          setError('Lỗi hiển thị video. Vui lòng thử lại.');
        };
      }
    } catch (err) {
      setError('Không thể truy cập camera. Vui lòng kiểm tra quyền truy cập.');
      console.error('Camera error:', err);
    }
  }, []);

  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
  }, [stream]);

  const capturePhoto = useCallback(() => {
    if (!videoRef.current || !canvasRef.current || isCapturing) return;

    setIsCapturing(true);
    
    try {
      const video = videoRef.current;
      const canvas = canvasRef.current;
      const context = canvas.getContext('2d');

      if (!context) return;

      // Set canvas size to match video
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;

      // Draw video frame to canvas
      context.drawImage(video, 0, 0, canvas.width, canvas.height);

      // Convert to base64
      const base64 = canvas.toDataURL('image/jpeg', 0.8);
      return base64;
    } finally {
      // Reset capturing state after a delay
      setTimeout(() => setIsCapturing(false), 2000);
    }
  }, [isCapturing]);

  const processFaceAuth = async (imageData: string) => {
    setIsProcessing(true);
    setError(null);
    setSuccess(null);

    try {
      const baseUrl = import.meta.env.VITE_API_URL || 'https://rolanda-skinless-sue.ngrok-free.dev';
      const endpoint = mode === 'register' ? `${baseUrl}/api/face-storage/save-face` : `${baseUrl}/api/face-storage/compare-face`;
      
      const formData = new FormData();
      formData.append('image_data', imageData);
      
      // API MỚI: register cần username, compare không cần
      if (mode === 'register') {
        // Lấy username từ localStorage hoặc auth store
        const username = localStorage.getItem('username') || 'hung'; // fallback
        formData.append('username', username);
      }

      const response = await fetch(endpoint, {
        method: 'POST',
        credentials: 'include',
        body: formData
      });

      const data = await response.json();

      if (data.success) {
        setSuccess(data.message);
        if (mode === 'register' && onRegisterSuccess) {
          onRegisterSuccess();
        } else if (mode === 'verify') {
          // API MỚI: compare-face trả về matched_user thay vì user
          if (data.matched_user) {
            onSuccess(data.matched_user);
          } else if (data.user) {
            onSuccess(data.user); // fallback
          }
        }
      } else {
        setError(data.message || 'Có lỗi xảy ra');
      }
    } catch (error) {
      console.error('Face auth error:', error);
      setError('Không thể kết nối đến server');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleCapture = useCallback(() => {
    if (isCapturing || isProcessing || !stream) return;

    const imageData = capturePhoto();
    if (imageData) {
      processFaceAuth(imageData);
    }
  }, [isCapturing, isProcessing, stream, capturePhoto]);

  useEffect(() => {
    if (isOpen) {
      startCamera();
    } else {
      stopCamera();
    }
  }, [isOpen, startCamera, stopCamera]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold">
            {mode === 'register' ? 'Đăng ký khuôn mặt' : 'Xác thực khuôn mặt'}
          </h3>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="space-y-4">
          {/* Camera Preview */}
          <div className="relative bg-gray-100 rounded-lg overflow-hidden">
            <video
              ref={videoRef}
              autoPlay
              playsInline
              muted
              className="w-full h-64 object-cover"
              style={{
                transform: 'scaleX(-1)',
                filter: 'brightness(1.1) contrast(1.1)',
                objectFit: 'cover',
                // CSS để ổn định stream
                imageRendering: 'auto',
                backfaceVisibility: 'hidden',
                perspective: '1000px',
                transformStyle: 'preserve-3d',
                willChange: 'transform'
              }}
              // Thêm attributes để ổn định
              preload="auto"
              webkit-playsinline="true"
            />
            <canvas
              ref={canvasRef}
              className="hidden"
            />
            
            {/* Overlay for face detection */}
            <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
              <div className="w-48 h-48 border-3 border-white border-dashed rounded-full opacity-70 shadow-lg">
                <div className="absolute top-4 left-1/2 transform -translate-x-1/2 text-white text-sm font-medium">
                  Đặt khuôn mặt trong khung này
                </div>
              </div>
            </div>
            
            {/* Status indicator */}
            {stream && (
              <div className="absolute top-4 right-4 bg-green-500 text-white px-2 py-1 rounded-full text-xs">
                📹 Camera đang hoạt động
              </div>
            )}
          </div>

          {/* Instructions */}
          <div className="text-center text-sm text-gray-600">
            {mode === 'register' ? (
              <p>Đặt khuôn mặt trong khung tròn và nhấn chụp ảnh</p>
            ) : (
              <p>Nhìn vào camera và nhấn chụp ảnh để xác thực</p>
            )}
          </div>

          {/* Status Messages */}
          {error && (
            <div className="flex items-center space-x-2 text-red-600 bg-red-50 p-3 rounded-lg">
              <AlertCircle className="w-5 h-5" />
              <span className="text-sm">{error}</span>
            </div>
          )}

          {success && (
            <div className="flex items-center space-x-2 text-green-600 bg-green-50 p-3 rounded-lg">
              <CheckCircle className="w-5 h-5" />
              <span className="text-sm">{success}</span>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex space-x-3">
            <button
              onClick={handleCapture}
              disabled={isCapturing || isProcessing || !stream}
              className="flex-1 flex items-center justify-center space-x-2 bg-blue-600 text-white px-4 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all duration-300"
            >
              {isCapturing ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  <span>Đang chụp...</span>
                </>
              ) : isProcessing ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  <span>Đang xử lý...</span>
                </>
              ) : (
                <>
                  <Camera className="w-4 h-4" />
                  <span>Chụp ảnh</span>
                </>
              )}
            </button>
            <button
              onClick={onClose}
              className="px-4 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Hủy
            </button>
          </div>

          {/* Tips */}
          <div className="text-xs text-gray-500">
            <p className="font-medium mb-1">Mẹo:</p>
            <ul className="list-disc list-inside space-y-1">
              <li>Đảm bảo ánh sáng đủ</li>
              <li>Nhìn thẳng vào camera</li>
              <li>Giữ khuôn mặt trong khung tròn</li>
              <li>Tránh đeo kính râm hoặc khẩu trang</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FaceAuthModalNew;
