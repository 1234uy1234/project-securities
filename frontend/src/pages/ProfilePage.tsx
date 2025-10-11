import React from 'react'
import { useAuthStore } from '../stores/authStore'

const ProfilePage = () => {
  const { user } = useAuthStore()

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Hồ sơ cá nhân</h1>
      <div className="card max-w-2xl">
        <div className="space-y-4">
          <div>
            <label className="form-label">Họ và tên</label>
            <p className="text-gray-900">{user?.full_name}</p>
          </div>
          <div>
            <label className="form-label">Tên đăng nhập</label>
            <p className="text-gray-900">{user?.username}</p>
          </div>
          <div>
            <label className="form-label">Email</label>
            <p className="text-gray-900">{user?.email}</p>
          </div>
          <div>
            <label className="form-label">Vai trò</label>
            <p className="text-gray-900 capitalize">{user?.role}</p>
          </div>
          <div>
            <label className="form-label">Số điện thoại</label>
            <p className="text-gray-900">{user?.phone || 'Chưa cập nhật'}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ProfilePage
