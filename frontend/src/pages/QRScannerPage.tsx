import React, { useEffect, useRef, useState } from 'react'
import { BrowserMultiFormatReader, IScannerControls } from '@zxing/browser'
import { useNavigate, useSearchParams } from 'react-router-dom'
import toast from 'react-hot-toast'
import { api } from '../utils/api'
import { getCurrentPosition } from '../utils/geo'
import { enqueueScan, flushQueue, setupOnlineSync } from '../utils/offlineQueue'
import { useAuthStore } from '../stores/authStore'
import FinalCamera from '../components/FinalCamera'
import CameraManager from '../utils/cameraManager'

const QRScannerPage = () => {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const { user } = useAuthStore()
  
  // Lấy parameters từ employee dashboard
  const taskId = searchParams.get('task_id')
  const stopId = searchParams.get('stop_id')
  const locationId = searchParams.get('location_id')
  
  const scannerRef = useRef<BrowserMultiFormatReader | null>(null)
  const controlsRef = useRef<IScannerControls | null>(null) // Thêm ref để lưu IScannerControls
  const videoRef = useRef<HTMLVideoElement>(null) // Thêm ref cho video element
  const [isCameraActive, setIsCameraActive] = useState(false)
  const [photoCameraActive, setPhotoCameraActive] = useState(false)
  const [photoWebcamError, setPhotoWebcamError] = useState<string | null>(null)
  const [isInitializingCamera, setIsInitializingCamera] = useState(false)
  const [lastResult, setLastResult] = useState<string>('')
  const [notes, setNotes] = useState('')
  const [capturedPhoto, setCapturedPhoto] = useState<string | null>(null)
  const [photoFacingMode, setPhotoFacingMode] = useState<'user' | 'environment'>('user') // Chỉ dùng selfie
  
  // Flow steps và status
  const [currentStep, setCurrentStep] = useState<'scan' | 'photo' | 'submit' | 'success'>('scan')
  const [isSubmitting, setIsSubmitting] = useState(false)
  
  // Location info
  const [locationInfo, setLocationInfo] = useState<any>(null)
  const [scannedQRContent, setScannedQRContent] = useState<string | null>(null)
  
  // Bắt đầu quét QR
  const startQRScanner = async () => {
    try {
      if (!scannerRef.current) {
        scannerRef.current = new BrowserMultiFormatReader()
      }
      
      // Đảm bảo video element đã sẵn sàng
      if (!videoRef.current) {
        console.error('🎥 Video element for QR scanner not found.')
        toast.error('Lỗi: Không tìm thấy phần tử video cho QR Scanner.')
        return
      }

      console.log('🎥 Starting QR scanner with camera...')

      // Lấy danh sách các thiết bị video
      const videoInputDevices = await BrowserMultiFormatReader.listVideoInputDevices()
      let selectedDeviceId: string | undefined

      // Tìm camera sau (environment)
      const environmentCamera = videoInputDevices.find(device => 
        device.label.toLowerCase().includes('back') || device.label.toLowerCase().includes('environment')
      )

      if (environmentCamera) {
        selectedDeviceId = environmentCamera.deviceId
        console.log('✅ Found environment camera:', environmentCamera.label)
      } else if (videoInputDevices.length > 0) {
        // Nếu không tìm thấy camera sau, dùng thiết bị đầu tiên
        selectedDeviceId = videoInputDevices[0].deviceId
        console.warn('⚠️ Environment camera not found, using first available camera:', videoInputDevices[0].label)
      } else {
        toast.error('Không tìm thấy thiết bị camera nào.')
        console.error('❌ No video input devices found.')
        return
      }
      
      // SỬA: Dùng deviceId của camera sau và truyền video element
      const controls = await scannerRef.current.decodeFromVideoDevice(
        selectedDeviceId, // Truyền deviceId đã chọn
        videoRef.current, // Truyền trực tiếp video element
        (result: any, err: any) => {
          if (result && !lastResult) { // Chỉ xử lý nếu chưa có kết quả
            console.log('✅ QR Code detected:', result.getText())
            
            // DỪNG CAMERA NGAY LẬP TỨC
            if (controlsRef.current) { // Dùng controlsRef để dừng
              controlsRef.current.stop()
              console.log('🛑 Camera stopped after QR detection')
            }
            
            // Xử lý QR code
            handleQRScan(result.getText())
          }
          
          if (err && !(err instanceof Error && err.name === 'NotFoundException')) {
            console.log('⚠️ QR scan error:', err)
          }
        }
      )
      
      controlsRef.current = controls // Lưu controls để có thể dừng sau này
      console.log('✅ QR scanner started successfully')
      
      // Hiển thị thông báo nếu vào từ employee dashboard
      if (taskId && stopId && locationId) {
        toast.success('📷 Đã vào chế độ chấm công. Quét QR code tại vị trí được giao!')
      }
    } catch (error) {
      console.error('QR Scanner error:', error)
      toast.error('Không thể khởi động QR Scanner')
    }
  }

  // Xử lý kết quả quét QR - TỐI ƯU HÓA ĐỂ GIẢM DELAY
  const handleQRScan = async (qrText: string) => {
    // Nếu đã quét rồi thì không quét nữa
    if (lastResult) {
      return
    }
    
    console.log('QR Code scanned:', qrText)
    setLastResult(qrText)
    
    // DỪNG SCANNER NGAY LẬP TỨC ĐỂ TRÁNH DELAY
    if (controlsRef.current) {
      try {
        controlsRef.current.stop()
        console.log('🛑 QR Scanner stopped immediately after scan')
      } catch (e) {
        console.log('Scanner stopped')
      } finally {
        controlsRef.current = null
      }
    }
    
    try {
      // Kiểm tra QR code có hợp lệ không
      const qrResponse = await api.get(`/qr-codes/validate/${encodeURIComponent(qrText)}`)
      const qrData = qrResponse.data
      
      if (!qrData || !qrData.valid) {
        // HIỂN THỊ MÃ KHÔNG HỢP LỆ NGAY LẬP TỨC
        setLastResult('') // Reset để có thể quét lại
        setScannedQRContent(null)
        setLocationInfo(null)
        toast.error(`❌ Mã không hợp lệ: ${qrText}`)
        return
      }
      
      setScannedQRContent(qrText)
      
      // Hiển thị thông tin vị trí
      const locationData = {
        name: qrData.content || qrText,
        address: `Đã quét QR: ${qrData.content || qrText}`,
        description: `QR Code: ${qrText}`,
        location_id: qrData.location_id
      }
      
      setLocationInfo(locationData)
      
      // CHỈ HIỂN THỊ 1 THÔNG BÁO DUY NHẤT
      toast.success(`✅ Đã quét QR thành công: ${locationData.name}`)
      
      // Tự động chuyển sang bước chụp ảnh
      setCurrentStep('photo')
      
      // Lưu vào localStorage
      localStorage.setItem('lastScannedLocation', JSON.stringify(locationData))
      localStorage.setItem('lastScannedQR', qrText)
      
    } catch (error) {
      console.error('Lỗi xử lý QR Code:', error)
      toast.error('Lỗi xử lý QR Code')
      setLastResult('') // Reset để có thể quét lại
    }
  }

  // Bật camera chụp ảnh - TỐI ƯU HÓA ĐỂ TRÁNH XUNG ĐỘT
  const enablePhotoCamera = async () => {
    try {
      console.log('🎥 Enabling Photo Camera...')
      setIsInitializingCamera(true)
      setPhotoWebcamError(null)
      
      // Dừng QR scanner trước khi bật selfie camera
      if (controlsRef.current) {
        try {
          console.log('🛑 Stopping QR Scanner before enabling selfie camera...')
          controlsRef.current.stop()
        } catch (e) {
          console.log('QR Scanner stopped')
        } finally {
          controlsRef.current = null
        }
      }
      
      // Đặt isCameraActive = false để cleanup QR scanner
      setIsCameraActive(false)
      
      // Sử dụng CameraManager để dừng tất cả streams
      const cameraManager = CameraManager.getInstance()
      
      // FORCE STOP tất cả camera tracks trên toàn hệ thống
      await cameraManager.forceStopAllStreams()
      
      // Đợi thêm để đảm bảo camera được giải phóng hoàn toàn
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      setPhotoCameraActive(true)
      setIsInitializingCamera(false)
      console.log('✅ Photo Camera enabled successfully')
    } catch (error) {
      console.error('❌ Photo Camera error:', error)
      setPhotoWebcamError('Không thể khởi động camera. Vui lòng đóng các ứng dụng khác đang sử dụng camera và thử lại.')
      setIsInitializingCamera(false)
    }
  }

  // Chụp ảnh
  const capturePhoto = () => {
    console.log('📷 CAPTURE PHOTO: Starting with SimpleVideoCamera...')
    
    // Tạo canvas để capture từ video element
    const videoElement = document.querySelector('video') as HTMLVideoElement
    if (!videoElement) {
      console.error('📷 CAPTURE PHOTO: No video element found')
      toast.error('Không tìm thấy video element')
      return
    }
    
    if (!videoElement.videoWidth || !videoElement.videoHeight) {
      console.error('📷 CAPTURE PHOTO: Video element not ready')
      toast.error('Video chưa sẵn sàng. Vui lòng đợi một chút và thử lại.')
      return
    }
    
    try {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      
      if (!ctx) {
        console.error('📷 CAPTURE PHOTO: No canvas context')
        toast.error('Không thể tạo canvas context')
        return
      }
      
      // Set canvas size
      canvas.width = videoElement.videoWidth
      canvas.height = videoElement.videoHeight
      
      // Draw video frame
      ctx.drawImage(videoElement, 0, 0, canvas.width, canvas.height)
      
      // Add timestamp overlay - THỜI GIAN VIỆT NAM CHÍNH XÁC
      const now = new Date()
      const vietnamTime = new Date(now.toLocaleString("en-US", {timeZone: "Asia/Ho_Chi_Minh"}))
      const timestamp = vietnamTime.toLocaleString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      })
      
      // Larger background
      ctx.fillStyle = 'rgba(0, 0, 0, 0.8)'
      ctx.fillRect(10, canvas.height - 50, 300, 40)
      
      // White text with larger font
      ctx.fillStyle = 'white'
      ctx.font = 'bold 16px Arial'
      ctx.fillText(`📅 ${timestamp}`, 20, canvas.height - 25)
      
      const imageSrc = canvas.toDataURL('image/jpeg', 0.9)
      console.log('📷 CAPTURE PHOTO: Screenshot result:', imageSrc ? 'SUCCESS' : 'FAILED')
      
      if (imageSrc) {
        setCapturedPhoto(imageSrc)
        console.log('📷 CAPTURE PHOTO: Photo saved, length:', imageSrc.length)
                 toast.success(`📷 Đã chụp ảnh selfie thành công! Thời gian: ${timestamp}`)
        setCurrentStep('submit')
        // KHÔNG tắt camera, giữ camera để có thể chụp lại
      } else {
        console.error('📷 CAPTURE PHOTO: Failed to generate image')
        toast.error('Không thể chụp ảnh')
      }
    } catch (error) {
      console.error('📷 CAPTURE PHOTO: Error:', error)
      toast.error('Lỗi khi chụp ảnh: ' + (error as Error).message)
    }
  }

  // Submit checkin
  const submitCheckin = async () => {
    console.log('🚀 SUBMIT CHECKIN: Starting...')
    setIsSubmitting(true)

    try {
      // Kiểm tra user đã đăng nhập chưa
      if (!user) {
        toast.error('Vui lòng đăng nhập trước khi check-in!')
        navigate('/')
        return
      }

      // Đảm bảo token được set trong API headers
      const token = localStorage.getItem('access_token')
      if (token) {
        api.defaults.headers.common['Authorization'] = `Bearer ${token}`
        console.log('🔐 Token restored for checkin:', token.substring(0, 20) + '...')
      } else {
        toast.error('Token không tồn tại. Vui lòng đăng nhập lại!')
        navigate('/')
        return
      }

      console.log('🚀 Starting checkin submission...')
      
      // Prepare checkin data - ĐẢM BẢO CÓ ĐỦ THÔNG TIN
      const checkinData = {
        qr_code: lastResult || scannedQRContent || 'manual_checkin',
        location_id: locationInfo?.location_id || 1,
        notes: notes || `Check-in từ QR Scanner: ${lastResult || scannedQRContent}`,
        latitude: 0, // Không cần vị trí
        longitude: 0, // Không cần vị trí
        photo: capturedPhoto || 'data:image/jpeg;base64,placeholder' // Backend yêu cầu photo field
      }

      console.log('📤 Sending checkin data:', checkinData)

      // Submit checkin
      const response = await api.post('/patrol-records/checkin', checkinData)
      console.log('✅ Checkin response:', response.data)
      
      toast.success('Check-in thành công!')
      
      // Dispatch event để các dashboard khác cập nhật
      const eventDetail = {
        taskId, 
        stopId, 
        locationId,
        checkinData: response.data,
        timestamp: new Date().toISOString(),
        user: user?.username || user?.full_name
      };
      
      console.log('📡 Dispatching checkin-success event:', eventDetail);
      window.dispatchEvent(new CustomEvent('checkin-success', { 
        detail: eventDetail
      }));
      
      // Chuyển về trang phù hợp dựa trên nguồn gốc
      if (taskId && stopId && locationId) {
        // Nếu vào từ employee dashboard, quay lại đó
        navigate('/employee-dashboard')
      } else {
        // Nếu vào từ admin, quay lại admin dashboard
        navigate('/admin-dashboard')
      }
      
        } catch (error) {
      console.error('❌ Check-in error:', error)
      if ((error as any).response?.status === 401) {
        toast.error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!')
        navigate('/')
      } else {
        toast.error('Lỗi khi submit check-in: ' + (error as any).message)
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  // Kiểm tra xác thực khi component load
  useEffect(() => {
    if (!user) {
      console.log('🔐 QRScannerPage: No user found, redirecting to login')
      toast.error('Vui lòng đăng nhập để sử dụng QR Scanner!')
      navigate('/')
      return
    }
    console.log('🔐 QRScannerPage: User authenticated:', user.username)
  }, [user, navigate])

  useEffect(() => {
    const savedLocation = localStorage.getItem('lastScannedLocation')
    const savedQR = localStorage.getItem('lastScannedQR')
    
    if (savedLocation && savedQR) {
      try {
        const locationData = JSON.parse(savedLocation)
        setLocationInfo(locationData)
        setScannedQRContent(savedQR)
        setLastResult(savedQR)
        console.log('Khôi phục thông tin vị trí từ localStorage:', locationData)
      } catch (error) {
        console.error('Lỗi khôi phục thông tin:', error)
      }
    }
    
    // Setup offline sync
    setupOnlineSync()
    console.log('📱 Offline sync setup completed')
  }, [])

  // Bắt đầu quét QR khi camera active
  useEffect(() => {
    // Cleanup function
    return () => {
      if (controlsRef.current) {
        controlsRef.current.stop()
        console.log('🛑 QR Scanner cleaned up on unmount')
      }
    }
  }, [])

  useEffect(() => {
    if (isCameraActive && !lastResult) {
      setIsInitializingCamera(true) // Bắt đầu khởi tạo camera
      startQRScanner().finally(() => {
        setIsInitializingCamera(false) // Kết thúc khởi tạo
      })
    } else if (!isCameraActive && controlsRef.current) {
      // Dừng camera khi isCameraActive là false
      controlsRef.current.stop()
      console.log('🛑 QR Scanner stopped due to isCameraActive = false')
      controlsRef.current = null // Xóa controls sau khi dừng
    }
    // Không cần xử lý lastResult ở đây, logic dừng đã có trong handleQRScan
  }, [isCameraActive, lastResult])

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-4xl mx-auto">
        <div className="bg-white rounded-lg shadow-md p-4 mb-4">
          <div className="flex items-center justify-between mb-4">
            <h1 className="text-2xl font-bold text-gray-800">Quét QR & Check-in</h1>
            <button
              onClick={() => {
                if (taskId && stopId && locationId) {
                  navigate('/employee-dashboard')
                } else {
                  navigate('/dashboard')
                }
              }}
              className="px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600"
            >
              ← Quay lại {taskId && stopId && locationId ? 'Employee Dashboard' : 'Dashboard'}
            </button>
          </div>
        </div>

        {/* QR Scanner Section */}
        <div className="bg-white rounded-lg shadow-md p-4 mb-4">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold">Camera Quét QR</h2>
            <div className="flex gap-2">
              <button
                onClick={() => setIsCameraActive(!isCameraActive)}
                className={`px-4 py-2 rounded-lg font-medium ${
                  isCameraActive 
                    ? 'bg-red-500 text-white hover:bg-red-600' 
                    : 'bg-green-500 text-white hover:bg-green-600'
                }`}
              >
                {isCameraActive ? '⏹️ Tắt Camera' : '📷 Bật Camera'}
              </button>
              <button
                onClick={() => {
                  setLocationInfo(null)
                  setScannedQRContent(null)
                  setLastResult('')
                  localStorage.removeItem('lastScannedLocation')
                  localStorage.removeItem('lastScannedQR')
                }}
                className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
              >
                🔄 Reset
              </button>
            </div>
          </div>
          
          <div className="relative h-96">
            {isCameraActive ? (
              <div className="qr-scanner-container w-full h-full rounded-lg overflow-hidden relative">
                {/* Video element cho BrowserMultiFormatReader */}
                <video 
                  ref={videoRef} 
                  id="qr-video" 
                  className="w-full h-full object-cover"
                ></video>
                
                {/* Loading Overlay */}
                {isInitializingCamera && (
                  <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center rounded-lg z-10">
                    <div className="text-center text-white">
                      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto mb-2"></div>
                      <p className="text-sm">Đang khởi động QR Scanner...</p>
                      <p className="text-xs mt-2">Camera sau sẽ bật tự động</p>
                    </div>
                  </div>
                )}
                
                {/* Hiệu ứng border sáng khi đang quét */}
                <div className="absolute inset-0 border-4 border-blue-400 animate-pulse rounded-lg pointer-events-none"></div>
              </div>
            ) : (
              <div className="w-full h-full bg-gray-200 rounded-lg flex items-center justify-center">
                <div className="text-center">
                  <div className="text-6xl mb-4">📷</div>
                  <p className="text-gray-600">Nhấn "Bật Camera" để bắt đầu quét QR</p>
                </div>
              </div>
            )}
          </div>
          
          {/* Hiển thị thông tin QR code ngay bên dưới camera */}
          <div className="mt-4">
            {lastResult && locationInfo ? (
              <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                <h3 className="font-semibold text-green-800 mb-2">✅ QR Code đã quét thành công:</h3>
                <p className="text-green-700 font-mono text-sm break-all mb-2">{lastResult}</p>
                <p className="text-green-600 font-medium">📍 Vị trí: {locationInfo.name}</p>
                <p className="text-green-600 text-sm">📝 Mô tả: {locationInfo.description}</p>
              </div>
            ) : lastResult && !locationInfo ? (
              <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
                <h3 className="font-semibold text-red-800 mb-2">❌ Mã không hợp lệ:</h3>
                <p className="text-red-700 font-mono text-sm break-all">{lastResult}</p>
                <p className="text-red-600 text-sm mt-2">Vui lòng quét lại mã QR hợp lệ</p>
              </div>
            ) : (
              <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
                <p className="text-gray-600 text-center">Chưa quét QR code nào</p>
              </div>
            )}
          </div>
                </div>

        {/* Photo Camera Section - Always visible */}
          <div className="bg-white rounded-lg shadow-md p-4 mb-4">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold">Chụp ảnh selfie xác thực</h2>
              <div className="flex gap-2">
                <button
                  onClick={enablePhotoCamera}
                  disabled={isInitializingCamera}
                  className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                    isInitializingCamera 
                      ? 'bg-gray-400 text-gray-200 cursor-not-allowed' 
                      : 'bg-green-500 text-white hover:bg-green-600'
                  }`}
                >
                  {isInitializingCamera ? '⏳ Đang khởi động...' : '📷 Bật Camera Selfie'}
                </button>
              </div>
          </div>
          
              {photoCameraActive ? (
                <div className="relative">
                  {/* Loading Overlay */}
                  {isInitializingCamera && (
                    <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center rounded-lg z-10">
                      <div className="text-center text-white">
                        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto mb-2"></div>
                        <p className="text-sm">Đang khởi động camera...</p>
                      </div>
                    </div>
                  )}
                  
                  <FinalCamera
                    isActive={photoCameraActive}
                    onError={(error) => setPhotoWebcamError(error)}
                    onReady={() => {
                      console.log('Photo camera ready')
                      setIsInitializingCamera(false)
                    }}
                    className="w-full h-48 rounded-lg"
                    facingMode={photoFacingMode}
                  />
                <div className="mt-4 flex gap-2">
                  <button
                    onClick={capturePhoto}
                    className="px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 font-medium"
                  >
                    📸 Chụp ảnh
                  </button>
                  <button
                    onClick={() => {
                      setPhotoCameraActive(false)
                      // Quay lại QR scanner sau khi tắt selfie camera
                      setTimeout(() => {
                        setIsCameraActive(true)
                      }, 500)
                    }}
                    className="px-6 py-3 bg-red-500 text-white rounded-lg hover:bg-red-600 font-medium"
                  >
                    ⏹️ Tắt Camera
                  </button>
                </div>
                </div>
              ) : (
              <div className="w-full h-48 bg-gray-200 rounded-lg flex items-center justify-center">
                <div className="text-center">
                  <div className="text-4xl mb-2">📷</div>
                  <p className="text-gray-600 mb-2">Nhấn "Bật Camera Selfie" để chụp ảnh</p>
                  <p className="text-xs text-gray-400 mb-1">💡 Lưu ý: Camera QR sẽ tự động tắt khi bật camera selfie</p>
                  <p className="text-xs text-blue-500">📱 Đã tối ưu cho mobile - Camera sẽ khởi động nhanh hơn</p>
                </div>
              </div>
              )}

            {photoWebcamError && (
              <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                <div className="flex items-start">
                  <div className="text-red-500 text-xl mr-3">⚠️</div>
                  <div>
                    <p className="text-red-700 font-medium mb-1">Lỗi Camera</p>
                    <p className="text-red-600 text-sm">{photoWebcamError}</p>
                    <div className="mt-2 text-xs text-red-500">
                      <p>💡 Gợi ý:</p>
                      <ul className="list-disc list-inside ml-2">
                        <li>Đảm bảo đã cho phép truy cập camera</li>
                        <li>Đóng các ứng dụng khác đang sử dụng camera</li>
                        <li>Thử refresh trang và bật lại camera</li>
                        <li>Kiểm tra kết nối internet</li>
                      </ul>
                    </div>
                    <button
                      onClick={() => {
                        setPhotoWebcamError(null)
                        setPhotoCameraActive(false)
                        setIsInitializingCamera(false)
                      }}
                      className="mt-2 px-3 py-1 bg-red-100 text-red-700 rounded text-xs hover:bg-red-200"
                    >
                      Đóng thông báo
                    </button>
                  </div>
                </div>
              </div>
            )}

            {capturedPhoto && (
              <div className="mt-4">
                <h3 className="font-semibold mb-2">Ảnh đã chụp:</h3>
                  <img
                    src={capturedPhoto}
                    alt="Captured"
                  className="w-full max-w-md h-48 object-cover rounded-lg border"
                  />
                <div className="mt-2">
                  <button
                    onClick={() => {
                      setCapturedPhoto(null)
                      setCurrentStep('photo')
                    }}
                    className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 text-sm"
                  >
                    📸 Chụp lại
                  </button>
                </div>
                </div>
              )}
          </div>


        {/* Submit Button - Always visible */}
        <div className="bg-white rounded-lg shadow-md p-4 mb-4">
            <h2 className="text-lg font-semibold mb-4">Gửi báo cáo</h2>
            
            <div className="mb-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Ghi chú (tùy chọn):
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                rows={3}
                placeholder="Nhập ghi chú..."
              />
            </div>

            <button
              onClick={submitCheckin}
              disabled={isSubmitting}
              className={`w-full px-6 py-3 rounded-lg font-medium ${
                isSubmitting 
                  ? 'bg-gray-400 text-gray-600 cursor-not-allowed' 
                  : 'bg-green-500 text-white hover:bg-green-600'
              }`}
            >
              {isSubmitting ? '⏳ Đang xử lý...' : '📤 Gửi báo cáo'}
            </button>
        </div>

        {/* Success Message */}
        {currentStep === 'success' && (
          <div className="bg-white rounded-lg shadow-md p-4">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-green-800 mb-2">Check-in thành công!</h2>
              <p className="text-green-700">Báo cáo đã được gửi thành công</p>
              <div className="mt-4">
                <div className="inline-flex items-center px-4 py-2 bg-green-500 text-white rounded-lg">
                  <span className="animate-spin mr-2">⏳</span>
                  Đang reset form...
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default QRScannerPage
