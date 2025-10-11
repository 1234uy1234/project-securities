import { useState, useCallback, useRef, useEffect } from 'react';
import CameraManager from '../utils/cameraManager';

export interface UseCameraOptions {
  type: 'qr' | 'photo' | 'face';
  autoStart?: boolean;
  timeout?: number;
}

export interface UseCameraReturn {
  stream: MediaStream | null;
  videoRef: React.RefObject<HTMLVideoElement>;
  isActive: boolean;
  isInitializing: boolean;
  error: string | null;
  startCamera: () => Promise<void>;
  stopCamera: () => Promise<void>;
  switchCamera: () => Promise<void>;
  capturePhoto: () => string | null;
}

export const useCamera = (options: UseCameraOptions): UseCameraReturn => {
  const { type, autoStart = false, timeout = 15000 } = options; // Tăng timeout cho mobile
  
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [isActive, setIsActive] = useState(false);
  const [isInitializing, setIsInitializing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [facingMode, setFacingMode] = useState<'user' | 'environment'>(
    type === 'qr' ? 'environment' : 'user'
  );
  
  const videoRef = useRef<HTMLVideoElement>(null);
  const cameraManager = CameraManager.getInstance();
  const streamId = `camera-${type}-${facingMode}`;

  const startCamera = useCallback(async () => {
    if (isActive || isInitializing) {
      console.log('Camera already active or initializing');
      return;
    }

    try {
      setIsInitializing(true);
      setError(null);
      
      console.log(`🎥 Starting camera: ${type} (${facingMode})`);
      
      // Kiểm tra permissions
      const permissions = await cameraManager.checkPermissions();
      if (permissions.camera === 'denied') {
        throw new Error('Camera permission denied');
      }
      
      // Dừng tất cả streams trước
      await cameraManager.stopAllStreams();
      
      // Đợi lâu hơn cho mobile
      const waitTime = cameraManager.isMobileDevice() ? 1000 : 500;
      await new Promise(resolve => setTimeout(resolve, waitTime));
      
      // Lấy constraints tối ưu
      const constraints = cameraManager.getOptimizedConstraints(type);
      
      // Override facingMode nếu cần
      if (constraints.video && typeof constraints.video === 'object') {
        (constraints.video as any).facingMode = facingMode;
      }
      
      // Lấy stream
      const newStream = await cameraManager.getStream(streamId, constraints);
      setStream(newStream);
      
      // Setup video element
      if (videoRef.current) {
        videoRef.current.srcObject = newStream;
        
        const video = videoRef.current;
        const handleLoadedMetadata = () => {
          video.play()
            .then(() => {
              console.log(`✅ Camera ready: ${type} (${facingMode})`);
              setIsActive(true);
              setIsInitializing(false);
            })
            .catch((err) => {
              console.error('Video play error:', err);
              setError('Không thể phát video. Vui lòng thử lại.');
              setIsInitializing(false);
            });
        };

        video.addEventListener('loadedmetadata', handleLoadedMetadata, { once: true });
        
        // Timeout để tránh camera bị treo
        const timeoutId = setTimeout(() => {
          if (isInitializing) {
            console.log('⏰ Camera timeout');
            setError('Camera khởi động quá lâu. Vui lòng thử lại.');
            setIsInitializing(false);
            stopCamera();
          }
        }, timeout);
        
        // Cleanup timeout khi camera ready
        video.addEventListener('loadedmetadata', () => {
          clearTimeout(timeoutId);
        }, { once: true });
      }
      
    } catch (err: any) {
      console.error('Camera error:', err);
      
      // Error messages tối ưu cho mobile
      if (err.name === 'NotAllowedError') {
        setError('Camera bị từ chối. Vui lòng cho phép camera và thử lại.');
      } else if (err.name === 'NotFoundError') {
        setError('Không tìm thấy camera. Vui lòng kiểm tra thiết bị.');
      } else if (err.name === 'NotReadableError') {
        setError('Camera đang được sử dụng. Vui lòng đóng các ứng dụng khác.');
      } else if (err.name === 'OverconstrainedError') {
        setError('Camera không hỗ trợ độ phân giải này. Vui lòng thử lại.');
      } else if (err.message === 'Camera permission denied') {
        setError('Camera bị từ chối. Vui lòng cho phép camera trong cài đặt trình duyệt.');
      } else {
        setError(err.message || 'Không thể khởi động camera. Vui lòng thử lại.');
      }
      
      setIsInitializing(false);
    }
  }, [type, facingMode, isActive, isInitializing, cameraManager, streamId, timeout]);

  const stopCamera = useCallback(async () => {
    if (!isActive && !isInitializing) {
      return;
    }

    try {
      console.log(`🛑 Stopping camera: ${type}`);
      
      await cameraManager.stopStream(streamId);
      
      if (videoRef.current) {
        videoRef.current.srcObject = null;
      }
      
      setStream(null);
      setIsActive(false);
      setIsInitializing(false);
      setError(null);
      
      console.log(`✅ Camera stopped: ${type}`);
    } catch (err) {
      console.error('Stop camera error:', err);
    }
  }, [type, isActive, isInitializing, cameraManager, streamId]);

  const switchCamera = useCallback(async () => {
    const newFacingMode = facingMode === 'user' ? 'environment' : 'user';
    setFacingMode(newFacingMode);
    
    // Restart camera với facingMode mới
    await stopCamera();
    await new Promise(resolve => setTimeout(resolve, 500));
    await startCamera();
  }, [facingMode, stopCamera, startCamera]);

  const capturePhoto = useCallback((): string | null => {
    if (!videoRef.current || !isActive) {
      return null;
    }

    try {
      const video = videoRef.current;
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      
      if (!ctx) return null;
      
      // Set canvas size
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      
      // Draw video frame
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
      
      // Add timestamp overlay
      ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
      ctx.fillRect(10, canvas.height - 40, 200, 30);
      
      ctx.fillStyle = 'white';
      ctx.font = '14px Arial';
      ctx.fillText(
        new Date().toLocaleString('vi-VN'),
        15,
        canvas.height - 20
      );
      
      return canvas.toDataURL('image/jpeg', 0.9);
    } catch (err) {
      console.error('Capture photo error:', err);
      return null;
    }
  }, [isActive]);

  // Auto start camera
  useEffect(() => {
    if (autoStart) {
      startCamera();
    }
    
    // Cleanup on unmount
    return () => {
      stopCamera();
    };
  }, [autoStart, startCamera, stopCamera]);

  return {
    stream,
    videoRef,
    isActive,
    isInitializing,
    error,
    startCamera,
    stopCamera,
    switchCamera,
    capturePhoto
  };
};
