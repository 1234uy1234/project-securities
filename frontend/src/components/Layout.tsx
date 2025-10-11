import React, { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuthStore } from '../stores/authStore'
import MobileBottomNavigation from './MobileBottomNavigation'
import { Menu, X, Home, ClipboardList, QrCode, Users, MapPin, BarChart3, Settings, LogOut, User, Smartphone, Square, Bell } from 'lucide-react'

interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const { user, logout } = useAuthStore()
  const location = useLocation()
  const navigate = useNavigate()
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  const handleLogout = () => {
    logout()
    navigate('/')
  }

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen)
  }

  const closeMobileMenu = () => {
    setIsMobileMenuOpen(false)
  }

  // Navigation items based on user role
  const navigationItems = [
    { to: '/dashboard', label: 'Dashboard', icon: Home },
    { to: '/tasks', label: 'Nhiệm vụ', icon: ClipboardList },
    { to: '/qr-scan', label: 'Quét QR', icon: QrCode },
    { to: '/push-notifications', label: 'Thông báo', icon: Bell },
    ...(user?.role === 'manager' || user?.role === 'admin' ? [
      { to: '/admin-dashboard', label: 'Admin Dashboard', icon: BarChart3 },
      { to: '/reports', label: 'Báo cáo', icon: BarChart3 },
      { to: '/users', label: 'Nhân viên', icon: Users },
    ] : [
      { to: '/employee-dashboard', label: 'Nhiệm vụ của tôi', icon: ClipboardList },
    ]),
  ]

  const isActive = (path: string) => location.pathname === path

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile Header */}
      <div className="lg:hidden bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between safe-top">
        <div className="flex items-center space-x-2">
          <div className="w-10 h-10 bg-gradient-to-r from-green-500 via-green-400 to-emerald-500 rounded-xl flex items-center justify-center shadow-lg">
            <span className="text-white font-bold text-base">MT</span>
          </div>
          <div>
            <span className="text-lg font-bold text-gray-900">MANHTOAN</span>
            <p className="text-xs text-green-600 font-medium">Smart Patrol</p>
          </div>
        </div>
        
        <button
          onClick={toggleMobileMenu}
          className="p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100"
        >
          {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile Menu Overlay */}
      {isMobileMenuOpen && (
        <div className="lg:hidden fixed inset-0 z-50 bg-black bg-opacity-50" onClick={closeMobileMenu}>
          <div className="fixed inset-y-0 right-0 w-64 bg-white shadow-lg" onClick={e => e.stopPropagation()}>
            <div className="p-4">
              <div className="flex items-center space-x-3 mb-6">
                <div className="w-12 h-12 bg-gradient-to-r from-green-500 via-green-400 to-emerald-500 rounded-xl flex items-center justify-center shadow-lg">
                  <span className="text-white font-bold text-lg">MT</span>
                </div>
                <div>
                  <span className="text-lg font-bold text-gray-900">MANHTOAN</span>
                  <p className="text-xs text-green-600 font-medium">Smart Patrol</p>
                </div>
              </div>

              <nav className="space-y-2">
                {navigationItems.map((item) => {
                  const Icon = item.icon
                  return (
                    <Link
                      key={item.to}
                      to={item.to}
                      onClick={closeMobileMenu}
                      className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                        isActive(item.to)
                          ? 'bg-green-100 text-green-700 border-l-4 border-green-500'
                          : 'text-gray-700 hover:bg-gray-100'
                      }`}
                    >
                      <Icon size={20} />
                      <span>{item.label}</span>
                    </Link>
                  )
                })}
              </nav>

              <div className="mt-8 border-t pt-4">
                <div className="flex items-center space-x-3 px-4 py-3 mb-3">
                  <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                    <User size={16} />
                  </div>
                  <div>
                    <p className="font-medium">{user?.full_name || user?.username}</p>
                    <p className="text-sm text-gray-500">{user?.role}</p>
                  </div>
                </div>
                <button
                  onClick={handleLogout}
                  className="w-full flex items-center justify-center space-x-2 px-4 py-3 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-xl hover:from-red-600 hover:to-red-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
                >
                  <LogOut size={16} />
                  <span className="font-medium">Đăng xuất</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Desktop Sidebar */}
      <div className="hidden lg:flex lg:flex-col lg:w-64 lg:fixed lg:inset-y-0 lg:z-50">
        <div className="flex flex-col flex-grow bg-gray-900 pt-5 pb-4 overflow-y-auto">
          <div className="flex items-center flex-shrink-0 px-4">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-gradient-to-r from-green-500 via-green-400 to-emerald-500 rounded-xl flex items-center justify-center shadow-lg">
                <span className="text-white font-bold text-xl">MT</span>
              </div>
              <div>
                <h1 className="text-xl font-bold text-white">MANHTOAN</h1>
                <p className="text-xs text-green-400 font-medium">Smart Patrol System</p>
              </div>
            </div>
          </div>
          
          <nav className="mt-8 flex-1 px-2 space-y-1">
            {navigationItems.map((item) => {
              const Icon = item.icon
              return (
                <Link
                  key={item.to}
                  to={item.to}
                  className={`nav-link ${isActive(item.to) ? 'active' : ''}`}
                >
                  <Icon className="w-5 h-5" />
                  {item.label}
                </Link>
              )
            })}
          </nav>
          
          <div className="flex-shrink-0 px-4 py-4 border-t border-gray-700">
            <div className="flex items-center space-x-3 mb-3">
              <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                <User className="w-6 h-6 text-gray-600" />
              </div>
              <div>
                <p className="text-white font-medium">{user?.full_name || user?.username}</p>
                <p className="text-gray-400 text-sm">{user?.role}</p>
              </div>
            </div>
            <button 
              onClick={handleLogout} 
              className="w-full flex items-center justify-center space-x-2 px-4 py-3 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-xl hover:from-red-600 hover:to-red-700 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
            >
              <LogOut className="w-4 h-4" />
              <span className="font-medium">Đăng xuất</span>
            </button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="lg:pl-64">
        <main className="min-h-screen pb-20 lg:pb-0">
          {children}
        </main>
      </div>

      {/* Mobile Bottom Navigation */}
      <MobileBottomNavigation />
    </div>
  )
}

export default Layout
