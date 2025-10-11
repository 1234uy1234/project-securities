import React, { useState, useEffect } from 'react';

interface MobileCameraManagerProps {
  onCameraReady: () => void;
  onCameraError: (error: string) => void;
}

const MobileCameraManager: React.FC<MobileCameraManagerProps> = ({
  onCameraReady,
  onCameraError
}) => {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    // Detect mobile
    const userAgent = navigator.userAgent;
    const mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent);
    setIsMobile(mobile);

    if (mobile) {
      console.log('📱 Mobile detected - using aggressive camera management');
      
      // Force stop all camera tracks on mobile
      const forceStopAllCamera = async () => {
        try {
          // Get all media devices
          const devices = await navigator.mediaDevices.enumerateDevices();
          console.log('📱 Available devices:', devices.length);
          
          // Try to get a temporary stream and stop it
          try {
            const tempStream = await navigator.mediaDevices.getUserMedia({ video: true });
            console.log('📱 Got temp stream, stopping...');
            tempStream.getTracks().forEach(track => {
              console.log(`📱 Stopping temp track: ${track.kind}`);
              track.stop();
            });
          } catch (e) {
            console.log('📱 Temp stream failed (expected):', e);
          }
          
          // Wait longer for mobile
          await new Promise(resolve => setTimeout(resolve, 3000));
          
          onCameraReady();
        } catch (error) {
          console.error('📱 Mobile camera management error:', error);
          onCameraError('Mobile camera management failed');
        }
      };

      forceStopAllCamera();
    } else {
      onCameraReady();
    }
  }, [onCameraReady, onCameraError]);

  // This component doesn't render anything, just manages camera
  return null;
};

export default MobileCameraManager;
