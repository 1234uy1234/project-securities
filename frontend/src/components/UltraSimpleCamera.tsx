import React, { useRef, useEffect, useState } from 'react';

interface UltraSimpleCameraProps {
  isActive: boolean;
  onError?: (error: string) => void;
  onReady?: () => void;
  className?: string;
  facingMode?: 'user' | 'environment';
}

const UltraSimpleCamera: React.FC<UltraSimpleCameraProps> = ({
  isActive,
  onError,
  onReady,
  className = '',
  facingMode = 'user'
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    let stream: MediaStream | null = null;

    const startCamera = async () => {
      if (!isActive) return;

      setIsLoading(true);
      setError(null);

      try {
        // Stop any existing streams first
        if (videoRef.current && videoRef.current.srcObject) {
          const existingStream = videoRef.current.srcObject as MediaStream;
          existingStream.getTracks().forEach(track => track.stop());
          videoRef.current.srcObject = null;
        }

        // Wait a bit for cleanup
        await new Promise(resolve => setTimeout(resolve, 500));

        // Get new stream
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode },
          audio: false
        });

        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          
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
        }
        setError(errorMessage);
        setIsLoading(false);
        if (onError) onError(errorMessage);
      }
    };

    const stopCamera = () => {
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
        stream = null;
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
                // Trigger re-render by changing a state
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

export default UltraSimpleCamera;
