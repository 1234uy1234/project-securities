import React, { useRef, useState, useCallback, useEffect } from 'react';
import { Camera, X, Check, RotateCcw } from 'lucide-react';

interface SimpleCameraModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (userData: any) => void;
  onRegisterSuccess: () => void;
  mode: 'register' | 'verify';
}

const SimpleCameraModal: React.FC<SimpleCameraModalProps> = ({
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
  const [cameraReady, setCameraReady] = useState(false);
  const [isInitializing, setIsInitializing] = useState(false);

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      setCameraReady(false);
      setIsInitializing(true);
      
      // Tối ưu camera settings cho mobile
      const constraints = {
        video: {
          width: { ideal: 640, max: 1280 },
          height: { ideal: 480, max: 720 },
          facingMode: 'user',
          frameRate: { ideal: 24, max: 30 },
          // Tối ưu cho mobile
          aspectRatio: { ideal: 4/3 },
          resizeMode: 'crop-and-scale'
        },
        audio: false // Tắt audio để tiết kiệm tài nguyên
      };

      // Kiểm tra xem có camera không
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('Camera không được hỗ trợ trên thiết bị này');
      }

      const mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
      setStream(mediaStream);
      
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        
        // Tối ưu cho mobile - đợi video load
        const video = videoRef.current;
        
        const handleLoadedMetadata = () => {
          video.play()
            .then(() => {
              setCameraReady(true);
              setIsInitializing(false);
              console.log('📹 Camera ready for mobile');
            })
            .catch((err) => {
              console.error('Video play error:', err);
              setError('Không thể khởi động camera. Vui lòng thử lại.');
              setIsInitializing(false);
            });
        };

        const handleError = () => {
          setError('Lỗi camera. Vui lòng kiểm tra quyền truy cập.');
          setIsInitializing(false);
        };

        video.addEventListener('loadedmetadata', handleLoadedMetadata, { once: true });
        video.addEventListener('error', handleError, { once: true });
      }
    } catch (err: any) {
      console.error('Camera error:', err);
      setError(err.message || 'Không thể truy cập camera. Vui lòng kiểm tra quyền truy cập.');
      setIsInitializing(false);
    }
  }, []);

  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => {
        track.stop();
        console.log('📹 Camera track stopped');
      });
      setStream(null);
      setCameraReady(false);
    }
  }, [stream]);

  const capturePhoto = useCallback(() => {
    if (!videoRef.current || !canvasRef.current || isCapturing || !cameraReady) return;
    
    setIsCapturing(true);
    
    // Giảm debounce time cho mobile
    setTimeout(() => {
      try {
        const video = videoRef.current;
        const canvas = canvasRef.current;
        const ctx = canvas?.getContext('2d');
        
        if (!ctx || !video || !canvas) return;
        
        // Tối ưu canvas size cho mobile
        const videoWidth = video.videoWidth;
        const videoHeight = video.videoHeight;
        
        // Giữ tỷ lệ khung hình
        const aspectRatio = videoWidth / videoHeight;
        let canvasWidth = videoWidth;
        let canvasHeight = videoHeight;
        
        // Giới hạn kích thước cho mobile
        if (canvasWidth > 800) {
          canvasWidth = 800;
          canvasHeight = canvasWidth / aspectRatio;
        }
        
        canvas.width = canvasWidth;
        canvas.height = canvasHeight;
        
        // Draw video frame với chất lượng tốt
        ctx.imageSmoothingEnabled = true;
        ctx.imageSmoothingQuality = 'high';
        ctx.drawImage(video, 0, 0, canvasWidth, canvasHeight);
        
        // Thêm timestamp overlay
        const now = new Date();
        const timestamp = now.toLocaleString('vi-VN', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit',
          second: '2-digit'
        });
        
        // Tối ưu overlay cho mobile
        const fontSize = Math.max(12, canvasWidth / 40);
        const padding = Math.max(8, canvasWidth / 80);
        
        ctx.fillStyle = 'rgba(0, 0, 0, 0.8)';
        ctx.fillRect(padding, canvasHeight - fontSize - padding * 2, canvasWidth - padding * 2, fontSize + padding);
        
        ctx.fillStyle = 'white';
        ctx.font = `bold ${fontSize}px Arial`;
        ctx.textAlign = 'left';
        ctx.fillText(`📅 ${timestamp}`, padding * 2, canvasHeight - padding);
        
        // Convert to base64 với chất lượng cao cho mobile
        const base64 = canvas.toDataURL('image/jpeg', 0.9);
        setCapturedImage(base64);
        
        // Stop camera sau khi chụp để tiết kiệm tài nguyên
        stopCamera();
        
      } catch (err) {
        console.error('Capture error:', err);
        setError('Lỗi chụp ảnh. Vui lòng thử lại.');
      } finally {
        setIsCapturing(false);
      }
    }, 300); // Giảm từ 500ms xuống 300ms
  }, [isCapturing, cameraReady, stopCamera]);

  const retakePhoto = useCallback(() => {
    setCapturedImage(null);
    setError(null);
    // Khởi động lại camera với delay nhỏ
    setTimeout(() => {
      startCamera();
    }, 100);
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
      
      if (mode === 'register') {
        const username = localStorage.getItem('username') || 'admin';
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
          if (data.matched_user) {
            onSuccess(data.matched_user);
          } else {
            onSuccess(data.user);
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
    setIsInitializing(false);
    onClose();
  }, [stopCamera, onClose]);

  // Tối ưu camera startup cho mobile
  useEffect(() => {
    if (isOpen && !capturedImage) {
      // Delay nhỏ để đảm bảo modal đã render xong
      const timer = setTimeout(() => {
        startCamera();
      }, 100);
      
      return () => {
        clearTimeout(timer);
        if (!capturedImage) {
          stopCamera();
        }
      };
    }
  }, [isOpen, capturedImage, startCamera, stopCamera]);

  // Cleanup khi component unmount
  useEffect(() => {
    return () => {
      stopCamera();
    };
  }, [stopCamera]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-2 sm:p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[95vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <h3 className="text-lg font-semibold text-gray-900">
            {mode === 'register' ? '📸 Đăng ký khuôn mặt' : '🔐 Đăng nhập bằng khuôn mặt'}
          </h3>
          <button
            onClick={handleClose}
            className="text-gray-400 hover:text-gray-600 transition-colors p-1"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4 space-y-4">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
              ⚠️ {error}
            </div>
          )}

          {!capturedImage ? (
            // Camera View
            <div className="space-y-4">
              <div className="relative bg-gray-100 rounded-lg overflow-hidden">
                {isInitializing && (
                  <div className="absolute inset-0 flex items-center justify-center bg-gray-200 z-10">
                    <div className="text-center">
                      <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
                      <p className="text-sm text-gray-600">Đang khởi động camera...</p>
                    </div>
                  </div>
                )}
                
                <video
                  ref={videoRef}
                  autoPlay
                  playsInline
                  muted
                  className="w-full h-64 sm:h-80 object-cover"
                  style={{
                    transform: 'scaleX(-1)',
                    objectFit: 'cover',
                    // Tối ưu CSS cho mobile
                    imageRendering: 'auto',
                    backfaceVisibility: 'hidden',
                    willChange: 'auto',
                    WebkitTransform: 'scaleX(-1)',
                    WebkitBackfaceVisibility: 'hidden'
                  }}
                />
                <canvas
                  ref={canvasRef}
                  className="hidden"
                />
                
                {/* Face positioning guide - tối ưu cho mobile */}
                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                  <div className="w-40 h-40 sm:w-48 sm:h-48 border-3 border-white border-dashed rounded-full opacity-80 shadow-lg">
                    <div className="absolute top-2 left-1/2 transform -translate-x-1/2 text-white text-xs sm:text-sm font-medium text-center">
                      Đặt khuôn mặt<br/>trong khung này
                    </div>
                  </div>
                </div>
                
                {/* Camera status */}
                {cameraReady && (
                  <div className="absolute top-2 right-2 bg-green-500 text-white px-2 py-1 rounded-full text-xs">
                    📹 Sẵn sàng
                  </div>
                )}
              </div>

              <div className="text-center">
                <p className="text-sm text-gray-600 mb-4">
                  {mode === 'register' 
                    ? 'Chụp ảnh khuôn mặt để đăng ký'
                    : 'Chụp ảnh khuôn mặt để đăng nhập'
                  }
                </p>
                
                <button
                  onClick={capturePhoto}
                  disabled={!cameraReady || isCapturing || isInitializing}
                  className="flex items-center justify-center space-x-2 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all duration-200 mx-auto text-sm sm:text-base"
                >
                  {isCapturing ? (
                    <>
                      <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>Đang chụp...</span>
                    </>
                  ) : (
                    <>
                      <Camera className="w-5 h-5" />
                      <span>📸 Chụp ảnh</span>
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
                  className="w-full h-64 sm:h-80 object-cover"
                  style={{
                    transform: 'scaleX(-1)',
                    objectFit: 'cover'
                  }}
                />
                <div className="absolute top-2 right-2 bg-green-500 text-white px-2 py-1 rounded-full text-xs">
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
                
                <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-3 justify-center">
                  <button
                    onClick={retakePhoto}
                    disabled={isProcessing}
                    className="flex items-center justify-center space-x-2 bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all duration-200 text-sm"
                  >
                    <RotateCcw className="w-4 h-4" />
                    <span>Chụp lại</span>
                  </button>
                  
                  <button
                    onClick={processPhoto}
                    disabled={isProcessing}
                    className="flex items-center justify-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all duration-200 text-sm"
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

export default SimpleCameraModal;
