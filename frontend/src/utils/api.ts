import axios from 'axios'
import { useAuthStore } from '../stores/authStore'

// SIMPLE NGROK - Gọi trực tiếp ngrok backend với /api prefix
const NUCLEAR_HTTPS_URL = 'https://rolanda-skinless-sue.ngrok-free.dev/api'

export const api = axios.create({
  baseURL: NUCLEAR_HTTPS_URL,
  headers: {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  },
  withCredentials: true,
})

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const storeToken = useAuthStore.getState().token
    const localToken = localStorage.getItem('access_token')
    const token = storeToken || localToken
    
    console.log('🌐 NUCLEAR API REQUEST:', config.url)
    console.log('🌐 NUCLEAR API BASE URL:', NUCLEAR_HTTPS_URL)
    console.log('🌐 NUCLEAR API TOKEN:', token ? `Present (${token.substring(0, 20)}...)` : 'Missing')
    console.log('🌐 Store token:', storeToken ? 'Present' : 'Missing')
    console.log('🌐 Local token:', localToken ? 'Present' : 'Missing')
    
    if (config.data instanceof FormData) {
      delete config.headers['Content-Type']
    }
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
      console.log('🔑 Authorization header set:', `Bearer ${token.substring(0, 20)}...`)
    } else {
      console.warn('⚠️ No token available for request:', config.url)
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  (response) => {
    console.log('✅ NUCLEAR API RESPONSE:', response.status, response.config.url)
    return response
  },
  (error) => {
    console.error('❌ NUCLEAR API RESPONSE ERROR:', error.response?.status, error.config?.url)
    console.error('NUCLEAR Load error:', error)
    
    // Tự động redirect về login khi lỗi authentication
    if (error.response?.status === 401 || error.response?.status === 403) {
      console.log('🔒 Authentication error, redirecting to home')
      useAuthStore.getState().logout()
      // Chỉ redirect nếu không phải trang home
      if (!window.location.pathname.includes('/')) {
        window.location.href = '/'
      }
    }
    
    return Promise.reject(error)
  }
)

export default api
