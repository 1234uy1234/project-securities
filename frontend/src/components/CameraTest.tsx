import React, { useRef, useEffect, useState, useCallback } from 'react';

const CameraTest: React.FC = () => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);

  const startCamera = useCallback(async () => {
    try {
      setError(null);
      
      // Test với settings khác nhau
      const constraints = {
        video: {
          width: { ideal: 640 },
          height: { ideal: 480 },
          facingMode: 'user',
          frameRate: { ideal: 15 },
          aspectRatio: { ideal: 4/3 }
        }
      };
      
      console.log('Requesting camera with constraints:', constraints);
      
      const mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
      console.log('Camera stream obtained:', mediaStream);
      
      setStream(mediaStream);
      
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
        
        videoRef.current.onloadedmetadata = () => {
          console.log('Video metadata loaded');
          if (videoRef.current) {
            videoRef.current.play()
              .then(() => {
                console.log('Video started playing');
                setIsPlaying(true);
              })
              .catch((err) => {
                console.error('Error playing video:', err);
                setError('Không thể phát video');
              });
          }
        };
        
        videoRef.current.onplay = () => {
          console.log('Video is playing');
          setIsPlaying(true);
        };
        
        videoRef.current.onpause = () => {
          console.log('Video is paused');
          setIsPlaying(false);
        };
        
        videoRef.current.onerror = (e) => {
          console.error('Video error:', e);
          setError('Lỗi video');
        };
      }
    } catch (err: any) {
      console.error('Camera error:', err);
      setError(`Lỗi camera: ${err.message}`);
    }
  }, []);

  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => {
        console.log('Stopping track:', track.kind);
        track.stop();
      });
      setStream(null);
      setIsPlaying(false);
    }
  }, [stream]);

  useEffect(() => {
    startCamera();
    return () => {
      stopCamera();
    };
  }, [startCamera, stopCamera]);

  return (
    <div className="p-8 max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Camera Test</h1>
      
      <div className="mb-4">
        <button
          onClick={startCamera}
          className="bg-blue-500 text-white px-4 py-2 rounded mr-2"
        >
          Start Camera
        </button>
        <button
          onClick={stopCamera}
          className="bg-red-500 text-white px-4 py-2 rounded"
        >
          Stop Camera
        </button>
      </div>
      
      <div className="mb-4">
        <p>Status: {isPlaying ? 'Playing' : 'Not Playing'}</p>
        <p>Stream: {stream ? 'Active' : 'Inactive'}</p>
        {error && <p className="text-red-500">Error: {error}</p>}
      </div>
      
      <div className="relative bg-gray-100 rounded-lg overflow-hidden">
        <video
          ref={videoRef}
          autoPlay
          playsInline
          muted
          className="w-full h-96 object-cover"
          style={{
            transform: 'scaleX(-1)',
            filter: 'brightness(1.1) contrast(1.1)',
            objectFit: 'cover'
          }}
        />
        
        {/* Overlay để test */}
        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
          <div className="w-48 h-48 border-4 border-white border-dashed rounded-full opacity-70">
            <div className="absolute top-4 left-1/2 transform -translate-x-1/2 text-white text-sm font-medium">
              Test Camera Here
            </div>
          </div>
        </div>
      </div>
      
      <div className="mt-4 text-sm text-gray-600">
        <p>Nếu camera vẫn bị giật, có thể do:</p>
        <ul className="list-disc list-inside mt-2">
          <li>Browser không hỗ trợ tốt camera</li>
          <li>Camera đang được sử dụng bởi app khác</li>
          <li>Hardware không đủ mạnh</li>
          <li>Network lag (nếu dùng remote camera)</li>
        </ul>
      </div>
    </div>
  );
};

export default CameraTest;
