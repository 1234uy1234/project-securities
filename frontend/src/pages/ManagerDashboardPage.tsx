import React, { useEffect, useState } from 'react'
import { api } from '../utils/api'

interface Stats {
  users: { total: number; employees: number; managers: number }
  locations: number
  tasks: { total: number; pending: number; in_progress: number; completed: number }
  records: { today: number; week: number }
}

const ManagerDashboardPage = () => {
  const [stats, setStats] = useState<Stats | null>(null)

  const load = async () => {
    const res = await api.get('/stats/overview')
    setStats(res.data)
  }

  useEffect(() => { load() }, [])

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Dashboard Quản lý</h1>
      {!stats ? (
        <p>Đang tải...</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Nhân viên</h3>
            <p className="text-3xl font-bold text-primary-600">{stats.users.employees}</p>
            <p className="text-sm text-gray-600">Tổng: {stats.users.total} | Quản lý: {stats.users.managers}</p>
          </div>
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Vị trí</h3>
            <p className="text-3xl font-bold text-green-600">{stats.locations}</p>
          </div>
          <div className="card">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Nhiệm vụ</h3>
            <p className="text-3xl font-bold text-orange-600">{stats.tasks.total}</p>
            <p className="text-sm text-gray-600">Pending: {stats.tasks.pending} | In progress: {stats.tasks.in_progress} | Completed: {stats.tasks.completed}</p>
          </div>
          <div className="card md:col-span-3">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Ghi nhận tuần tra</h3>
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <p className="text-sm text-gray-600">Hôm nay</p>
                <p className="text-3xl font-bold text-primary-600">{stats.records.today}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Trong tuần</p>
                <p className="text-3xl font-bold text-green-600">{stats.records.week}</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default ManagerDashboardPage
