import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { api } from '../utils/api'

export interface User {
  id: number
  username: string
  email: string
  role: 'employee' | 'manager' | 'admin'
  full_name: string
  phone?: string
  is_active: boolean
  created_at: string
  updated_at?: string
}

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
  
  // Actions
  login: (username: string, password: string) => Promise<void>
  logout: () => void
  refreshToken: () => Promise<void>
  setUser: (user: User) => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      isLoading: false,

                  login: async (username: string, password: string) => {
                    set({ isLoading: true })
                    try {
                      const response = await api.post('/auth/login', { username, password })
                      const { access_token, user } = response.data
                      
                      // Set token in API headers
                      api.defaults.headers.common['Authorization'] = `Bearer ${access_token}`
                      
                      // Lưu token vào localStorage để đảm bảo persistence
                      localStorage.setItem('access_token', access_token)
                      localStorage.setItem('user_data', JSON.stringify(user))
                      
                      set({
                        user,
                        token: access_token,
                        isAuthenticated: true,
                        isLoading: false
                      })
                    } catch (error) {
                      set({ isLoading: false })
                      throw error
                    }
                  },

      logout: () => {
        // Remove token from API headers
        delete api.defaults.headers.common['Authorization']
        
        // Xóa token khỏi localStorage
        localStorage.removeItem('access_token')
        localStorage.removeItem('user_data')
        
        set({
          user: null,
          token: null,
          isAuthenticated: false
        })
      },

      refreshToken: async () => {
        try {
          const response = await api.post('/auth/refresh')
          const { access_token, user } = response.data
          
          // Update token in API headers
          api.defaults.headers.common['Authorization'] = `Bearer ${access_token}`
          
          set({
            user,
            token: access_token,
            isAuthenticated: true
          })
        } catch (error) {
          // If refresh fails, logout
          get().logout()
          throw error
        }
      },

      setUser: (user: User) => {
        set({ user })
      }
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated
      })
    }
  )
)

// Ensure axios has Authorization header if token was persisted
try {
  // Thử lấy token từ localStorage trước
  const localToken = localStorage.getItem('access_token')
  if (localToken) {
    api.defaults.headers.common['Authorization'] = `Bearer ${localToken}`
    console.log('🔑 Token loaded from localStorage:', localToken.substring(0, 20) + '...')
  } else {
    // Fallback: thử lấy từ zustand storage
    const state = JSON.parse(localStorage.getItem('auth-storage') || 'null')
    if (state && state.token) {
      api.defaults.headers.common['Authorization'] = `Bearer ${state.token}`
      console.log('🔑 Token loaded from zustand storage:', state.token.substring(0, 20) + '...')
    }
  }
} catch (e) {
  console.error('❌ Error loading token:', e)
}
