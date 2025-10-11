#!/bin/bash

echo "🔧 TẠO COMPONENT SCANCAMERA CHUYÊN NGHIỆP VỚI VIEWFINDER VÀ VẠCH QUÉT"
echo "=================================================================="

# Create ScanCamera component
echo "📱 Creating ScanCamera component..."
cat > /Users/maybe/Documents/shopee/frontend/src/components/ScanCamera.tsx << 'EOF'
import React, { useRef, useEffect, useState, useCallback } from 'react';
import jsQR from 'jsqr';

interface ScanCameraProps {
  onDecode: (text: string) => void;
  onError?: (error: string) => void;
  isActive: boolean;
}

const ScanCamera: React.FC<ScanCameraProps> = ({ onDecode, onError, isActive }) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const animationRef = useRef<number | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isScanning, setIsScanning] = useState(false);

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      console.log('🎥 Starting camera...');
      
      // Stop existing stream
      if (streamRef.current) {
        streamRef.current.getTracks().forEach(track => track.stop());
        streamRef.current = null;
      }

      // Wait a bit to ensure previous stream is fully stopped
      await new Promise(resolve => setTimeout(resolve, 500));

      // Get camera stream
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'environment',
          width: { ideal: 1280, min: 640 },
          height: { ideal: 720, min: 480 },
          frameRate: { ideal: 30, max: 30 }
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
                  console.log('✅ Camera ready');
                  setIsScanning(true);
                  startScanning();
                  resolve(true);
                }).catch(reject);
              }
            };
            
            videoRef.current.onerror = reject;
          }
        });
      }
    } catch (err: any) {
      console.error('❌ Camera error:', err);
      const errorMsg = err.name === 'NotAllowedError' 
        ? 'Quyền truy cập camera bị từ chối'
        : err.name === 'NotFoundError'
        ? 'Không tìm thấy camera'
        : 'Lỗi camera: ' + err.message;
      
      setError(errorMsg);
      onError?.(errorMsg);
    }
  }, [onError]);

  const startScanning = useCallback(() => {
    if (!videoRef.current || !canvasRef.current || !isScanning) return;

    const video = videoRef.current;
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');

    if (!ctx) return;

    const scan = () => {
      if (video.readyState === video.HAVE_ENOUGH_DATA) {
        // Set canvas size to match video
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;

        // Draw video frame to canvas
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

        // Get image data
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

        // Calculate ROI (Region of Interest) - center 60% of width
        const roiWidth = Math.floor(canvas.width * 0.6);
        const roiHeight = Math.floor(canvas.height * 0.6);
        const roiX = Math.floor((canvas.width - roiWidth) / 2);
        const roiY = Math.floor((canvas.height - roiHeight) / 2);

        // Crop to ROI
        const roiImageData = ctx.getImageData(roiX, roiY, roiWidth, roiHeight);

        // Decode QR code
        const code = jsQR(roiImageData.data, roiWidth, roiHeight);

        if (code) {
          console.log('✅ QR Code detected:', code.data);
          setIsScanning(false);
          onDecode(code.data);
          return;
        }
      }

      // Continue scanning
      if (isScanning) {
        animationRef.current = requestAnimationFrame(scan);
      }
    };

    scan();
  }, [isScanning, onDecode]);

  const stopCamera = useCallback(() => {
    setIsScanning(false);
    
    if (animationRef.current) {
      cancelAnimationFrame(animationRef.current);
      animationRef.current = null;
    }
    
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => track.stop());
      streamRef.current = null;
    }
    
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
  }, []);

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

  return (
    <div className="relative w-full h-full bg-black">
      {/* Video */}
      <video
        ref={videoRef}
        className="w-full h-full object-cover"
        playsInline
        muted
        autoPlay
        style={{
          filter: 'brightness(1.1) contrast(1.1)',
        }}
      />
      
      {/* Viewfinder Overlay */}
      <div className="absolute inset-0 pointer-events-none">
        {/* Dark overlay */}
        <div className="absolute inset-0 bg-black bg-opacity-50"></div>
        
        {/* Viewfinder square - 60% width, centered */}
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-3/5 aspect-square">
          {/* Transparent center */}
          <div className="absolute inset-0 bg-transparent"></div>
          
          {/* White border */}
          <div className="absolute inset-0 border-2 border-white rounded-lg"></div>
          
          {/* Corner brackets */}
          <div className="absolute -top-1 -left-1 w-8 h-8">
            <div className="absolute top-0 left-0 w-6 h-1 bg-white rounded-sm"></div>
            <div className="absolute top-0 left-0 w-1 h-6 bg-white rounded-sm"></div>
          </div>
          
          <div className="absolute -top-1 -right-1 w-8 h-8">
            <div className="absolute top-0 right-0 w-6 h-1 bg-white rounded-sm"></div>
            <div className="absolute top-0 right-0 w-1 h-6 bg-white rounded-sm"></div>
          </div>
          
          <div className="absolute -bottom-1 -left-1 w-8 h-8">
            <div className="absolute bottom-0 left-0 w-6 h-1 bg-white rounded-sm"></div>
            <div className="absolute bottom-0 left-0 w-1 h-6 bg-white rounded-sm"></div>
          </div>
          
          <div className="absolute -bottom-1 -right-1 w-8 h-8">
            <div className="absolute bottom-0 right-0 w-6 h-1 bg-white rounded-sm"></div>
            <div className="absolute bottom-0 right-0 w-1 h-6 bg-white rounded-sm"></div>
          </div>
          
          {/* Scanning line animation */}
          <div className="absolute inset-0 overflow-hidden rounded-lg">
            <div className="scanning-line"></div>
          </div>
        </div>
      </div>
      
      {/* Instructions */}
      <div className="absolute top-4 left-4 right-4 text-center">
        <div className="bg-black bg-opacity-75 text-white px-4 py-2 rounded-lg">
          <p className="text-sm font-medium">📱 Đưa mã QR vào khung vuông</p>
          <p className="text-xs text-gray-300">Camera sẽ tự động quét và nhận diện</p>
        </div>
      </div>
      
      {/* Error */}
      {error && (
        <div className="absolute bottom-4 left-4 right-4 bg-red-500 text-white p-3 rounded-lg text-sm">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-white rounded-full animate-pulse"></div>
            <span>{error}</span>
          </div>
        </div>
      )}
      
      {/* Hidden canvas for QR detection */}
      <canvas ref={canvasRef} className="hidden" />
      
      {/* CSS Animation */}
      <style jsx>{`
        @keyframes scan {
          0% {
            transform: translateY(-100%);
          }
          100% {
            transform: translateY(100%);
          }
        }
        
        .scanning-line {
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 2px;
          background: linear-gradient(90deg, transparent, #10b981, transparent);
          animation: scan 2s linear infinite;
          box-shadow: 0 0 10px #10b981;
        }
      `}</style>
    </div>
  );
};

