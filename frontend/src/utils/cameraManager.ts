/**
 * Camera Manager - Tối ưu hóa camera cho mobile và desktop
 * Quản lý camera streams và tránh conflicts
 */

class CameraManager {
  private static instance: CameraManager;
  private activeStreams: Map<string, MediaStream> = new Map();
  private isMobile: boolean = false;
  private isIOS: boolean = false;
  private isAndroid: boolean = false;

  private constructor() {
    this.detectDevice();
  }

  public static getInstance(): CameraManager {
    if (!CameraManager.instance) {
      CameraManager.instance = new CameraManager();
    }
    return CameraManager.instance;
  }

  private detectDevice(): void {
    const userAgent = navigator.userAgent;
    this.isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent);
    this.isIOS = /iPad|iPhone|iPod/.test(userAgent);
    this.isAndroid = /Android/i.test(userAgent);
    
    console.log('📱 Device Detection:', {
      isMobile: this.isMobile,
      isIOS: this.isIOS,
      isAndroid: this.isAndroid,
      userAgent: userAgent
    });
  }

  /**
   * Lấy camera constraints tối ưu cho từng loại camera
   */
  public getOptimizedConstraints(type: 'qr' | 'photo' | 'face'): MediaStreamConstraints {
    const baseConstraints = {
      audio: false,
      video: {} as any
    };

    if (this.isMobile) {
      // MOBILE: Constraints cực kỳ đơn giản
      switch (type) {
        case 'qr':
          return {
            ...baseConstraints,
            video: {
              facingMode: 'environment'
            }
          };

        case 'photo':
        case 'face':
          return {
            ...baseConstraints,
            video: {
              facingMode: 'user'
            }
          };

        default:
          return {
            ...baseConstraints,
            video: {
              facingMode: 'user'
            }
          };
      }
    } else {
      // DESKTOP: Constraints đầy đủ
      switch (type) {
        case 'qr':
          return {
            ...baseConstraints,
            video: {
              facingMode: 'environment',
              width: { ideal: 1280, min: 640 },
              height: { ideal: 720, min: 480 },
              frameRate: { ideal: 30, max: 30 },
              aspectRatio: { ideal: 16/9 },
              resizeMode: 'crop-and-scale'
            }
          };

        case 'photo':
        case 'face':
          return {
            ...baseConstraints,
            video: {
              facingMode: 'user',
              width: { ideal: 640, max: 1280 },
              height: { ideal: 480, max: 720 },
              frameRate: { ideal: 24, max: 30 },
              aspectRatio: { ideal: 4/3 },
              resizeMode: 'crop-and-scale'
            }
          };

        default:
          return baseConstraints;
      }
    }
  }

  /**
   * Lấy camera stream với fallback cho mobile
   */
  public async getStream(id: string, constraints: MediaStreamConstraints): Promise<MediaStream> {
    try {
      console.log(`🎥 Getting camera stream for ${id}:`, constraints);
      
      // Đảm bảo chỉ có 1 camera stream hoạt động
      await this.ensureSingleCameraStream(id);
      
      // Thử với constraints tối ưu
      const stream = await navigator.mediaDevices.getUserMedia(constraints);
      this.activeStreams.set(id, stream);
      
      console.log(`✅ Camera stream obtained for ${id}`);
      return stream;
      
    } catch (error: any) {
      console.error(`❌ Failed to get camera stream for ${id}:`, error);
      
      // Fallback cho mobile
      if (this.isMobile) {
        console.log('📱 Trying mobile fallback...');
        return await this.getMobileFallbackStream(id, constraints);
      }
      
      throw error;
    }
  }

  /**
   * Fallback stream cho mobile với constraints đơn giản hơn
   */
  private async getMobileFallbackStream(id: string, originalConstraints: MediaStreamConstraints): Promise<MediaStream> {
    const fallbackConstraints: MediaStreamConstraints = {
      audio: false,
      video: {
        facingMode: (originalConstraints.video as any)?.facingMode || 'user',
        width: { ideal: 320, max: 640 },
        height: { ideal: 240, max: 480 },
        frameRate: { ideal: 10, max: 15 }
      }
    };

    try {
      console.log('📱 Trying mobile fallback constraints:', fallbackConstraints);
      const stream = await navigator.mediaDevices.getUserMedia(fallbackConstraints);
      this.activeStreams.set(id, stream);
      
      console.log(`✅ Mobile fallback stream obtained for ${id}`);
      return stream;
      
    } catch (fallbackError: any) {
      console.error('❌ Mobile fallback also failed:', fallbackError);
      
      // Fallback cuối cùng - chỉ cần camera
      const minimalConstraints: MediaStreamConstraints = {
        audio: false,
        video: true
      };
      
      console.log('📱 Trying minimal constraints:', minimalConstraints);
      const stream = await navigator.mediaDevices.getUserMedia(minimalConstraints);
      this.activeStreams.set(id, stream);
      
      console.log(`✅ Minimal stream obtained for ${id}`);
      return stream;
    }
  }

  /**
   * Dừng camera stream cụ thể
   */
  public async stopStream(id: string): Promise<void> {
    const stream = this.activeStreams.get(id);
    if (stream) {
      console.log(`🛑 Stopping camera stream for ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`🛑 Stopping track: ${track.kind} - ${track.label}`);
        track.stop();
      });
      this.activeStreams.delete(id);
      
      // Đợi một chút để camera được giải phóng hoàn toàn
      await new Promise(resolve => setTimeout(resolve, this.isMobile ? 800 : 500));
    }
  }

  /**
   * Dừng tất cả camera streams
   */
  public async stopAllStreams(): Promise<void> {
    console.log('🛑 Stopping all camera streams...');
    
    // Lấy tất cả tracks từ tất cả streams
    const allTracks: MediaStreamTrack[] = [];
    
    for (const [id, stream] of this.activeStreams) {
      console.log(`🛑 Stopping stream: ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`🛑 Stopping track: ${track.kind} - ${track.label}`);
        allTracks.push(track);
        track.stop();
      });
    }
    
    this.activeStreams.clear();
    
    // Đợi lâu hơn cho mobile để đảm bảo camera được giải phóng
    await new Promise(resolve => setTimeout(resolve, this.isMobile ? 1500 : 1000));
    
    // Kiểm tra lại xem có tracks nào còn active không
    const stillActiveTracks = allTracks.filter(track => track.readyState === 'live');
    if (stillActiveTracks.length > 0) {
      console.log(`⚠️ Still ${stillActiveTracks.length} active tracks, forcing stop...`);
      stillActiveTracks.forEach(track => {
        track.stop();
      });
      // Đợi thêm
      await new Promise(resolve => setTimeout(resolve, 500));
    }
    
    console.log('✅ All camera streams stopped');
  }

  /**
   * Kiểm tra xem có stream nào đang active không
   */
  public hasActiveStreams(): boolean {
    return this.activeStreams.size > 0;
  }

  /**
   * Lấy danh sách active streams
   */
  public getActiveStreams(): string[] {
    return Array.from(this.activeStreams.keys());
  }

  /**
   * Kiểm tra xem có phải mobile không
   */
  public getIsMobile(): boolean {
    return this.isMobile;
  }

  /**
   * Kiểm tra xem có phải iOS không
   */
  public getIsIOS(): boolean {
    return this.isIOS;
  }

  /**
   * Kiểm tra xem có phải Android không
   */
  public getIsAndroid(): boolean {
    return this.isAndroid;
  }

  /**
   * Force stop tất cả camera streams - method mạnh nhất
   */
  public async forceStopAllStreams(): Promise<void> {
    console.log('🚨 FORCE STOPPING all camera streams...');
    
    // Lấy tất cả tracks từ tất cả streams
    const allTracks: MediaStreamTrack[] = [];
    
    for (const [id, stream] of this.activeStreams) {
      console.log(`🚨 FORCE stopping stream: ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`🚨 FORCE stopping track: ${track.kind} - ${track.label}`);
        allTracks.push(track);
        track.stop();
      });
    }
    
    this.activeStreams.clear();
    
    // Đợi lâu hơn cho mobile
    const waitTime = this.isMobile ? 3000 : 2000;
    console.log(`⏳ Waiting ${waitTime}ms for mobile: ${this.isMobile}`);
    await new Promise(resolve => setTimeout(resolve, waitTime));
    
    // Force stop tất cả tracks còn lại
    allTracks.forEach(track => {
      if (track.readyState === 'live') {
        console.log(`🚨 FORCE stopping remaining track: ${track.kind}`);
        track.stop();
      }
    });
    
    // Đợi thêm cho mobile
    const extraWaitTime = this.isMobile ? 2000 : 1000;
    console.log(`⏳ Extra wait ${extraWaitTime}ms for mobile: ${this.isMobile}`);
    await new Promise(resolve => setTimeout(resolve, extraWaitTime));
    
    console.log('✅ FORCE STOP completed');
  }

  /**
   * NUCLEAR OPTION - Force stop tất cả camera trên toàn hệ thống (cho mobile)
   */
  public async nuclearStopAllCamera(): Promise<void> {
    console.log('☢️ NUCLEAR STOP: Stopping ALL camera on system...');
    
    // Stop tất cả streams trong activeStreams
    for (const [id, stream] of this.activeStreams) {
      console.log(`☢️ NUCLEAR stopping stream: ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`☢️ NUCLEAR stopping track: ${track.kind} - ${track.label}`);
        track.stop();
      });
    }
    
    this.activeStreams.clear();
    
    // Đợi rất lâu cho mobile
    const waitTime = this.isMobile ? 5000 : 3000;
    console.log(`⏳ NUCLEAR wait ${waitTime}ms for mobile: ${this.isMobile}`);
    await new Promise(resolve => setTimeout(resolve, waitTime));
    
    // Thử stop tất cả media devices
    try {
      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        // Force stop bằng cách tạo và stop stream mới
        const tempStream = await navigator.mediaDevices.getUserMedia({ video: true });
        tempStream.getTracks().forEach(track => {
          console.log(`☢️ NUCLEAR stopping temp track: ${track.kind}`);
          track.stop();
        });
      }
    } catch (e) {
      console.log('☢️ NUCLEAR temp stream failed (expected):', e);
    }
    
    // Đợi thêm
    const extraWaitTime = this.isMobile ? 3000 : 2000;
    console.log(`⏳ NUCLEAR extra wait ${extraWaitTime}ms for mobile: ${this.isMobile}`);
    await new Promise(resolve => setTimeout(resolve, extraWaitTime));
    
    console.log('✅ NUCLEAR STOP completed');
  }

  /**
   * ULTIMATE STOP - Method cuối cùng để stop camera (cho mobile cứng đầu)
   */
  public async ultimateStopAllCamera(): Promise<void> {
    console.log('💀 ULTIMATE STOP: Final attempt to stop ALL camera...');
    
    // Stop tất cả streams trong activeStreams
    for (const [id, stream] of this.activeStreams) {
      console.log(`💀 ULTIMATE stopping stream: ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`💀 ULTIMATE stopping track: ${track.kind} - ${track.label}`);
        track.stop();
      });
    }
    
    this.activeStreams.clear();
    
    // Đợi rất rất lâu cho mobile
    const waitTime = this.isMobile ? 10000 : 5000;
    console.log(`⏳ ULTIMATE wait ${waitTime}ms for mobile: ${this.isMobile}`);
    await new Promise(resolve => setTimeout(resolve, waitTime));
    
    // Thử nhiều cách để stop camera
    try {
      // Method 1: Tạo và stop temp stream
      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        const tempStream = await navigator.mediaDevices.getUserMedia({ video: true });
        tempStream.getTracks().forEach(track => {
          console.log(`💀 ULTIMATE stopping temp track: ${track.kind}`);
          track.stop();
        });
      }
    } catch (e) {
      console.log('💀 ULTIMATE temp stream failed (expected):', e);
    }
    
    // Method 2: Thử với constraints khác nhau
    try {
      const tempStream2 = await navigator.mediaDevices.getUserMedia({ 
        video: { facingMode: 'user' } 
      });
      tempStream2.getTracks().forEach(track => {
        console.log(`💀 ULTIMATE stopping temp track 2: ${track.kind}`);
        track.stop();
      });
    } catch (e) {
      console.log('💀 ULTIMATE temp stream 2 failed (expected):', e);
    }
    
    // Đợi thêm rất lâu
    const extraWaitTime = this.isMobile ? 5000 : 3000;
    console.log(`⏳ ULTIMATE extra wait ${extraWaitTime}ms for mobile: ${this.isMobile}`);
    await new Promise(resolve => setTimeout(resolve, extraWaitTime));
    
    console.log('✅ ULTIMATE STOP completed');
  }

  /**
   * GHOST KILLER - Method để kill "ghost camera streams" (cho mobile cứng đầu)
   */
  public async killGhostCameraStreams(): Promise<void> {
    console.log('👻 GHOST KILLER: Killing ghost camera streams...');
    
    // Stop tất cả streams trong activeStreams
    for (const [id, stream] of this.activeStreams) {
      console.log(`👻 GHOST KILLER stopping stream: ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`👻 GHOST KILLER stopping track: ${track.kind} - ${track.label}`);
        track.stop();
      });
    }
    
    this.activeStreams.clear();
    
    // Đợi để camera được giải phóng
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Thử nhiều cách để kill ghost streams
    try {
      // Method 1: Tạo và kill temp stream
      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        const tempStream = await navigator.mediaDevices.getUserMedia({ video: true });
        console.log('👻 GHOST KILLER got temp stream, killing...');
        tempStream.getTracks().forEach(track => {
          console.log(`👻 GHOST KILLER killing temp track: ${track.kind}`);
          track.stop();
        });
      }
    } catch (e) {
      console.log('👻 GHOST KILLER temp stream failed (expected):', e);
    }
    
    // Method 2: Thử với constraints khác nhau
    try {
      const tempStream2 = await navigator.mediaDevices.getUserMedia({ 
        video: { facingMode: 'environment' } 
      });
      console.log('👻 GHOST KILLER got temp stream 2, killing...');
      tempStream2.getTracks().forEach(track => {
        console.log(`👻 GHOST KILLER killing temp track 2: ${track.kind}`);
        track.stop();
      });
    } catch (e) {
      console.log('👻 GHOST KILLER temp stream 2 failed (expected):', e);
    }
    
    // Method 3: Thử với constraints khác nhau nữa
    try {
      const tempStream3 = await navigator.mediaDevices.getUserMedia({ 
        video: { width: 640, height: 480 } 
      });
      console.log('👻 GHOST KILLER got temp stream 3, killing...');
      tempStream3.getTracks().forEach(track => {
        console.log(`👻 GHOST KILLER killing temp track 3: ${track.kind}`);
        track.stop();
      });
    } catch (e) {
      console.log('👻 GHOST KILLER temp stream 3 failed (expected):', e);
    }
    
    // Đợi lâu để camera được giải phóng hoàn toàn
    const waitTime = this.isMobile ? 5000 : 3000;
    console.log(`⏳ GHOST KILLER wait ${waitTime}ms for mobile: ${this.isMobile}`);
    await new Promise(resolve => setTimeout(resolve, waitTime));
    
    console.log('✅ GHOST KILLER completed');
  }

  /**
   * Get active streams map - trả về Map của active streams
   */
  public getActiveStreamsMap(): Map<string, MediaStream> {
    return this.activeStreams;
  }

  /**
   * Debug method - kiểm tra trạng thái camera
   */
  public async debugCameraStatus(): Promise<void> {
    console.log('🔍 DEBUG: Camera Status Check...');
    console.log(`📊 Active streams: ${this.activeStreams.size}`);
    console.log(`📱 Device: Mobile=${this.isMobile}, iOS=${this.isIOS}, Android=${this.isAndroid}`);
    
    for (const [id, stream] of this.activeStreams) {
      console.log(`📊 Stream ${id}:`, {
        id: stream.id,
        active: stream.active,
        tracks: stream.getTracks().map(track => ({
          kind: track.kind,
          label: track.label,
          readyState: track.readyState,
          enabled: track.enabled
        }))
      });
    }
    
    try {
      const devices = await navigator.mediaDevices.enumerateDevices();
      const videoDevices = devices.filter(device => device.kind === 'videoinput');
      console.log(`📊 Available video devices: ${videoDevices.length}`);
      videoDevices.forEach((device, index) => {
        console.log(`📊 Device ${index}:`, {
          deviceId: device.deviceId,
          label: device.label,
          groupId: device.groupId
        });
      });
    } catch (e) {
      console.log('📊 Cannot enumerate devices:', e);
    }
  }

  /**
   * Method đơn giản để dừng camera - hiệu quả nhất
   */
  public async simpleStopAllStreams(): Promise<void> {
    console.log('🛑 SIMPLE STOP: Stopping all camera streams...');
    
    // Dừng tất cả streams một cách đơn giản
    for (const [id, stream] of this.activeStreams) {
      console.log(`🛑 Stopping stream: ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`🛑 Stopping track: ${track.kind} - ${track.label}`);
        track.stop();
      });
    }
    
    this.activeStreams.clear();
    
    // Đợi ngắn gọn
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    console.log('✅ SIMPLE STOP completed');
  }

  /**
   * Stop tất cả camera tracks trên toàn hệ thống - cho mobile
   */
  public async stopAllCameraTracks(): Promise<void> {
    console.log('🛑 STOP ALL CAMERA TRACKS: Stopping all camera tracks on system...');
    
    // Dừng tất cả streams trong activeStreams
    for (const [id, stream] of this.activeStreams) {
      console.log(`🛑 Stopping stream: ${id}`);
      stream.getTracks().forEach(track => {
        console.log(`🛑 Stopping track: ${track.kind} - ${track.label}`);
        track.stop();
      });
    }
    
    this.activeStreams.clear();
    
    // Đợi để đảm bảo tracks được stop hoàn toàn
    await new Promise(resolve => setTimeout(resolve, this.isMobile ? 1500 : 1000));
    
    console.log('✅ STOP ALL CAMERA TRACKS completed');
  }

  /**
   * Đảm bảo chỉ có 1 camera stream hoạt động tại 1 thời điểm
   */
  public async ensureSingleCameraStream(newStreamId: string): Promise<void> {
    console.log(`🔒 ENSURING SINGLE CAMERA: Only ${newStreamId} should be active...`);
    
    // Stop tất cả streams khác
    for (const [id, stream] of this.activeStreams) {
      if (id !== newStreamId) {
        console.log(`🛑 Stopping other stream: ${id}`);
        stream.getTracks().forEach(track => {
          console.log(`🛑 Stopping track: ${track.kind} - ${track.label}`);
          track.stop();
        });
        this.activeStreams.delete(id);
      }
    }
    
    // Đợi để đảm bảo tracks được stop hoàn toàn
    await new Promise(resolve => setTimeout(resolve, this.isMobile ? 1000 : 500));
    
    console.log(`✅ SINGLE CAMERA ENSURED: Only ${newStreamId} is active`);
  }

}

export default CameraManager;
