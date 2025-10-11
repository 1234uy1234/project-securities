import React, { useRef, useState, useCallback, useEffect } from 'react';
import { X, RotateCcw, AlertCircle } from 'lucide-react';

interface SimpleVideoCameraProps {
  isActive: boolean;
  onError?: (error: string) => void;
  onReady?: () => void;
  className?: string;
  facingMode?: 'user' | 'environment';
}

const SimpleVideoCamera: React.FC<SimpleVideoCameraProps> = ({
  isActive,
  onError,
  onReady,
  className = '',
  facingMode = 'user'
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentFacingMode, setCurrentFacingMode] = useState<'user' | 'environment'>(facingMode);
  const [cameraReady, setCameraReady] = useState(false);
  const [isInitialized, setIsInitialized] = useState(false);

  const stopCamera = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => track.stop());
      streamRef.current = null;
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    setIsLoading(false);
    setError(null);
    setCameraReady(false);
    setIsInitialized(false);
  }, []);

  const startCamera = useCallback(async () => {
    if (isLoading || cameraReady || streamRef.current || !isActive || isInitialized) {
      return;
    }
    
    setIsLoading(true);
    setError(null);
    setCameraReady(false);
    setIsInitialized(true);
    
    try {
      const constraints: MediaStreamConstraints = {
        video: {
          facingMode: currentFacingMode,
          width: { ideal: 640 },
          height: { ideal: 480 }
        },
        audio: false
      };
      
      const stream = await navigator.mediaDevices.getUserMedia(constraints);
      
      if (stream.active) {
        streamRef.current = stream;
        
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          
          const video = videoRef.current;
          const handleLoadedMetadata = () => {
            video.play()
              .then(() => {
                setCameraReady(true);
                setIsLoading(false);
                if (onReady) onReady();
              })
              .catch((err) => {
                setError('Không thể phát video');
                setIsLoading(false);
                if (onError) onError('Không thể phát video');
              });
          };

          video.addEventListener('loadedmetadata', handleLoadedMetadata, { once: true });
        }
      } else {
        throw new Error('Stream không active');
      }
      
    } catch (err: any) {
      let errorMessage = 'Không thể khởi động camera';
      if (err.name === 'NotAllowedError') {
        errorMessage = 'Camera bị từ chối. Vui lòng cho phép camera';
      } else if (err.name === 'NotFoundError') {
        errorMessage = 'Không tìm thấy camera';
      } else if (err.name === 'NotReadableError') {
        errorMessage = 'Camera đang được sử dụng. Vui lòng đóng ứng dụng khác và thử lại';
      } else if (err.message === 'Stream không active') {
        errorMessage = 'Camera stream không hoạt động. Vui lòng thử lại';
      }
      
      setError(errorMessage);
      setIsLoading(false);
      setIsInitialized(false);
      if (onError) onError(errorMessage);
    }
  }, [currentFacingMode, onError, onReady, isActive, isLoading, cameraReady, isInitialized]);

  useEffect(() => {
    if (isActive && !isInitialized) {
      startCamera();
    } else if (!isActive && streamRef.current) {
      stopCamera();
    }
    return () => {
      stopCamera();
    };
  }, [isActive, isInitialized, startCamera, stopCamera]);

  const toggleFacingMode = useCallback(() => {
    setCurrentFacingMode(prevMode => (prevMode === 'user' ? 'environment' : 'user'));
    stopCamera();
  }, [stopCamera]);

  if (error) {
    return (
      <div className={`relative flex flex-col items-center justify-center w-full h-full bg-gray-900 text-white rounded-lg overflow-hidden ${className}`}>
        <AlertCircle className="w-12 h-12 text-red-500 mb-4" />
        <p className="text-center text-lg font-semibold">{error}</p>
        <button
          onClick={toggleFacingMode}
          className="absolute bottom-4 left-4 p-2 bg-blue-600 text-white rounded-full shadow-lg flex items-center space-x-2"
        >
          <RotateCcw className="w-5 h-5" />
          <span>Đổi Camera</span>
        </button>
        <button
          onClick={stopCamera}
          className="absolute top-4 right-4 p-2 bg-gray-700 text-white rounded-full shadow-lg"
        >
          <X className="w-5 h-5" />
        </button>
      </div>
    );
  }

  return (
    <div className={`relative w-full h-full bg-black rounded-lg overflow-hidden ${className}`}>
      {isLoading && (
        <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-75 text-white z-10">
          <p>Đang tải camera...</p>
        </div>
      )}
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        className="w-full h-full object-cover transform scaleX(-1)"
      />
      <button
        onClick={toggleFacingMode}
        className="absolute bottom-4 left-4 p-2 bg-blue-600 text-white rounded-full shadow-lg flex items-center space-x-2"
      >
        <RotateCcw className="w-5 h-5" />
        <span>Đổi Camera</span>
      </button>
      <button
        onClick={stopCamera}
        className="absolute top-4 right-4 p-2 bg-gray-700 text-white rounded-full shadow-lg"
      >
        <X className="w-5 h-5" />
      </button>
    </div>
  );
};

export default SimpleVideoCamera;