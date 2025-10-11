import React, { useEffect, useState } from 'react'
import { useSearchParams, useNavigate } from 'react-router-dom'
import { useAuthStore } from '../stores/authStore'
import toast from 'react-hot-toast'

const SmartQRPage: React.FC = () => {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const { user, isAuthenticated } = useAuthStore()
  const [loading, setLoading] = useState(true)
  
  const locationId = searchParams.get('location_id')
  const locationName = searchParams.get('location_name')

  useEffect(() => {
    const handleSmartQR = async () => {
      console.log('🎯 SmartQRPage loaded!')
      console.log('📍 Location ID:', locationId, 'Name:', locationName)
      console.log('🔐 Is authenticated:', isAuthenticated, 'User:', user)
      
      try {
        if (!locationId) {
          console.log('❌ No location ID')
          toast.error('QR code không hợp lệ')
          navigate('/')
          return
        }

        if (!isAuthenticated || !user) {
          // Chưa đăng nhập - chuyển đến trang login với thông tin vị trí
          console.log('🔑 Not authenticated, redirecting to login')
          toast.success(`🔑 Chưa đăng nhập! Vui lòng đăng nhập để chấm công tại ${locationName || 'vị trí này'}`)
          navigate(`/?location_id=${locationId}&location_name=${encodeURIComponent(locationName || '')}`)
          return
        }

        // Đã đăng nhập - chuyển đến QR Scanner với thông tin vị trí
        console.log('✅ Authenticated, redirecting to QR scanner')
        toast.success(`📍 Đã đăng nhập! Chuyển đến chấm công tại ${locationName || 'vị trí này'}`)
        navigate(`/qr-scanner?location_id=${locationId}&location_name=${encodeURIComponent(locationName || '')}`)
        
      } catch (error) {
        console.error('Error handling smart QR:', error)
        toast.error('Có lỗi xảy ra khi xử lý QR code')
        navigate('/')
      } finally {
        setLoading(false)
      }
    }

    handleSmartQR()
  }, [locationId, locationName, isAuthenticated, user, navigate])

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-8 h-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Đang xử lý QR code...</p>
        </div>
      </div>
    )
  }

  return null
}

export default SmartQRPage
