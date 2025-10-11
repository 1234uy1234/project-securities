import { useState, useEffect } from 'react'
import { useAuthStore } from '../stores/authStore'
import { Eye, EyeOff, Lock, User, Camera } from 'lucide-react'
import toast from 'react-hot-toast'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { api } from '../utils/api'
import SimpleFaceAuthModal from '../components/SimpleFaceAuthModal'

const LoginPage = () => {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [rememberMe, setRememberMe] = useState(false)
  const { login, isLoading, user } = useAuthStore()
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const [qrRef, setQrRef] = useState<string | null>(null)
  const [showFaceAuth, setShowFaceAuth] = useState(false)
  const [faceAuthStatus, setFaceAuthStatus] = useState<{
    has_face_data: boolean;
    registered_at?: string;
    message?: string;
  } | null>(null)

  // Check for QR code reference on page load
  useEffect(() => {
    const ref = searchParams.get('ref')
    const qr = searchParams.get('qr')
    const locationId = searchParams.get('location_id')
    const locationName = searchParams.get('location_name')
    
    if (ref) {
      setQrRef(ref)
      toast.success(`Đã quét QR code: "${ref}". Vui lòng đăng nhập để tiếp tục.`)
    } else if (qr === 'quick') {
      setQrRef('QR Login')
      toast.success('🔑 Đã quét QR Login! Vui lòng đăng nhập để tiếp tục.')
    } else if (locationId) {
      setQrRef(`Vị trí: ${locationName || 'Vị trí ' + locationId}`)
      toast.success(`📍 Đã quét QR tại ${locationName || 'vị trí này'}! Vui lòng đăng nhập để chấm công.`)
    }
  }, [searchParams])

  // Load saved credentials on component mount
  useEffect(() => {
    const savedCredentials = localStorage.getItem('remembered-credentials')
    if (savedCredentials) {
      try {
        const { username: savedUsername, password: savedPassword, rememberMe: savedRememberMe } = JSON.parse(savedCredentials)
        setUsername(savedUsername || '')
        setPassword(savedPassword || '')
        setRememberMe(savedRememberMe || false)
      } catch (error) {
        console.error('Error loading saved credentials:', error)
        // Clear invalid data
        localStorage.removeItem('remembered-credentials')
      }
    }
  }, [])

  // Check face auth status
  const checkFaceAuthStatus = async () => {
    try {
      // Sử dụng axios với authentication
      const { api } = await import('../utils/api');
      const response = await api.get('/face-auth/status');
      const data = response.data;
      
      console.log('🔍 Face auth status:', data);
      setFaceAuthStatus(data);
    } catch (error) {
      console.error('Error checking face auth status:', error);
      // Nếu không thể kiểm tra status, vẫn hiển thị nút face auth
      setFaceAuthStatus({ has_face_data: true, message: "Có thể đăng nhập bằng khuôn mặt" });
    }
  }

  // Handle face login success
  const handleFaceLoginSuccess = async (userData: any) => {
    try {
      console.log('🎉 Face login successful:', userData)
      
      // Validate user data
      if (!userData) {
        console.error('❌ No user data received:', userData)
        toast.error('Không nhận được dữ liệu người dùng')
        return
      }
      
      if (!userData.id || !userData.username || !userData.role) {
        console.error('❌ Missing required user fields:', userData)
        toast.error('Dữ liệu người dùng thiếu thông tin cần thiết')
        return
      }
      
      // Set user data in auth store
      useAuthStore.getState().setUser(userData)
      
      // Set token if available
      if (userData.token) {
        localStorage.setItem('auth_token', userData.token)
        useAuthStore.getState().setToken(userData.token)
      }
      
      // Lưu username để sử dụng cho face verification
      if (userData.username) {
        localStorage.setItem('username', userData.username)
      }
      
      // Set authentication status
      useAuthStore.getState().setIsAuthenticated(true)
      
      toast.success(`🎉 Xin chào ${userData.full_name || userData.username}! Đăng nhập bằng khuôn mặt thành công.`)
      
      // Close face auth modal
      setShowFaceAuth(false)
      
      // Navigate immediately without setTimeout
      if (qrRef) {
        if (qrRef.includes('QR Login')) {
          navigate('/dashboard')
        } else if (qrRef.includes('Vị trí:')) {
          navigate('/checkin')
        } else {
          navigate('/checkin')
        }
      } else {
        // Navigate based on user role
        const role = userData.role
        if (role === 'admin') {
          navigate('/admin-dashboard')
        } else if (role === 'manager') {
          navigate('/tasks')
        } else {
          navigate('/dashboard')
        }
      }
      
    } catch (error) {
      console.error('Error handling face login:', error)
      toast.error('Có lỗi xảy ra khi đăng nhập')
    }
  }


  // Check face auth status on mount
  useEffect(() => {
    checkFaceAuthStatus()
  }, []) // Empty dependency array - only run once on mount

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    console.log('=== LOGIN FORM SUBMITTED ===')
    console.log('Username:', username)
    console.log('Password:', password)
    console.log('Form event:', e)
    
    // Validate inputs
    if (!username.trim()) {
      toast.error('Vui lòng nhập tên đăng nhập')
      return
    }
    if (!password.trim()) {
      toast.error('Vui lòng nhập mật khẩu')
      return
    }
    
    try {
      console.log('Calling login function...')
      await login(username, password)
      console.log('Login successful!')
      
      // Lưu username để sử dụng cho face verification
      localStorage.setItem('username', username)
      console.log('Username saved for face verification:', username)
      
      // Save credentials if "Remember Me" is checked
      if (rememberMe) {
        const credentials = {
          username,
          password,
          rememberMe: true
        }
        localStorage.setItem('remembered-credentials', JSON.stringify(credentials))
        console.log('Credentials saved')
        toast.success('✅ Đăng nhập thành công! Thông tin đã được lưu để lần sau.')
      } else {
        // Clear saved credentials if "Remember Me" is unchecked
        localStorage.removeItem('remembered-credentials')
        console.log('Credentials cleared')
        toast.success('✅ Đăng nhập thành công!')
      }
      
      // Kiểm tra nhiệm vụ mới cho user
      try {
        const user = useAuthStore.getState().user
        if (user && user.role !== 'admin') {
          const response = await api.get(`/patrol-tasks/user/${user.id}/new-tasks`)
          const newTasks = response.data
          if (newTasks && newTasks.length > 0) {
            toast.success(`📋 Bạn có ${newTasks.length} nhiệm vụ mới!`, {
              duration: 5000,
              icon: '📋'
            })
          }
        }
      } catch (error) {
        console.error('Error checking new tasks:', error)
      }
      
      // Kiểm tra xem có ref từ QR không
      const ref = searchParams.get('ref')
      
      if (ref) {
        // Nếu có ref từ QR, chuyển đến QR Scanner
        toast.success(`🎉 Đăng nhập thành công! Chuyển đến chấm công...`)
        navigate(`/qr-scanner?ref=${ref}`)
      } else {
        // Chuyển đến dashboard bình thường
        const role = useAuthStore.getState().user?.role
        if (role === 'admin' || role === 'manager') navigate('/tasks')
        else navigate('/dashboard')
      }
    } catch (error: any) {
      toast.error(error.response?.data?.detail || 'Đăng nhập thất bại')
    }
  }

  const handleForgot = async () => {
    if (!username && !user?.email) {
      return toast.error('Nhập email ở ô Tên đăng nhập hoặc đăng nhập để lấy email')
    }
    try {
      const email = username.includes('@') ? username : (user?.email || '')
      if (!email) return toast.error('Hãy nhập email để nhận mã đặt lại')
      const res = await api.post('/auth/forgot-password', { email })
      const token = res.data?.token
      if (token) {
        toast.success('Đã tạo mã đặt lại (demo): ' + token)
      } else {
        toast.success('Nếu email tồn tại, hệ thống đã gửi liên kết đặt lại')
      }
    } catch (err: any) {
      toast.error('Không gửi được yêu cầu')
    }
  }

  const clearSavedCredentials = () => {
    localStorage.removeItem('remembered-credentials')
    setUsername('')
    setPassword('')
    setRememberMe(false)
    toast.success('Đã xóa thông tin đăng nhập đã lưu')
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <div className="flex justify-center">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-gradient-to-r from-green-500 to-red-500 rounded-xl flex items-center justify-center">
                <span className="text-white font-bold text-xl">MT</span>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">MANHTOAN</h1>
                <p className="text-sm text-gray-600">PLASTIC</p>
              </div>
            </div>
          </div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Hệ thống Tuần tra
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Đăng nhập để tiếp tục
          </p>
          
          {/* QR Code Reference Banner */}
          {qrRef && (
            <div className="mt-4 p-3 bg-green-50 border border-green-200 rounded-lg">
              <div className="flex items-center justify-center">
                <div className="text-center">
                  <p className="text-sm font-medium text-green-800">
                    📱 Đã quét QR Code
                  </p>
                  <p className="text-xs text-green-600 mt-1">
                    Nội dung: "{qrRef}"
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
        
        <form className="mt-8 space-y-6" onSubmit={handleSubmit}>
          <div className="space-y-4">
            <div>
              <label htmlFor="username" className="form-label">
                Tên đăng nhập
              </label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  id="username"
                  name="username"
                  type="text"
                  className="input-field pl-10"
                  placeholder="Nhập tên đăng nhập"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                />
              </div>
            </div>
            
            <div>
              <label htmlFor="password" className="form-label">
                Mật khẩu
              </label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  className="input-field pl-10 pr-10"
                  placeholder="Nhập mật khẩu"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
                <button
                  type="button"
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>
          </div>

          {/* Remember Me Checkbox */}
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <input
                id="remember-me"
                name="remember-me"
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
                className="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 rounded cursor-pointer"
              />
              <label htmlFor="remember-me" className="text-sm text-gray-700 cursor-pointer select-none">
                🔒 Ghi nhớ mật khẩu
              </label>
            </div>
            <button type="button" className="text-sm text-blue-600 hover:text-blue-800 hover:underline transition-colors" onClick={handleForgot}>
              Quên mật khẩu?
            </button>
          </div>

          {/* Saved Credentials Info */}
          {localStorage.getItem('remembered-credentials') && (
            <div className="bg-green-50 border border-green-200 rounded-lg p-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <span className="text-green-600">✅</span>
                  <span className="text-sm text-green-800 font-medium">
                    Thông tin đăng nhập đã được lưu
                  </span>
                </div>
                <button 
                  type="button" 
                  className="text-xs text-red-600 hover:text-red-800 hover:underline font-medium"
                  onClick={clearSavedCredentials}
                >
                  🗑️ Xóa
                </button>
              </div>
            </div>
          )}

          <div className="space-y-3">
            {/* Main Login Buttons - Side by side */}
            <div className="flex space-x-3">
              {/* Main Login Button - Username/Password */}
              <button
                type="submit"
                disabled={isLoading}
                className="btn-primary flex-1 flex justify-center items-center"
              >
                {isLoading ? 'Đang đăng nhập...' : 'Đăng nhập'}
              </button>

              {/* Face Login Button - Small on the right */}
              <button
                type="button"
                onClick={() => setShowFaceAuth(true)}
                disabled={isLoading}
                className="px-4 py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 transition-all duration-200 shadow-lg flex items-center justify-center"
                title="Đăng nhập bằng khuôn mặt"
              >
                <Camera className="w-5 h-5" />
              </button>
            </div>

            {/* Face Login Info */}
            <div className="text-center">
              <p className="text-xs text-gray-500">
                📸 Hoặc bấm nút camera để đăng nhập bằng khuôn mặt
              </p>
            </div>
          </div>
        </form>

        {/* Face Authentication Modal - Only for login */}
          <SimpleFaceAuthModal
            isOpen={showFaceAuth}
            onClose={() => setShowFaceAuth(false)}
            onSuccess={handleFaceLoginSuccess}
            onRegisterSuccess={() => {}}
            mode="verify"
          />
      </div>
    </div>
  )
}

export default LoginPage