export default ScanCamera;
EOF

# Install jsQR if not already installed
echo "📦 Installing jsQR..."
cd /Users/maybe/Documents/shopee/frontend
npm install jsqr @types/jsqr --save

# Update QRScannerPage to use ScanCamera
echo "🔧 Updating QRScannerPage to use ScanCamera..."
cat > /Users/maybe/Documents/shopee/frontend/src/pages/QRScannerPage.tsx << 'EOF'
import React, { useEffect, useRef, useState } from 'react'
import { BrowserMultiFormatReader, IScannerControls } from '@zxing/browser'
import Webcam from 'react-webcam'
import { useNavigate, useSearchParams } from 'react-router-dom'
import toast from 'react-hot-toast'
import { api } from '../utils/api'
import { getCurrentPosition } from '../utils/geo'
import { enqueueScan, flushQueue, setupOnlineSync } from '../utils/offlineQueue'
import { useAuthStore } from '../stores/authStore'
import ScanCamera from '../components/ScanCamera'

const QRScannerPage = () => {
  const navigate = useNavigate()
  const photoWebcamRef = useRef<Webcam | null>(null) // Camera riêng cho chụp ảnh
  const [photoCameraActive, setPhotoCameraActive] = useState(false) // Camera chụp ảnh
  const [photoWebcamError, setPhotoWebcamError] = useState<string | null>(null)
  const [lastResult, setLastResult] = useState<string>('')
  const [notes, setNotes] = useState('')
  const [capturedPhoto, setCapturedPhoto] = useState<string | null>(null)
  const [photoFacingMode, setPhotoFacingMode] = useState<'user' | 'environment'>('environment')
  
  // Thông tin nhiệm vụ từ QR scan
  const [currentLocation, setCurrentLocation] = useState<any>(null)
  const [currentTasks, setCurrentTasks] = useState<any[]>([])
  const [showTaskInfo, setShowTaskInfo] = useState(false)
  
  // Lấy ref từ URL params
  const [searchParams] = useSearchParams()
  const ref = searchParams.get('ref')
  
  // State để lưu QR content đã quét
  const [scannedQRContent, setScannedQRContent] = useState<string | null>(null)

  // Bật camera chụp ảnh
  const enablePhotoCamera = async () => {
    try {
      setPhotoWebcamError(null)
      setPhotoCameraActive(true)
      console.log('Photo Camera enabled')
    } catch (err: any) {
      console.error('Photo Camera error:', err)
      setPhotoWebcamError(err.message)
      setPhotoCameraActive(false)
    }
  }

  // Tắt camera chụp ảnh
  const disablePhotoCamera = () => {
    setPhotoCameraActive(false)
    setPhotoWebcamError(null)
  }

  // Chuyển đổi camera trước/sau cho Photo
  const switchPhotoCamera = () => {
    setPhotoFacingMode(prev => prev === 'environment' ? 'user' : 'environment')
    // Restart camera với facingMode mới
    if (photoCameraActive) {
      setPhotoCameraActive(false)
      setTimeout(() => setPhotoCameraActive(true), 100)
    }
  }

  // Xử lý lỗi camera Photo
  const handlePhotoWebcamError = (err: any) => {
    console.error('Photo Webcam error:', err)
    let errorMessage = 'Lỗi camera chụp ảnh: '
    
    if (err.name === 'NotAllowedError') {
      errorMessage += 'Quyền truy cập bị từ chối'
    } else if (err.name === 'NotFoundError') {
      errorMessage += 'Không tìm thấy camera'
    } else if (err.name === 'NotReadableError') {
      errorMessage += 'Camera đang được sử dụng'
    } else if (err.name === 'NotSupportedError') {
      errorMessage += 'Thiết bị không hỗ trợ'
    } else if (err.name === 'OverconstrainedError') {
      errorMessage += 'Độ phân giải không được hỗ trợ'
    } else {
      errorMessage += err.message || 'Lỗi không xác định'
    }
    
    setPhotoWebcamError(errorMessage)
    setPhotoCameraActive(false)
  }

  // Xử lý kết quả quét QR từ ScanCamera
  const handleQRScan = (result: string) => {
    console.log('QR Code scanned:', result)
    setLastResult(result)
    setScannedQRContent(result)
    
    // Xử lý QR content
    try {
      const qrData = JSON.parse(result)
      console.log('QR Data:', qrData)
      
      if (qrData.type === 'location') {
        setCurrentLocation(qrData)
        toast.success(`Đã quét QR: ${qrData.name}`)
      } else if (qrData.type === 'task') {
        setCurrentTasks([qrData])
        setShowTaskInfo(true)
        toast.success(`Đã quét QR: ${qrData.title}`)
      } else {
        toast.success(`Đã quét QR: ${result}`)
      }
    } catch (e) {
      // QR không phải JSON, xử lý như text thường
      toast.success(`Đã quét QR: ${result}`)
    }
  }

  // Xử lý lỗi quét QR
  const handleQRScanError = (error: string) => {
    console.error('QR Scan error:', error)
    setPhotoWebcamError(error)
  }

  // Chụp ảnh
  const capturePhoto = () => {
    if (photoWebcamRef.current) {
      const imageSrc = photoWebcamRef.current.getScreenshot()
      if (imageSrc) {
        setCapturedPhoto(imageSrc)
        toast.success('Đã chụp ảnh thành công!')
      }
    }
  }

  // Xóa ảnh đã chụp
  const clearPhoto = () => {
    setCapturedPhoto(null)
  }

  // Gửi dữ liệu check-in
  const submitCheckin = async () => {
    if (!scannedQRContent) {
      toast.error('Vui lòng quét QR code trước!')
      return
    }

    try {
      const position = await getCurrentPosition()
      
      const checkinData = {
        qr_content: scannedQRContent,
        notes: notes,
        photo: capturedPhoto,
        gps_latitude: position.latitude,
        gps_longitude: position.longitude,
        timestamp: new Date().toISOString()
      }

      // Gửi dữ liệu
      await api.post('/checkin', checkinData)
      
      toast.success('Check-in thành công!')
      
      // Reset form
      setScannedQRContent(null)
      setNotes('')
      setCapturedPhoto(null)
      setLastResult('')
      
    } catch (error) {
      console.error('Checkin error:', error)
      toast.error('Lỗi check-in: ' + (error as Error).message)
    }
  }

  return (
    <div className="min-h-screen bg-gray-100 p-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="bg-white rounded-lg shadow-md p-4 mb-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-800">Quét QR Code</h1>
            <button
              onClick={() => navigate('/dashboard')}
              className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600"
            >
              ← Quay lại
            </button>
          </div>
        </div>

        {/* QR Scanner - Using ScanCamera */}
        <div className="bg-white rounded-lg shadow-md p-4 mb-4">
          <h2 className="text-lg font-semibold mb-4">Camera Quét QR</h2>
          
          <div className="relative h-96">
            <ScanCamera
              onDecode={handleQRScan}
              onError={handleQRScanError}
              isActive={true}
            />
          </div>
        </div>

        {/* QR Result */}
        {lastResult && (
          <div className="bg-white rounded-lg shadow-md p-4 mb-4">
            <h3 className="text-lg font-semibold mb-2">Kết quả quét QR:</h3>
            <div className="bg-gray-100 p-3 rounded-lg">
              <code className="text-sm">{lastResult}</code>
            </div>
          </div>
        )}

        {/* Task Info */}
        {showTaskInfo && currentTasks.length > 0 && (
          <div className="bg-white rounded-lg shadow-md p-4 mb-4">
            <h3 className="text-lg font-semibold mb-2">Thông tin nhiệm vụ:</h3>
            {currentTasks.map((task, index) => (
              <div key={index} className="border rounded-lg p-3 mb-2">
                <h4 className="font-medium">{task.title}</h4>
                <p className="text-sm text-gray-600">{task.description}</p>
              </div>
            ))}
          </div>
        )}

        {/* Photo Capture */}
        <div className="bg-white rounded-lg shadow-md p-4 mb-4">
          <h2 className="text-lg font-semibold mb-4">Chụp ảnh</h2>
          
          <div className="flex gap-4">
            <div className="flex-1">
              {photoCameraActive ? (
                <div className="relative">
                  <Webcam
                    ref={photoWebcamRef}
                    audio={false}
                    videoConstraints={{
                      width: 640,
                      height: 480,
                      facingMode: photoFacingMode
                    }}
                    onError={handlePhotoWebcamError}
                    className="w-full h-48 object-cover rounded-lg"
                  />
                  
                  <button
                    onClick={capturePhoto}
                    className="absolute bottom-2 right-2 bg-blue-500 text-white p-2 rounded-full hover:bg-blue-600"
                  >
                    📷
                  </button>
                </div>
              ) : (
                <div className="w-full h-48 bg-gray-200 rounded-lg flex items-center justify-center">
                  <button
                    onClick={enablePhotoCamera}
                    className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600"
                  >
                    Bật Camera
                  </button>
                </div>
              )}
            </div>
            
            <div className="flex-1">
              {capturedPhoto ? (
                <div className="relative">
                  <img
                    src={capturedPhoto}
                    alt="Captured"
                    className="w-full h-48 object-cover rounded-lg"
                  />
                  <button
                    onClick={clearPhoto}
                    className="absolute top-2 right-2 bg-red-500 text-white p-1 rounded-full hover:bg-red-600"
                  >
                    ×
                  </button>
                </div>
              ) : (
                <div className="w-full h-48 bg-gray-200 rounded-lg flex items-center justify-center">
                  <span className="text-gray-500">Chưa có ảnh</span>
                </div>
              )}
            </div>
          </div>

          {photoWebcamError && (
            <div className="mt-4 p-3 bg-red-100 text-red-700 rounded-lg">
              {photoWebcamError}
            </div>
          )}

          <div className="mt-4 flex gap-2">
            <button
              onClick={switchPhotoCamera}
              className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
            >
              Chuyển Camera
            </button>
            {photoCameraActive && (
              <button
                onClick={disablePhotoCamera}
                className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
              >
                Tắt Camera
              </button>
            )}
          </div>
        </div>

        {/* Notes */}
        <div className="bg-white rounded-lg shadow-md p-4 mb-4">
          <h2 className="text-lg font-semibold mb-2">Ghi chú</h2>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Nhập ghi chú..."
            className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            rows={3}
          />
        </div>

        {/* Submit */}
        <div className="bg-white rounded-lg shadow-md p-4">
          <button
            onClick={submitCheckin}
            className="w-full px-6 py-3 bg-green-500 text-white rounded-lg hover:bg-green-600 font-medium"
          >
            Gửi Check-in
          </button>
        </div>
      </div>
    </div>
  )
}

export default QRScannerPage
EOF

echo "✅ ScanCamera component created successfully!"
echo "🎥 Features:"
echo "   - Full screen video with camera"
echo "   - 60% width viewfinder square in center"
echo "   - White border with corner brackets"
echo "   - Animated green scanning line"
echo "   - Hidden canvas for ROI cropping"
echo "   - jsQR library for QR detection"
echo "   - Professional look and feel"
echo ""
echo "📦 Dependencies installed: jsqr, @types/jsqr"
echo "🔧 QRScannerPage updated to use ScanCamera"
