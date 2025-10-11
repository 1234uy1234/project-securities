import React, { useEffect } from 'react';
import { useCamera, UseCameraOptions } from '../hooks/useCamera';

interface OptimizedCameraProps {
  type: 'qr' | 'photo' | 'face';
  isActive: boolean;
  onError?: (error: string) => void;
  onReady?: () => void;
  className?: string;
  showControls?: boolean;
  onSwitchCamera?: () => void;
}

const OptimizedCamera: React.FC<OptimizedCameraProps> = ({
  type,
  isActive,
  onError,
  onReady,
  className = '',
  showControls = false,
  onSwitchCamera
}) => {
  const {
    videoRef,
    isActive: cameraActive,
    isInitializing,
    error,
    startCamera,
    stopCamera,
    switchCamera
  } = useCamera({
    type,
    autoStart: false,
    timeout: 15000 // 15 giây timeout cho mobile
  });

  // Handle camera start/stop based on isActive prop
  useEffect(() => {
    if (isActive && !cameraActive && !isInitializing) {
      console.log(`🎥 Starting ${type} camera...`);
      startCamera();
    } else if (!isActive && cameraActive) {
      console.log(`🛑 Stopping ${type} camera...`);
      stopCamera();
    }
  }, [isActive, cameraActive, isInitializing, startCamera, stopCamera, type]);

  // Handle errors
  useEffect(() => {
    if (error && onError) {
      onError(error);
    }
  }, [error, onError]);

  // Handle camera ready
  useEffect(() => {
    if (cameraActive && onReady) {
      onReady();
    }
  }, [cameraActive, onReady]);

  const handleSwitchCamera = () => {
    if (onSwitchCamera) {
      onSwitchCamera();
    } else {
      switchCamera();
    }
  };

  return (
    <div className={`relative ${className}`}>
      {/* Video Element */}
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        className={`w-full h-full object-cover ${
          type === 'qr' ? 'scale-x-[-1]' : 'scale-x-[-1]'
        }`}
        style={{
          // Tối ưu cho mobile
          WebkitTransform: 'scaleX(-1)',
          WebkitBackfaceVisibility: 'hidden',
          backfaceVisibility: 'hidden',
          transform: 'scaleX(-1)',
          imageRendering: 'auto',
          objectFit: 'cover'
        }}
      />
      
      {/* Loading Overlay */}
      {isInitializing && (
        <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
          <div className="text-white text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto mb-2"></div>
            <p className="text-sm">Đang khởi động camera...</p>
          </div>
        </div>
      )}
      
      {/* Error Overlay */}
      {error && (
        <div className="absolute inset-0 bg-red-500 bg-opacity-80 flex items-center justify-center">
          <div className="text-white text-center p-4">
            <p className="text-sm mb-2">❌ {error}</p>
            <button
              onClick={startCamera}
              className="bg-white text-red-500 px-4 py-2 rounded text-sm font-medium"
            >
              Thử lại
            </button>
          </div>
        </div>
      )}
      
      {/* Camera Controls */}
      {showControls && cameraActive && (
        <div className="absolute bottom-4 right-4 flex gap-2">
          <button
            onClick={handleSwitchCamera}
            className="bg-black bg-opacity-50 text-white p-2 rounded-full hover:bg-opacity-70"
            title="Chuyển camera"
          >
            🔄
          </button>
          <button
            onClick={stopCamera}
            className="bg-red-500 bg-opacity-80 text-white p-2 rounded-full hover:bg-opacity-100"
            title="Tắt camera"
          >
            ❌
          </button>
        </div>
      )}
      
      {/* Camera Status Indicator */}
      {cameraActive && (
        <div className="absolute top-2 left-2 bg-green-500 text-white px-2 py-1 rounded text-xs">
          📹 {type === 'qr' ? 'QR Scanner' : type === 'photo' ? 'Photo Camera' : 'Face Camera'}
        </div>
      )}
    </div>
  );
};

export default OptimizedCamera;
