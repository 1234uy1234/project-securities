import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Home, ClipboardList, QrCode, User } from 'lucide-react'
import { useAuthStore } from '../stores/authStore'

const MobileBottomNavigation: React.FC = () => {
  const location = useLocation()
  const { user } = useAuthStore()

  const navigationItems = [
    { to: '/dashboard', label: 'Trang chủ', icon: Home },
    { to: user?.role === 'employee' ? '/employee-dashboard' : '/tasks', label: 'Nhiệm vụ', icon: ClipboardList },
    { to: '/qr-scan', label: 'Quét QR', icon: QrCode },
    { to: '/profile', label: 'Cá nhân', icon: User },
  ]

  const isActive = (path: string) => location.pathname === path

  return (
    <div className="lg:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-40 safe-bottom">
      <div className="flex justify-around">
        {navigationItems.map((item) => {
          const Icon = item.icon
          return (
            <Link
              key={item.to}
              to={item.to}
              className={`flex flex-col items-center py-2 px-3 flex-1 transition-colors ${
                isActive(item.to)
                  ? 'text-green-600'
                  : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              <Icon size={20} className="mb-1" />
              <span className="text-xs font-medium">{item.label}</span>
            </Link>
          )
        })}
      </div>
    </div>
  )
}

export default MobileBottomNavigation
