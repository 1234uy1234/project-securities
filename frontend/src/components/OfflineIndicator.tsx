import React, { useState, useEffect } from 'react'
import { Wifi, WifiOff, RefreshCw, CheckCircle } from 'lucide-react'
import { getQueueStatus } from '../utils/offlineQueue'

const OfflineIndicator: React.FC = () => {
  const [isOnline, setIsOnline] = useState(navigator.onLine)
  const [offlineCount, setOfflineCount] = useState(0)
  const [isSyncing, setIsSyncing] = useState(false)

  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true)
      setIsSyncing(true)
      // Simulate sync delay
      setTimeout(() => setIsSyncing(false), 2000)
    }
    const handleOffline = () => setIsOnline(false)

    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)

    // Check offline queue status periodically
    const checkQueueStatus = async () => {
      try {
        const status = await getQueueStatus()
        setOfflineCount(status.count)
      } catch (error) {
        console.error('Failed to check queue status:', error)
      }
    }

    checkQueueStatus()
    const interval = setInterval(checkQueueStatus, 5000) // Check every 5 seconds

    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
      clearInterval(interval)
    }
  }, [])

  if (isOnline && offlineCount === 0) return null

  return (
    <div className="fixed top-0 left-0 right-0 z-50 text-white px-4 py-2 text-center text-sm font-medium">
      {!isOnline ? (
        <div className="bg-red-600">
          <div className="flex items-center justify-center space-x-2">
            <WifiOff className="w-4 h-4" />
            <span>Bạn đang offline. Check-in sẽ được lưu và sync khi có mạng.</span>
          </div>
        </div>
      ) : isSyncing ? (
        <div className="bg-blue-600">
          <div className="flex items-center justify-center space-x-2">
            <RefreshCw className="w-4 h-4 animate-spin" />
            <span>Đang sync dữ liệu offline...</span>
          </div>
        </div>
      ) : offlineCount > 0 ? (
        <div className="bg-orange-600">
          <div className="flex items-center justify-center space-x-2">
            <Wifi className="w-4 h-4" />
            <span>Có {offlineCount} check-in offline chưa sync. Đang thử sync...</span>
          </div>
        </div>
      ) : (
        <div className="bg-green-600">
          <div className="flex items-center justify-center space-x-2">
            <CheckCircle className="w-4 h-4" />
            <span>Đã sync thành công tất cả dữ liệu offline!</span>
          </div>
        </div>
      )}
    </div>
  )
}

export default OfflineIndicator
