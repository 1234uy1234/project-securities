import React, { useState, useRef, useCallback, useEffect } from 'react';
import { X, Camera, AlertCircle, CheckCircle, Loader } from 'lucide-react';

interface SimpleFaceAuthModalNewProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: (userData: any) => void;
  mode: 'register' | 'verify';
  username?: string;
  onRegisterSuccess?: () => void;
}

const SimpleFaceAuthModalNew: React.FC<SimpleFaceAuthModalNewProps> = ({
  isOpen,
  onClose,
  onSuccess,
  mode,
  username,
  onRegisterSuccess
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [isCapturing, setIsCapturing] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [cameraReady, setCameraReady] = useState(false);

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      setCameraReady(false);
      console.log('🎥 Starting face auth camera...');
      
      // Stop existing stream first
      if (stream) {
        stream.getTracks().forEach(track => {
          track.stop();
          console.log('🛑 Stopped existing face auth track');
        });
        setStream(null);
      }
      
      // Lấy camera stream cho face auth directly
      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'user', // Camera trước cho face auth
          width: { ideal: 640 },
          height: { ideal: 480 }
        }
      });
      
      setStream(mediaStream);
      
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        
        // Wait for video to be ready
        await new Promise((resolve, reject) => {
          if (videoRef.current) {
            videoRef.current.onloadedmetadata = () => {
              if (videoRef.current) {
                videoRef.current.play().then(() => {
                  console.log('✅ Face auth video started playing');
                  setCameraReady(true);
                  resolve(true);
                }).catch(reject);
              }
            };
          }
        });
      }
    } catch (e: any) {
      setError('Lỗi bật camera: ' + e.message);
      console.error('❌ Error starting face auth camera:', e);
    }
  }, [stream]);

  const stopCamera = useCallback(() => {
    console.log('🛑 Stopping face auth camera...');
    
    if (stream) {
      stream.getTracks().forEach(track => {
        console.log(`🛑 Stopping track: ${track.kind} - ${track.label}`);
        track.stop();
      });
      setStream(null);
    }
    
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    
    setCameraReady(false);
    console.log('📱 Face Auth: Stop camera đơn giản');
  }, [stream]);

  const capturePhoto = useCallback(async () => {
    if (!videoRef.current || !canvasRef.current || !cameraReady) {
      setError('Camera chưa sẵn sàng');
      return;
    }

    setIsCapturing(true);
    setError(null);

    try {
      const video = videoRef.current;
      const canvas = canvasRef.current;
      const context = canvas.getContext('2d');

      if (!context) {
        throw new Error('Không thể lấy canvas context');
      }

      // Set canvas size to match video
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;

      // Draw video frame to canvas
      context.drawImage(video, 0, 0, canvas.width, canvas.height);

      // Convert to blob
      const blob = await new Promise<Blob>((resolve) => {
        canvas.toBlob((blob) => {
          if (blob) resolve(blob);
        }, 'image/jpeg', 0.8);
      });

      // Convert to base64 for API
      const base64 = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onload = () => {
          const result = reader.result as string;
          resolve(result.split(',')[1]); // Remove data:image/jpeg;base64, prefix
        };
        reader.readAsDataURL(blob);
      });

      setIsProcessing(true);

      // Call API based on mode
      const endpoint = mode === 'register' ? '/api/face-auth/register' : '/api/face-auth/verify';
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          image: base64,
          username: username
        })
      });

      const result = await response.json();

      if (response.ok) {
        setSuccess(result.message || 'Thành công!');
        onSuccess(result);
        
        if (mode === 'register' && onRegisterSuccess) {
          onRegisterSuccess();
        }
      } else {
        setError(result.detail || 'Lỗi xử lý ảnh');
      }
    } catch (err: any) {
      setError('Lỗi chụp ảnh: ' + err.message);
      console.error('❌ Error capturing photo:', err);
    } finally {
      setIsCapturing(false);
      setIsProcessing(false);
    }
  }, [cameraReady, mode, username, onSuccess, onRegisterSuccess]);

  // Start camera when modal opens
  useEffect(() => {
    if (isOpen) {
      startCamera();
    } else {
      stopCamera();
    }
    
    return () => {
      stopCamera();
    };
  }, [isOpen, startCamera, stopCamera]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-md w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b">
          <h2 className="text-lg font-semibold">
            {mode === 'register' ? 'Đăng ký khuôn mặt' : 'Xác thực khuôn mặt'}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4">
          {/* Video Preview */}
          <div className="relative mb-4">
            <video
              ref={videoRef}
              className="w-full h-64 bg-gray-200 rounded-lg"
              playsInline
              muted
              autoPlay
            />
            
            {error && (
              <div className="absolute top-2 left-2 right-2 bg-red-500 text-white p-2 rounded text-sm">
                {error}
              </div>
            )}
            
            {cameraReady && (
              <div className="absolute top-2 right-2 bg-green-500 text-white p-2 rounded text-sm">
                Camera sẵn sàng
              </div>
            )}
            
            {success && (
              <div className="absolute top-2 left-2 right-2 bg-green-500 text-white p-2 rounded text-sm">
                {success}
              </div>
            )}
          </div>

          {/* Hidden canvas for photo capture */}
          <canvas ref={canvasRef} className="hidden" />

          {/* Instructions */}
          <div className="mb-4 text-center">
            <p className="text-gray-600 text-sm">
              {mode === 'register' 
                ? 'Nhấn "Chụp ảnh" để đăng ký khuôn mặt'
                : 'Nhấn "Chụp ảnh" để xác thực khuôn mặt'
              }
            </p>
          </div>

          {/* Buttons */}
          <div className="flex space-x-3">
            <button
              onClick={capturePhoto}
              disabled={!cameraReady || isCapturing || isProcessing}
              className="flex-1 bg-blue-500 hover:bg-blue-600 disabled:bg-gray-300 text-white py-2 px-4 rounded-lg flex items-center justify-center space-x-2"
            >
              {isCapturing || isProcessing ? (
                <>
                  <Loader className="w-4 h-4 animate-spin" />
                  <span>{isProcessing ? 'Đang xử lý...' : 'Đang chụp...'}</span>
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
              className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
            >
              Đóng
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SimpleFaceAuthModalNew;
