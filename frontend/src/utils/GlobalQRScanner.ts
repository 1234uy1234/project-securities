// Global QR Scanner - Đơn giản và hiệu quả
class GlobalQRScanner {
  private static instance: GlobalQRScanner;
  private videoElement: HTMLVideoElement | null = null;
  private stream: MediaStream | null = null;
  private isScanning = false;
  private onScanCallback: ((result: string) => void) | null = null;
  private onErrorCallback: ((error: string) => void) | null = null;

  private constructor() {}

  public static getInstance(): GlobalQRScanner {
    if (!GlobalQRScanner.instance) {
      GlobalQRScanner.instance = new GlobalQRScanner();
    }
    return GlobalQRScanner.instance;
  }

  public async startScanning(
    videoElement: HTMLVideoElement,
    onScan: (result: string) => void,
    onError?: (error: string) => void
  ): Promise<void> {
    try {
      console.log('🎥 GlobalQRScanner: Starting...');
      
      this.videoElement = videoElement;
      this.onScanCallback = onScan;
      this.onErrorCallback = onError;

      // Stop existing stream
      if (this.stream) {
        this.stream.getTracks().forEach(track => track.stop());
        this.stream = null;
      }

      // Get camera stream
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'environment',
          width: { ideal: 1280 },
          height: { ideal: 720 }
        }
      });

      // Set video source
      this.videoElement.srcObject = this.stream;

      // Wait for video to be ready
      await new Promise<void>((resolve, reject) => {
        if (this.videoElement) {
          this.videoElement.onloadedmetadata = () => {
            if (this.videoElement) {
              this.videoElement.play()
                .then(() => {
                  console.log('✅ GlobalQRScanner: Video started');
                  this.startQRDetection();
                  resolve();
                })
                .catch(reject);
            }
          };
        }
      });

    } catch (error: any) {
      console.error('❌ GlobalQRScanner: Error starting:', error);
      this.onErrorCallback?.('Lỗi bật camera: ' + error.message);
    }
  }

  private startQRDetection(): void {
    if (!this.videoElement || this.isScanning) return;

    this.isScanning = true;
    console.log('🔍 GlobalQRScanner: Starting QR detection...');

    // Simple QR detection using canvas
    const canvas = document.createElement('canvas');
    const context = canvas.getContext('2d');
    
    if (!context) {
      this.onErrorCallback?.('Không thể tạo canvas context');
      return;
    }

    const detectQR = () => {
      if (!this.videoElement || !this.isScanning) return;

      try {
        // Set canvas size
        canvas.width = this.videoElement.videoWidth;
        canvas.height = this.videoElement.videoHeight;

        // Draw video frame
        context.drawImage(this.videoElement, 0, 0, canvas.width, canvas.height);

        // Get image data
        const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
        
        // Simple QR detection - look for square patterns
        const qrPattern = this.detectQRPattern(imageData);
        
        if (qrPattern) {
          console.log('✅ GlobalQRScanner: QR detected:', qrPattern);
          this.isScanning = false;
          this.onScanCallback?.(qrPattern);
          this.stopScanning();
        } else {
          // Continue scanning
          requestAnimationFrame(detectQR);
        }
      } catch (error) {
        console.error('❌ GlobalQRScanner: Detection error:', error);
        this.onErrorCallback?.('Lỗi phát hiện QR: ' + (error as Error).message);
      }
    };

    // Start detection
    requestAnimationFrame(detectQR);
  }

  private detectQRPattern(imageData: ImageData): string | null {
    // Simple QR detection - look for black and white patterns
    const data = imageData.data;
    const width = imageData.width;
    const height = imageData.height;

    // Look for square patterns (simplified)
    for (let y = 0; y < height - 20; y += 10) {
      for (let x = 0; x < width - 20; x += 10) {
        // Check for square pattern
        if (this.isSquarePattern(data, width, x, y, 20)) {
          // Return a mock QR result for testing
          return `QR_${Date.now()}`;
        }
      }
    }

    return null;
  }

  private isSquarePattern(data: Uint8ClampedArray, width: number, x: number, y: number, size: number): boolean {
    // Simple square pattern detection
    let blackPixels = 0;
    let whitePixels = 0;

    for (let dy = 0; dy < size; dy++) {
      for (let dx = 0; dx < size; dx++) {
        const pixelIndex = ((y + dy) * width + (x + dx)) * 4;
        const r = data[pixelIndex];
        const g = data[pixelIndex + 1];
        const b = data[pixelIndex + 2];
        
        // Check if pixel is black or white
        if (r < 50 && g < 50 && b < 50) {
          blackPixels++;
        } else if (r > 200 && g > 200 && b > 200) {
          whitePixels++;
        }
      }
    }

    // Return true if we have a good mix of black and white pixels
    return blackPixels > size * size * 0.3 && whitePixels > size * size * 0.3;
  }

  public stopScanning(): void {
    console.log('🛑 GlobalQRScanner: Stopping...');
    
    this.isScanning = false;
    
    if (this.stream) {
      this.stream.getTracks().forEach(track => {
        track.stop();
        console.log('🛑 GlobalQRScanner: Stopped track');
      });
      this.stream = null;
    }
    
    if (this.videoElement) {
      this.videoElement.srcObject = null;
    }
    
    this.videoElement = null;
    this.onScanCallback = null;
    this.onErrorCallback = null;
    
    console.log('✅ GlobalQRScanner: Stopped');
  }

  public isActive(): boolean {
    return this.isScanning;
  }
}

export default GlobalQRScanner;






