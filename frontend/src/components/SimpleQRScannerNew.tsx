import React, { useRef, useEffect, useState, useCallback } from 'react';
import { BrowserMultiFormatReader } from '@zxing/browser';

interface SimpleQRScannerNewProps {
  onScan: (result: string) => void;
  onError?: (error: string) => void;
  isActive: boolean;
}

const SimpleQRScannerNew: React.FC<SimpleQRScannerNewProps> = ({ onScan, onError, isActive }) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const codeReaderRef = useRef<BrowserMultiFormatReader | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const [isScanning, setIsScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [cameraReady, setCameraReady] = useState(false);

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      setCameraReady(false);
      console.log('🎥 Starting QR camera...');
      
      // Stop existing stream first
      if (streamRef.current) {
        streamRef.current.getTracks().forEach(track => {
          track.stop();
          console.log('🛑 Stopped existing QR track');
        });
        streamRef.current = null;
      }
      
      // Get camera stream directly
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'environment',
          width: { ideal: 1280 },
          height: { ideal: 720 }
        }
      });
      streamRef.current = stream;
      
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        
        // Wait for video to be ready
        await new Promise((resolve, reject) => {
          if (videoRef.current) {
            videoRef.current.onloadedmetadata = () => {
              if (videoRef.current) {
                videoRef.current.play().then(() => {
                  console.log('✅ Video started playing');
                  setCameraReady(true);
                  resolve(true);
                }).catch(reject);
              }
            };
          }
        });
      }
    } catch (err: any) {
      console.error('❌ Camera error:', err);
      const errorMsg = err.name === 'NotAllowedError'
        ? 'Camera bị từ chối. Vui lòng cho phép truy cập camera.'
        : err.name === 'NotFoundError'
        ? 'Không tìm thấy camera'
        : 'Lỗi camera: ' + err.message;
      
      setError(errorMsg);
      onError?.(errorMsg);
    }
  }, [onError]);

  const startQRScan = useCallback(() => {
    if (!videoRef.current || !cameraReady) {
      console.log('❌ Cannot start QR scan: video not ready');
      return;
    }
    
    try {
      console.log('🔍 Starting QR scan...');
      
      const codeReader = new BrowserMultiFormatReader();
      codeReaderRef.current = codeReader;
      setIsScanning(true);
      
      // Start scanning
      codeReader.decodeFromVideoElement(
        videoRef.current,
        (result, err) => {
          if (result) {
            console.log('✅ QR Code detected:', result.getText());
            setIsScanning(false);
            onScan(result.getText());
          }
          
          if (err && !(err instanceof Error && err.name === 'NotFoundException')) {
            console.log('⚠️ QR scan error:', err);
          }
        }
      );
    } catch (error) {
      console.error('❌ Error starting QR scan:', error);
      setError('Lỗi khởi tạo QR scanner: ' + (error as Error).message);
      onError?.('Lỗi khởi tạo QR scanner: ' + (error as Error).message);
    }
  }, [cameraReady, onScan]);

  const stopScanning = useCallback(() => {
    console.log('🛑 Stopping QR scan...');
    
    if (codeReaderRef.current) {
      try {
        (codeReaderRef.current as any).reset();
      } catch (e) {
        console.log('⚠️ Error resetting code reader:', e);
      }
      codeReaderRef.current = null;
    }
    
    setIsScanning(false);
    console.log('✅ QR scan stopped');
  }, []);

  const stopCamera = useCallback(() => {
    console.log('🛑 Stopping camera...');
    
    stopScanning();
    
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => {
        track.stop();
        console.log('🛑 Stopped QR track');
      });
      streamRef.current = null;
    }
    
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    
    setCameraReady(false);
    console.log('✅ Camera stopped');
  }, [stopScanning]);

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

  // Auto start scanning when camera is ready
  useEffect(() => {
    if (cameraReady && !isScanning) {
      startQRScan();
    }
  }, [cameraReady, isScanning, startQRScan]);

  return (
    <div className="relative w-full max-w-md mx-auto">
      <video
        ref={videoRef}
        className="w-full h-64 bg-black rounded-lg"
        playsInline
        muted
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
      
      {isScanning && (
        <div className="absolute bottom-2 left-2 right-2 bg-blue-500 text-white p-2 rounded text-sm text-center">
          Đang quét QR...
        </div>
      )}
    </div>
  );
};

export default SimpleQRScannerNew;














