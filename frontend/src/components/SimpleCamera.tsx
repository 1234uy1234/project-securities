import React, { useRef, useEffect, useState, useCallback } from 'react';

interface SimpleCameraProps {
  isActive: boolean;
  onError?: (error: string) => void;
  onReady?: () => void;
  className?: string;
  facingMode?: 'user' | 'environment';
}

const SimpleCamera: React.FC<SimpleCameraProps> = ({
  isActive,
  onError,
  onReady,
  className = '',
  facingMode = 'user'
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  // Stop camera function
  const stopCamera = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => track.stop());
      streamRef.current = null;
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    setError(null);
    setIsLoading(false);
  }, []);

  // Start camera function
  const startCamera = useCallback(async () => {
    if (!isActive) return;
    
    // ALWAYS stop existing stream first - CRITICAL for facingMode switching
    if (streamRef.current) {
      console.log('🛑 Stopping existing stream before switching facingMode');
      streamRef.current.getTracks().forEach(track => {
        track.stop();
        console.log('🛑 Track stopped:', track.kind, track.label);
      });
      streamRef.current = null;
    }
    
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    
    // Wait for cleanup to complete
    await new Promise(resolve => setTimeout(resolve, 300));
    
    setIsLoading(true);
    setError(null);

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode },
        audio: false
      });

      console.log('✅ New stream obtained for facingMode:', facingMode);

      if (videoRef.current) {
        streamRef.current = stream;
        videoRef.current.srcObject = stream;
        
        videoRef.current.addEventListener('loadedmetadata', () => {
          videoRef.current?.play().then(() => {
            console.log('✅ Camera ready for facingMode:', facingMode);
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
      console.error('❌ Camera error for facingMode:', facingMode, err);
      let errorMessage = 'Không thể khởi động camera';
      if (err.name === 'NotReadableError') {
        errorMessage = 'Camera đang được sử dụng. Vui lòng đóng ứng dụng khác và thử lại';
      }
      
      setError(errorMessage);
      setIsLoading(false);
      if (onError) onError(errorMessage);
    }
  }, [isActive, facingMode, onError, onReady]);

  // Effect for camera lifecycle
  useEffect(() => {
    if (isActive) {
      startCamera();
    } else {
      stopCamera();
    }

    return () => {
      stopCamera();
    };
  }, [isActive, startCamera, stopCamera]);

  // Effect for facingMode changes
  useEffect(() => {
    if (isActive) {
      startCamera();
    }
  }, [facingMode, startCamera]);

  if (error) {
    return (
      <div className={`flex items-center justify-center w-full h-full bg-gray-900 text-white rounded-lg ${className}`}>
        <div className="text-center p-4">
          <p className="text-red-500 mb-2 text-4xl">📷</p>
          <p className="text-sm font-medium mb-2">{error}</p>
          <button
            onClick={() => {
              setError(null);
              if (isActive) startCamera();
            }}
            className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 text-sm"
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
          <div className="text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto mb-2"></div>
            <p className="text-sm">Đang khởi động camera...</p>
          </div>
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

export default SimpleCamera;
