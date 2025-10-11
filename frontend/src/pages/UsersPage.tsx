import React, { useEffect, useState } from 'react'
import { api } from '../utils/api'
import toast from 'react-hot-toast'
import { useAuthStore } from '../stores/authStore'

type Role = 'employee' | 'manager' | 'admin'

interface UserRow {
  id: number
  username: string
  email: string
  full_name: string
  phone?: string
  role: Role
  is_active: boolean
}

const UsersPage = () => {
  const [users, setUsers] = useState<UserRow[]>([])
  const [username, setUsername] = useState('')
  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')
  const [role, setRole] = useState<Role>('employee')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [showInactive, setShowInactive] = useState(false)

  const [editUser, setEditUser] = useState<UserRow | null>(null)
  const [editFullName, setEditFullName] = useState('')
  const [editEmail, setEditEmail] = useState('')
  const [editRole, setEditRole] = useState<Role>('employee')
  const [editPhone, setEditPhone] = useState('')
  const [newPassword, setNewPassword] = useState('')

  const load = async () => {
    try {
      console.log('Loading users...')
      const res = await api.get('/users/', { 
        params: { include_inactive: showInactive } 
      })
      console.log('Users loaded successfully:', res.data)
      setUsers(res.data)
    } catch (err: any) {
      console.error('Error loading users:', err)
      console.error('Error response:', err?.response?.data)
      console.error('Error status:', err?.response?.status)
      
      if (err?.response?.status === 401) {
        toast.error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.')
        window.location.href = '/'
      } else {
        toast.error(err?.response?.data?.detail || 'Tải danh sách người dùng lỗi')
      }
    }
  }

  useEffect(() => { load() }, [showInactive])

  const createUser = async () => {
    if (!username || !email || !fullName || !password) {
      return toast.error('Điền đủ thông tin bắt buộc')
    }
    setLoading(true)
    try {
      console.log('Creating user with data:', { username, email, full_name: fullName, role, password: '***' })
      const response = await api.post('/users/', {
        username,
        email,
        full_name: fullName,
        role,
        password,
      })
      console.log('User created successfully:', response.data)
      toast.success('Tạo tài khoản thành công')
      setUsername(''); setEmail(''); setFullName(''); setPassword(''); setRole('employee')
      await load()
    } catch (err: any) {
      console.error('Error creating user:', err)
      console.error('Error response:', err?.response?.data)
      console.error('Error status:', err?.response?.status)
      
      if (err?.response?.status === 401) {
        toast.error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.')
        // Redirect to login
        window.location.href = '/'
      } else {
        toast.error(err?.response?.data?.detail || 'Tạo tài khoản thất bại')
      }
    } finally {
      setLoading(false)
    }
  }

  const toggleActive = async (u: UserRow) => {
    if (user && u.id === user.id) {
      return toast.error('Không thể tự khóa tài khoản của chính bạn')
    }
    try {
      await api.put(`/users/${u.id}`, { is_active: !u.is_active })
      toast.success('Cập nhật trạng thái thành công')
      await load()
    } catch (err: any) {
      toast.error('Cập nhật thất bại')
    }
  }

  const startEdit = (u: UserRow) => {
    setEditUser(u)
    setEditFullName(u.full_name)
    setEditEmail(u.email)
    setEditRole(u.role)
    setEditPhone(u.phone || '')
    setNewPassword('') // Reset password field
  }

  const saveEdit = async () => {
    if (!editUser) return
    try {
      const updateData: any = { 
        full_name: editFullName, 
        email: editEmail, 
        role: editRole 
      }
      
      // Chỉ gửi phone nếu có thay đổi
      if (editPhone !== editUser.phone) {
        updateData.phone = editPhone
      }
      
      await api.put(`/users/${editUser.id}`, updateData)
      toast.success('Lưu thay đổi thành công')
      setEditUser(null)
      await load()
    } catch (err: any) {
      toast.error(err?.response?.data?.detail || 'Lưu thất bại')
    }
  }

  const resetPassword = async () => {
    if (!editUser || !newPassword) {
      return toast.error('Nhập mật khẩu mới')
    }
    try {
      await api.put(`/users/${editUser.id}`, { password: newPassword })
      toast.success('Đặt lại mật khẩu thành công')
      setNewPassword('')
    } catch (err: any) {
      toast.error('Đặt lại mật khẩu thất bại')
    }
  }

  const deleteUser = async (u: UserRow) => {
    if (!confirm(`Xóa tài khoản ${u.username}? Tài khoản sẽ bị ẩn khỏi danh sách.`)) return
    try {
      await api.delete(`/users/${u.id}`)
      toast.success('Xóa tài khoản thành công')
      await load()
    } catch (err: any) {
      toast.error('Xóa thất bại')
    }
  }

  const hardDeleteUser = async (u: UserRow) => {
    if (!confirm(`XÓA HOÀN TOÀN tài khoản ${u.username}? Hành động này KHÔNG THỂ HOÀN TÁC!`)) return
    try {
      // Gọi API để xóa hoàn toàn (cần thêm endpoint này ở backend)
      await api.delete(`/users/${u.id}/hard-delete`)
      toast.success('Xóa hoàn toàn tài khoản thành công')
      await load()
    } catch (err: any) {
      toast.error('Xóa hoàn toàn thất bại')
    }
  }

  const { user } = useAuthStore()

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Quản lý nhân viên</h1>

      {user?.role === 'admin' && (
      <div className="card mb-6">
        <h2 className="text-lg font-semibold mb-3">Tạo tài khoản nhanh</h2>
        <div className="grid md:grid-cols-5 gap-3">
          <input className="form-input" placeholder="Username" value={username} onChange={(e) => setUsername(e.target.value)} />
          <input className="form-input" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <input className="form-input" placeholder="Họ tên" value={fullName} onChange={(e) => setFullName(e.target.value)} />
          <select className="form-input" value={role} onChange={(e) => setRole(e.target.value as Role)}>
            <option value="employee">Employee</option>
            <option value="manager">Manager</option>
            <option value="admin">Admin</option>
          </select>
          <input className="form-input" placeholder="Mật khẩu" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </div>
        <div className="mt-3">
          <button className="btn-primary" onClick={createUser} disabled={loading}>{loading ? 'Đang tạo...' : 'Tạo tài khoản'}</button>
        </div>
      </div>
      )}

      <div className="card">
        <div className="flex justify-between items-center mb-3">
          <h2 className="text-lg font-semibold">
            {showInactive ? 'Tất cả người dùng (bao gồm đã khóa)' : 'Danh sách người dùng đang hoạt động'}
          </h2>
          {user?.role === 'admin' && (
            <div className="flex items-center space-x-2">
              <label className="flex items-center space-x-2 text-sm">
                <input
                  type="checkbox"
                  checked={showInactive}
                  onChange={(e) => setShowInactive(e.target.checked)}
                  className="rounded border-gray-300 text-green-600 focus:ring-green-500"
                />
                <span>Hiển thị tài khoản đã khóa</span>
              </label>
            </div>
          )}
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr className="bg-gray-50">
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Username</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Họ tên</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Vai trò</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trạng thái</th>
                <th className="px-4 py-2"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {users.map(u => (
                <tr key={u.id}>
                  <td className="px-4 py-2">{u.id}</td>
                  <td className="px-4 py-2">{u.username}</td>
                  <td className="px-4 py-2">{u.email}</td>
                  <td className="px-4 py-2">{u.full_name}</td>
                  <td className="px-4 py-2 capitalize">{u.role}</td>
                  <td className="px-4 py-2">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                      u.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {u.is_active ? 'Hoạt động' : 'Đã khóa'}
                    </span>
                  </td>
                  <td className="px-4 py-2 text-right space-x-2">
                    <button className="btn-secondary" onClick={() => startEdit(u)}>Sửa</button>
                    {(!user || u.id !== user.id) && (
                      <>
                        {u.is_active ? (
                          <button className="btn-danger" onClick={() => deleteUser(u)}>Xóa/Ẩn</button>
                        ) : (
                          <>
                            <button className="btn-primary" onClick={() => toggleActive(u)}>Khôi phục</button>
                            {user?.role === 'admin' && (
                              <button className="btn-danger" onClick={() => hardDeleteUser(u)}>Xóa hoàn toàn</button>
                            )}
                          </>
                        )}
                        <button className="btn-secondary" onClick={() => toggleActive(u)}>
                          {u.is_active ? 'Khóa' : 'Mở khóa'}
                        </button>
                      </>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {editUser && (
        <div className="card mt-6">
          <h2 className="text-lg font-semibold mb-3">Sửa tài khoản: {editUser.username}</h2>
          
          {/* Thông tin cơ bản */}
          <div className="grid md:grid-cols-4 gap-3 mb-4">
            <div>
              <label className="form-label">Họ tên</label>
              <input 
                className="form-input" 
                placeholder="Nhập họ tên" 
                value={editFullName} 
                onChange={(e) => setEditFullName(e.target.value)} 
              />
            </div>
            <div>
              <label className="form-label">Email</label>
              <input 
                className="form-input" 
                placeholder="Nhập email" 
                value={editEmail} 
                onChange={(e) => setEditEmail(e.target.value)} 
              />
            </div>
            <div>
              <label className="form-label">Số điện thoại</label>
              <input 
                className="form-input" 
                placeholder="Nhập số điện thoại" 
                value={editPhone} 
                onChange={(e) => setEditPhone(e.target.value)} 
              />
            </div>
            <div>
              <label className="form-label">Vai trò</label>
              <select 
                className="form-input" 
                value={editRole} 
                onChange={(e) => setEditRole(e.target.value as Role)}
              >
                <option value="employee">Employee</option>
                <option value="manager">Manager</option>
                <option value="admin">Admin</option>
              </select>
            </div>
          </div>

          {/* Đặt lại mật khẩu */}
          <div className="border-t pt-4 mb-4">
            <h3 className="text-md font-medium text-gray-900 mb-3">Đặt lại mật khẩu</h3>
            <div className="grid md:grid-cols-3 gap-3">
              <div className="md:col-span-2">
                <label className="form-label">Mật khẩu mới</label>
                <input 
                  className="form-input" 
                  type="password" 
                  placeholder="Nhập mật khẩu mới" 
                  value={newPassword} 
                  onChange={(e) => setNewPassword(e.target.value)} 
                />
              </div>
              <div className="flex items-end">
                <button 
                  className="btn-primary w-full" 
                  onClick={resetPassword}
                  disabled={!newPassword}
                >
                  Đặt lại mật khẩu
                </button>
              </div>
            </div>
          </div>

          {/* Nút hành động */}
          <div className="flex gap-2">
            <button className="btn-primary" onClick={saveEdit}>Lưu thay đổi</button>
            <button className="btn-secondary" onClick={() => setEditUser(null)}>Hủy</button>
          </div>
        </div>
      )}
    </div>
  )
}

export default UsersPage
