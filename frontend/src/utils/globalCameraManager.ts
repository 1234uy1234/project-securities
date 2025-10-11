// Global Camera Manager - Quản lý tất cả camera streams
class GlobalCameraManager {
  private static instance: GlobalCameraManager;
  private activeStreams: Map<string, MediaStream> = new Map();
  private isMobile: boolean;

  private constructor() {
    this.isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  }

  public static getInstance(): GlobalCameraManager {
    if (!GlobalCameraManager.instance) {
      GlobalCameraManager.instance = new GlobalCameraManager();
    }
    return GlobalCameraManager.instance;
  }

  // Force stop ALL camera streams
  public async forceStopAllStreams(): Promise<void> {
    console.log('🛑 FORCE STOP ALL CAMERA STREAMS');
    
    // Stop all tracked streams
    for (const [id, stream] of this.activeStreams) {
      try {
        stream.getTracks().forEach(track => {
          track.stop();
          console.log(`🛑 Stopped track from stream: ${id}`);
        });
      } catch (e) {
        console.log(`⚠️ Error stopping stream ${id}:`, e);
      }
    }
    
    this.activeStreams.clear();
    
    // Additional cleanup for mobile
    if (this.isMobile) {
      try {
        // Try to get and immediately stop any remaining streams
        const devices = await navigator.mediaDevices.enumerateDevices();
        console.log('📱 Available devices after cleanup:', devices.length);
      } catch (e) {
        console.log('⚠️ Error enumerating devices:', e);
      }
    }
    
    console.log('✅ All camera streams stopped');
  }

  // Start camera with specific constraints
  public async startCamera(
    id: string, 
    constraints: MediaStreamConstraints
  ): Promise<MediaStream> {
    console.log(`🎥 Starting camera: ${id}`);
    
    // Only stop existing stream with same ID, not all streams
    this.stopCamera(id);
    
    // Wait a bit for cleanup
    await new Promise(resolve => setTimeout(resolve, 200));
    
    try {
      const stream = await navigator.mediaDevices.getUserMedia(constraints);
      this.activeStreams.set(id, stream);
      console.log(`✅ Camera started: ${id}`);
      return stream;
    } catch (error) {
      console.error(`❌ Error starting camera ${id}:`, error);
      throw error;
    }
  }

  // Stop specific camera
  public stopCamera(id: string): void {
    const stream = this.activeStreams.get(id);
    if (stream) {
      stream.getTracks().forEach(track => {
        track.stop();
        console.log(`🛑 Stopped camera: ${id}`);
      });
      this.activeStreams.delete(id);
    }
  }

  // Get active streams count
  public getActiveStreamsCount(): number {
    return this.activeStreams.size;
  }

  // Check if mobile
  public isMobileDevice(): boolean {
    return this.isMobile;
  }
}

export default GlobalCameraManager;
