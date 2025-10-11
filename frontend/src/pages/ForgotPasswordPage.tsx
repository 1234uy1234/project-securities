import { useState } from 'react'
import { api } from '../utils/api'
import toast from 'react-hot-toast'

const ForgotPasswordPage = () => {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email) return toast.error('Nhập email')
    setLoading(true)
    try {
      const res = await api.post('/auth/forgot-password', { email })
      if (res.data?.token) {
        toast.success('Mã đặt lại (demo): ' + res.data.token)
      } else {
        toast.success('Nếu email tồn tại, liên kết đặt lại đã được gửi')
      }
    } catch (e) {
      toast.error('Không gửi được yêu cầu')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
      <form onSubmit={submit} className="card w-full max-w-md space-y-4">
        <h1 className="text-xl font-semibold">Quên mật khẩu</h1>
        <input className="input-field" type="email" placeholder="Email" value={email} onChange={e=>setEmail(e.target.value)} />
        <button className="btn-primary" disabled={loading}>
          {loading ? 'Đang gửi...' : 'Gửi yêu cầu'}
        </button>
      </form>
    </div>
  )
}

export default ForgotPasswordPage


