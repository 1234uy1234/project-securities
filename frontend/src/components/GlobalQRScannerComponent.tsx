import React, { useRef, useEffect, useState, useCallback } from 'react';
import GlobalQRScanner from '../utils/GlobalQRScanner';

interface GlobalQRScannerComponentProps {
  onScan: (result: string) => void;
  onError?: (error: string) => void;
  isActive: boolean;
}

const GlobalQRScannerComponent: React.FC<GlobalQRScannerComponentProps> = ({ 
  onScan, 
  onError, 
  isActive 
}) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isScanning, setIsScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [cameraReady, setCameraReady] = useState(false);
  const globalQRScanner = GlobalQRScanner.getInstance();

  const startScanning = useCallback(async () => {
    if (!videoRef.current) return;

    try {
      setError(null);
      setCameraReady(false);
      setIsScanning(true);

      console.log('🎥 Starting Global QR Scanner...');

      await globalQRScanner.startScanning(
        videoRef.current,
        (result) => {
          console.log('✅ QR Code detected:', result);
          setIsScanning(false);
          setCameraReady(false);
          onScan(result);
        },
        (error) => {
          console.error('❌ QR Scanner error:', error);
          setError(error);
          setIsScanning(false);
          setCameraReady(false);
          onError?.(error);
        }
      );

      setCameraReady(true);
      console.log('✅ Global QR Scanner started successfully');

    } catch (err: any) {
      console.error('❌ Error starting Global QR Scanner:', err);
      setError('Lỗi khởi tạo QR scanner: ' + err.message);
      setIsScanning(false);
      setCameraReady(false);
      onError?.('Lỗi khởi tạo QR scanner: ' + err.message);
    }
  }, [onScan, onError, globalQRScanner]);

  const stopScanning = useCallback(() => {
    console.log('🛑 Stopping Global QR Scanner...');
    globalQRScanner.stopScanning();
    setIsScanning(false);
    setCameraReady(false);
    setError(null);
  }, [globalQRScanner]);

  useEffect(() => {
    if (isActive) {
      startScanning();
    } else {
      stopScanning();
    }
    
    return () => {
      stopScanning();
    };
  }, [isActive, startScanning, stopScanning]);

  return (
    <div className="relative w-full max-w-md mx-auto">
      <video
        ref={videoRef}
        className="w-full h-64 bg-black rounded-lg"
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
      
      {isScanning && (
        <div className="absolute bottom-2 left-2 right-2 bg-blue-500 text-white p-2 rounded text-sm text-center">
          Đang quét QR...
        </div>
      )}
      
      {!isScanning && !cameraReady && (
        <div className="absolute bottom-2 left-2 right-2 bg-gray-500 text-white p-2 rounded text-sm text-center">
          Nhấn để bắt đầu quét
        </div>
      )}
    </div>
  );
};

export default GlobalQRScannerComponent;














