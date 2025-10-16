import React, { useRef, useState, useCallback } from 'react';
import { Camera, X, Check, RotateCcw } from 'lucide-react';

interface FaceCaptureModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (userData: any) => void;
  onRegisterSuccess: () => void;
  mode: 'register' | 'verify';
}

const FaceCaptureModal: React.FC<FaceCaptureModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
  onRegisterSuccess,
  mode
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [capturedImage, setCapturedImage] = useState<string | null>(null);
  const [isCapturing, setIsCapturing] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      
      // Tối ưu camera settings cho mobile
      const constraints = {
        video: {
          width: { ideal: 640, max: 1280 },
          height: { ideal: 480, max: 720 },
          facingMode: 'user',
          frameRate: { ideal: 24, max: 30 },
          aspectRatio: { ideal: 4/3 },
          resizeMode: 'crop-and-scale'
        },
        audio: false // Tắt audio để tiết kiệm tài nguyên
      };
      
      const mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
      setStream(mediaStream);
      
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        
        // Tối ưu cho mobile
        const video = videoRef.current;
        const handleLoadedMetadata = () => {
          video.play()
            .then(() => {
              console.log('📹 FaceCapture camera ready for mobile');
            })
            .catch((err) => {
              console.error('Video play error:', err);
              setError('Không thể khởi động camera. Vui lòng thử lại.');
            });
        };

        video.addEventListener('loadedmetadata', handleLoadedMetadata, { once: true });
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
      const ctx = canvas.getContext('2d');
      
      if (!ctx) return;
      
      // Set canvas size to video size
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      
      // Draw video frame to canvas
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
      
      // Add timestamp overlay
      const now = new Date();
      const timestamp = now.toLocaleString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
      
      // Set text style
      ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
      ctx.fillRect(10, canvas.height - 50, 300, 40);
      
      ctx.fillStyle = 'white';
      ctx.font = 'bold 16px Arial';
      ctx.textAlign = 'left';
      ctx.fillText(`📅 ${timestamp}`, 15, canvas.height - 25);
      
      // Convert to base64
      const base64 = canvas.toDataURL('image/jpeg', 0.9);
      setCapturedImage(base64);
      
      // Stop camera after capture
      stopCamera();
      
    } catch (err) {
      console.error('Capture error:', err);
      setError('Lỗi chụp ảnh. Vui lòng thử lại.');
    } finally {
      setIsCapturing(false);
    }
  }, [isCapturing, stopCamera]);

  const retakePhoto = useCallback(() => {
    setCapturedImage(null);
    setError(null);
    startCamera();
  }, [startCamera]);

  const processPhoto = useCallback(async () => {
    if (!capturedImage || isProcessing) return;
    
    setIsProcessing(true);
    setError(null);
    
    try {
      const baseUrl = import.meta.env.VITE_API_URL || 'https://rolanda-skinless-sue.ngrok-free.dev';
      const endpoint = mode === 'register' 
        ? `${baseUrl}/api/face-storage/save-face` 
        : `${baseUrl}/api/face-storage/compare-face`;
      
      const formData = new FormData();
      formData.append('image_data', capturedImage);
      
      // API MỚI: register cần username, compare không cần
      if (mode === 'register') {
        // Lấy username từ localStorage hoặc auth store
        const username = localStorage.getItem('username') || 'hung'; // fallback
        formData.append('username', username);
      }
      
      const response = await fetch(endpoint, {
        method: 'POST',
        body: formData
      });
      
      const data = await response.json();
      
      if (data.success) {
        if (mode === 'register') {
          onRegisterSuccess();
          onClose();
        } else {
          // API MỚI: compare-face trả về matched_user thay vì user
          if (data.matched_user) {
            onSuccess(data.matched_user);
          } else {
            onSuccess(data.user); // fallback
          }
          onClose();
        }
      } else {
        setError(data.message || 'Có lỗi xảy ra. Vui lòng thử lại.');
      }
    } catch (err) {
      console.error('API error:', err);
      setError('Lỗi kết nối. Vui lòng thử lại.');
    } finally {
      setIsProcessing(false);
    }
  }, [capturedImage, mode, onSuccess, onRegisterSuccess, onClose]);

  const handleClose = useCallback(() => {
    stopCamera();
    setCapturedImage(null);
    setError(null);
    onClose();
  }, [stopCamera, onClose]);

  // Start camera when modal opens
  React.useEffect(() => {
    if (isOpen && !capturedImage) {
      startCamera();
    }
    return () => {
      if (!capturedImage) {
        stopCamera();
      }
    };
  }, [isOpen, capturedImage, startCamera, stopCamera]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <h3 className="text-lg font-semibold text-gray-900">
            {mode === 'register' ? 'Đăng ký khuôn mặt' : 'Đăng nhập bằng khuôn mặt'}
          </h3>
          <button
            onClick={handleClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4 space-y-4">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
              {error}
            </div>
          )}

          {!capturedImage ? (
            // Camera View
            <div className="space-y-4">
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
                    objectFit: 'cover'
                  }}
                />
                <canvas
                  ref={canvasRef}
                  className="hidden"
                />
                
                {/* Overlay for face positioning */}
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                  <div className="w-48 h-48 border-3 border-white border-dashed rounded-full opacity-70 shadow-lg">
                    <div className="absolute top-4 left-1/2 transform -translate-x-1/2 text-white text-sm font-medium text-center">
                      Đặt khuôn mặt<br/>trong khung này
                    </div>
                  </div>
                </div>
                
                {/* Camera status */}
                {stream && (
                  <div className="absolute top-4 right-4 bg-green-500 text-white px-2 py-1 rounded-full text-xs">
                    📹 Camera sẵn sàng
                  </div>
                )}
              </div>

              <div className="text-center">
                <p className="text-sm text-gray-600 mb-4">
                  {mode === 'register' 
                    ? 'Chụp ảnh khuôn mặt để đăng ký. Ảnh sẽ được lưu để xác thực sau này.'
                    : 'Chụp ảnh khuôn mặt để đăng nhập. Hệ thống sẽ so sánh với ảnh đã đăng ký.'
                  }
                </p>
                
                <button
                  onClick={capturePhoto}
                  disabled={!stream || isCapturing}
                  className="flex items-center justify-center space-x-2 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all duration-200 mx-auto"
                >
                  {isCapturing ? (
                    <>
                      <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>Đang chụp...</span>
                    </>
                  ) : (
                    <>
                      <Camera className="w-5 h-5" />
                      <span>Chụp ảnh</span>
                    </>
                  )}
                </button>
              </div>
            </div>
          ) : (
            // Captured Image View
            <div className="space-y-4">
              <div className="relative bg-gray-100 rounded-lg overflow-hidden">
                <img
                  src={capturedImage}
                  alt="Captured face"
                  className="w-full h-64 object-cover"
                  style={{
                    transform: 'scaleX(-1)',
                    filter: 'brightness(1.1) contrast(1.1)',
                    objectFit: 'cover'
                  }}
                />
                <div className="absolute top-4 right-4 bg-green-500 text-white px-2 py-1 rounded-full text-xs">
                  ✅ Đã chụp
                </div>
              </div>

              <div className="text-center">
                <p className="text-sm text-gray-600 mb-4">
                  {mode === 'register' 
                    ? 'Ảnh khuôn mặt đã được chụp. Bạn có muốn sử dụng ảnh này để đăng ký không?'
                    : 'Ảnh khuôn mặt đã được chụp. Bạn có muốn sử dụng ảnh này để đăng nhập không?'
                  }
                </p>
                
                <div className="flex space-x-3 justify-center">
                  <button
                    onClick={retakePhoto}
                    disabled={isProcessing}
                    className="flex items-center space-x-2 bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all duration-200"
                  >
                    <RotateCcw className="w-4 h-4" />
                    <span>Chụp lại</span>
                  </button>
                  
                  <button
                    onClick={processPhoto}
                    disabled={isProcessing}
                    className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all duration-200"
                  >
                    {isProcessing ? (
                      <>
                        <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        <span>Đang xử lý...</span>
                      </>
                    ) : (
                      <>
                        <Check className="w-4 h-4" />
                        <span>{mode === 'register' ? 'Đăng ký' : 'Đăng nhập'}</span>
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default FaceCaptureModal;
