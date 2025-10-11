import { useState } from 'react'
import { api } from '../utils/api'
import toast from 'react-hot-toast'

const ResetPasswordPage = () => {
  const [token, setToken] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!token || !password) return toast.error('Nhập token và mật khẩu mới')
    setLoading(true)
    try {
      await api.post('/auth/reset-password', { token, new_password: password })
      toast.success('Đổi mật khẩu thành công')
    } catch (e: any) {
      toast.error(e?.response?.data?.detail || 'Đổi mật khẩu thất bại')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
      <form onSubmit={submit} className="card w-full max-w-md space-y-4">
        <h1 className="text-xl font-semibold">Đặt lại mật khẩu</h1>
        <input className="input-field" placeholder="Token" value={token} onChange={e=>setToken(e.target.value)} />
        <input className="input-field" placeholder="Mật khẩu mới" type="password" value={password} onChange={e=>setPassword(e.target.value)} />
        <button className="btn-primary" disabled={loading}>
          {loading ? 'Đang đổi...' : 'Đổi mật khẩu'}
        </button>
      </form>
    </div>
  )
}

export default ResetPasswordPage


