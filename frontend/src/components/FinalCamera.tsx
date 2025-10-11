import React, { useRef, useEffect, useState } from 'react';
import CameraManager from '../utils/cameraManager';

interface FinalCameraProps {
  isActive: boolean;
  onError?: (error: string) => void;
  onReady?: () => void;
  className?: string;
  facingMode?: 'user' | 'environment';
}

const FinalCamera: React.FC<FinalCameraProps> = ({
  isActive,
  onError,
  onReady,
  className = '',
  facingMode = 'user'
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [stream, setStream] = useState<MediaStream | null>(null);
  
  // Camera Manager instance
  const cameraManager = CameraManager.getInstance();

  useEffect(() => {
    let currentStream: MediaStream | null = null;

    const startCamera = async () => {
      if (!isActive) return;

      // Stop any existing stream first
      if (currentStream) {
        currentStream.getTracks().forEach(track => track.stop());
        currentStream = null;
        setStream(null);
      }

      if (videoRef.current) {
        videoRef.current.srcObject = null;
      }

      // Stop tất cả camera tracks trên toàn hệ thống
      await cameraManager.stopAllCameraTracks();

      setIsLoading(true);
      setError(null);

      try {
        // Get optimized camera constraints for photo/face
        const cameraType = facingMode === 'user' ? 'photo' : 'qr';
        const constraints = cameraManager.getOptimizedConstraints(cameraType);
        console.log('📱 Using optimized camera constraints:', constraints);
        
        // Get camera stream using CameraManager
        const newStream = await cameraManager.getStream('final-camera', constraints);
        currentStream = newStream;
        setStream(newStream);

        if (videoRef.current) {
          videoRef.current.srcObject = newStream;
          
          videoRef.current.addEventListener('loadedmetadata', () => {
            videoRef.current?.play().then(() => {
              setIsLoading(false);
              if (onReady) onReady();
            }).catch(() => {
              setError('Không thể phát video');
              setIsLoading(false);
              if (onError) onError('Không thể phát video');
            });
          }, { once: true });
        }
      } catch (err: any) {
        console.error('❌ Camera error:', err);
        let errorMessage = 'Không thể khởi động camera';
        if (err.name === 'NotReadableError') {
          errorMessage = 'Camera đang được sử dụng. Vui lòng đóng ứng dụng khác và thử lại';
        } else if (err.name === 'NotAllowedError') {
          errorMessage = 'Không có quyền truy cập camera. Vui lòng cho phép truy cập camera';
        } else if (err.name === 'NotFoundError') {
          errorMessage = 'Không tìm thấy camera. Vui lòng kiểm tra kết nối camera';
        } else if (err.name === 'OverconstrainedError') {
          errorMessage = 'Camera không hỗ trợ cài đặt yêu cầu. Đang thử cài đặt khác...';
          // Thử lại với cài đặt đơn giản hơn
          try {
            const fallbackStream = await navigator.mediaDevices.getUserMedia({
              video: { facingMode },
              audio: false
            });
            currentStream = fallbackStream;
            setStream(fallbackStream);
            if (videoRef.current) {
              videoRef.current.srcObject = fallbackStream;
              videoRef.current.addEventListener('loadedmetadata', () => {
                videoRef.current?.play().then(() => {
                  setIsLoading(false);
                  if (onReady) onReady();
                }).catch(() => {
                  setError('Không thể phát video');
                  setIsLoading(false);
                  if (onError) onError('Không thể phát video');
                });
              }, { once: true });
            }
            return; // Thành công với fallback
          } catch (fallbackErr: any) {
            console.error('❌ Fallback camera error:', fallbackErr);
            errorMessage = 'Không thể khởi động camera với bất kỳ cài đặt nào';
          }
        }
        setError(errorMessage);
        setIsLoading(false);
        if (onError) onError(errorMessage);
      }
    };

    const stopCamera = async () => {
      // Use CameraManager to stop the stream
      await cameraManager.stopStream('final-camera');
      
      if (currentStream) {
        currentStream = null;
        setStream(null);
      }
      if (videoRef.current) {
        videoRef.current.srcObject = null;
      }
      setError(null);
      setIsLoading(false);
    };

    if (isActive) {
      startCamera();
    } else {
      stopCamera();
    }

    return () => {
      stopCamera();
    };
  }, [isActive, facingMode, onError, onReady]);

  if (error) {
    return (
      <div className={`flex items-center justify-center w-full h-full bg-gray-900 text-white rounded-lg ${className}`}>
        <div className="text-center p-4">
          <p className="text-red-500 mb-2 text-4xl">📷</p>
          <p className="text-sm font-medium mb-2">{error}</p>
          <button
            onClick={() => {
              setError(null);
              if (isActive) {
                setIsLoading(true);
                setTimeout(() => setIsLoading(false), 100);
              }
            }}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 text-sm mt-2"
          >
            🔄 Thử lại
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={`relative w-full h-full bg-black rounded-lg overflow-hidden ${className}`}>
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75 text-white z-10">
          <p>Đang tải...</p>
        </div>
      )}
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        className="w-full h-full object-cover"
      />
    </div>
  );
};

export default FinalCamera;