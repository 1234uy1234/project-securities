import React, { useEffect, useState } from 'react'
import { api } from '../utils/api'
import { Location } from '../utils/types'
import { getImageUrl } from '../utils/config'
import { useAuthStore } from '../stores/authStore'
import toast from 'react-hot-toast'
import { Trash2 } from 'lucide-react'

interface RecordRow {
  id: number
  user_id: number
  task_id: number
  location_id: number
  check_in_time: string
  check_out_time?: string
  gps_latitude: number
  gps_longitude: number
  photo_url?: string
  notes?: string
  user?: {
    username: string
    full_name: string
  }
  location?: {
    name: string
  }
  task?: {
    title: string
  }
}

const ReportsPage = () => {
  const [records, setRecords] = useState<RecordRow[]>([])
  const [locations, setLocations] = useState<Location[]>([])
  const [userId, setUserId] = useState('')
  const [locationId, setLocationId] = useState('')
  const [startDate, setStartDate] = useState('')
  const [endDate, setEndDate] = useState('')
  const [recordId, setRecordId] = useState('')
  const [taskId, setTaskId] = useState('')
  const [selectedRecords, setSelectedRecords] = useState<number[]>([])
  const [isDeleting, setIsDeleting] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [deletingRecordId, setDeletingRecordId] = useState<number | null>(null)
  const [showImageModal, setShowImageModal] = useState(false)
  const [selectedImageUrl, setSelectedImageUrl] = useState('')

  const load = async () => {
    setIsLoading(true)
    try {
      // Add timestamp to prevent cache
      const timestamp = Date.now()
      const [r, l] = await Promise.all([
        api.get('/patrol-records/report', { 
          params: {
            user_id: userId || undefined,
            location_id: locationId || undefined,
            start_date: startDate || undefined,
            end_date: endDate || undefined,
            record_id: recordId || undefined,
            task_id: taskId || undefined,
            _t: timestamp, // Prevent cache
          }
        }),
        api.get('/locations/').catch(err => {
          console.error('Locations API error:', err)
          // Nếu lỗi authentication, trả về array rỗng
          if (err?.response?.status === 401 || err?.response?.status === 403) {
            console.log('Authentication error for locations, returning empty array')
            return { data: [] }
          }
          throw err
        })
      ])
      console.log('Loaded records:', r.data.length)
      setRecords(r.data)
      setLocations(l.data || [])
    } catch (err: any) {
      console.error('Load error:', err)
      // Nếu lỗi authentication, redirect về login
      if (err?.response?.status === 401 || err?.response?.status === 403) {
        console.log('Authentication error, redirecting to login')
        useAuthStore.getState().logout()
        window.location.href = '/'
        return
      }
      toast.error(err?.response?.data?.detail || 'Tải báo cáo thất bại')
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => { load() }, [])

  const exportCsv = () => {
    const params = new URLSearchParams()
    if (userId) params.append('user_id', userId)
    if (locationId) params.append('location_id', locationId)
    if (startDate) params.append('start_date', startDate)
    if (endDate) params.append('end_date', endDate)
    if (recordId) params.append('record_id', recordId)
    if (taskId) params.append('task_id', taskId)
    window.open(`https://biuniquely-wreckful-blake.ngrok-free.dev/api/patrol-records/report/csv?${params.toString()}`, '_blank')
  }

  const deleteRecord = async (recordId: number) => {
    if (!confirm('Bạn có chắc chắn muốn xóa bản ghi này? Hành động này không thể hoàn tác!')) {
      return
    }

    // Prevent double-click
    if (isDeleting || deletingRecordId === recordId) {
      console.log('Already deleting record', recordId, ', ignoring request')
      return
    }

    setIsDeleting(true)
    setDeletingRecordId(recordId)
    try {
      console.log('Deleting record:', recordId)
      const response = await api.delete(`/patrol-records/${recordId}`)
      console.log('Delete response:', response.data)
      
      toast.success('Xóa bản ghi thành công!')
      
      // Force reload immediately
      await load()
      
    } catch (error: any) {
      console.error('Error deleting record:', error)
      console.error('Error response:', error.response)
      
      // Handle 404 specifically
      if (error.response?.status === 404) {
        toast.error('Bản ghi đã không tồn tại hoặc đã bị xóa!')
        // Reload to sync UI with server
        await load()
      } else {
        toast.error('Không thể xóa bản ghi: ' + (error.response?.data?.detail || error.message || 'Lỗi không xác định'))
      }
    } finally {
      setIsDeleting(false)
      setDeletingRecordId(null)
    }
  }

  const deleteSelectedRecords = async () => {
    if (selectedRecords.length === 0) {
      toast.error('Vui lòng chọn ít nhất một bản ghi để xóa!')
      return
    }

    if (!confirm(`Bạn có chắc chắn muốn xóa ${selectedRecords.length} bản ghi đã chọn? Hành động này không thể hoàn tác!`)) {
      return
    }

    setIsDeleting(true)
    const deletedIds: number[] = []
    const failedIds: number[] = []
    
    try {
      console.log('Deleting selected records:', selectedRecords)
      
      // Xóa từng record một cách tuần tự
      for (const recordId of selectedRecords) {
        try {
          const response = await api.delete(`/patrol-records/${recordId}`)
          console.log(`Deleted record ${recordId}:`, response.data)
          deletedIds.push(recordId)
        } catch (error: any) {
          console.error(`Failed to delete record ${recordId}:`, error)
          failedIds.push(recordId)
        }
      }
      
      // Update UI based on results
      if (deletedIds.length > 0) {
        if (failedIds.length === 0) {
          toast.success(`Đã xóa thành công ${deletedIds.length} bản ghi!`)
        } else {
          toast.success(`Đã xóa thành công ${deletedIds.length} bản ghi, ${failedIds.length} bản ghi thất bại!`)
        }
      } else {
        toast.error('Không thể xóa bất kỳ bản ghi nào!')
      }
      
      // Force reload from server
      await load()
      setSelectedRecords([])
      
    } catch (error: any) {
      console.error('Error in bulk delete:', error)
      toast.error('Lỗi khi xóa hàng loạt: ' + (error.response?.data?.detail || error.message || 'Lỗi không xác định'))
    } finally {
      setIsDeleting(false)
    }
  }

  const toggleSelectRecord = (recordId: number) => {
    setSelectedRecords(prev => 
      prev.includes(recordId) 
        ? prev.filter(id => id !== recordId)
        : [...prev, recordId]
    )
  }

  const selectAllRecords = () => {
    if (selectedRecords.length === records.length) {
      setSelectedRecords([])
    } else {
      setSelectedRecords(records.map(r => r.id))
    }
  }

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Báo cáo tuần tra</h1>

      <div className="card mb-6">
        <div className="grid md:grid-cols-3 lg:grid-cols-4 gap-3 mb-4">
          <input 
            className="input-field" 
            placeholder="Record ID" 
            value={recordId} 
            onChange={(e) => setRecordId(e.target.value)} 
          />
          <input 
            className="input-field" 
            placeholder="User ID" 
            value={userId} 
            onChange={(e) => setUserId(e.target.value)} 
          />
          <input 
            className="input-field" 
            placeholder="Task ID" 
            value={taskId} 
            onChange={(e) => setTaskId(e.target.value)} 
          />
          <select className="input-field" value={locationId} onChange={(e) => setLocationId(e.target.value)}>
            <option value="">Tất cả vị trí</option>
            {locations.map(l => (
              <option key={l.id} value={l.id}>{l.name}</option>
            ))}
          </select>
        </div>
        
        <div className="grid md:grid-cols-3 gap-3 mb-4">
          <input 
            className="input-field" 
            type="date" 
            placeholder="Từ ngày"
            value={startDate} 
            onChange={(e) => setStartDate(e.target.value)} 
          />
          <input 
            className="input-field" 
            type="date" 
            placeholder="Đến ngày"
            value={endDate} 
            onChange={(e) => setEndDate(e.target.value)} 
          />
          <div className="flex gap-2">
            <button 
              className="btn-primary flex-1" 
              onClick={load}
              disabled={isLoading}
            >
              {isLoading ? 'Đang tải...' : 'Lọc'}
            </button>
            <button 
              className="btn-secondary flex-1" 
              onClick={exportCsv}
              disabled={isLoading}
            >
              Tải CSV
            </button>
            <button 
              className="btn-secondary flex-1" 
              onClick={() => {
                console.log('Manual refresh triggered')
                load()
              }}
              disabled={isLoading}
              title="Làm mới dữ liệu"
            >
              🔄
            </button>
          </div>
        </div>
        
        {selectedRecords.length > 0 && (
          <div className="flex justify-end">
            <button 
              className="btn-danger flex items-center gap-2" 
              onClick={deleteSelectedRecords}
              disabled={isDeleting}
            >
              <Trash2 className="w-4 h-4" />
              {isDeleting ? 'Đang xóa...' : `Xóa ${selectedRecords.length} bản ghi`}
            </button>
          </div>
        )}
      </div>

      {/* Debug Panel - Remove in production */}
      {process.env.NODE_ENV === 'development' && (
        <div className="card mb-4 bg-yellow-50 border-yellow-200">
          <h3 className="text-sm font-semibold text-yellow-800 mb-2">Debug Info:</h3>
          <div className="text-xs text-yellow-700">
            <p>Records count: {records.length}</p>
            <p>Selected records: {selectedRecords.length} - [{selectedRecords.join(', ')}]</p>
            <p>Is loading: {isLoading ? 'Yes' : 'No'}</p>
            <p>Is deleting: {isDeleting ? 'Yes' : 'No'}</p>
            <p>Deleting record ID: {deletingRecordId || 'None'}</p>
            <p>Record IDs: [{records.map(r => r.id).join(', ')}]</p>
          </div>
        </div>
      )}

      <div className="card">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-semibold text-gray-900">
            Kết quả tìm kiếm ({records.length} bản ghi)
            {isLoading && <span className="text-blue-500 ml-2">(Đang tải...)</span>}
            {isDeleting && <span className="text-red-500 ml-2">(Đang xóa...)</span>}
          </h2>
          {(recordId || userId || taskId || locationId || startDate || endDate) && (
            <button 
              className="btn-secondary text-sm"
              onClick={() => {
                setRecordId('')
                setUserId('')
                setTaskId('')
                setLocationId('')
                setStartDate('')
                setEndDate('')
                setSelectedRecords([])
                load()
              }}
            >
              Xóa bộ lọc
            </button>
          )}
        </div>
        
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead>
              <tr className="bg-gray-50">
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <input 
                    type="checkbox" 
                    checked={selectedRecords.length === records.length && records.length > 0}
                    onChange={selectAllRecords}
                    className="rounded border-gray-300"
                  />
                </th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Task</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Location</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Check-in</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Check-out</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ảnh</th>
                <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hành động</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {records.map(r => (
                <tr key={r.id} className={selectedRecords.includes(r.id) ? 'bg-blue-50' : ''}>
                  <td className="px-4 py-2">
                    <input 
                      type="checkbox" 
                      checked={selectedRecords.includes(r.id)}
                      onChange={() => toggleSelectRecord(r.id)}
                      className="rounded border-gray-300"
                    />
                  </td>
                  <td className="px-4 py-2">{r.id}</td>
                  <td className="px-4 py-2">
                    <div>
                      <div className="font-medium">{r.user?.full_name || `User ${r.user_id}`}</div>
                      <div className="text-sm text-gray-500">@{r.user?.username || r.user_id}</div>
                    </div>
                  </td>
                  <td className="px-4 py-2">
                    <div className="text-sm">
                      <div className="font-medium">{r.task?.title || "Check-in tự do"}</div>
                      <div className="text-gray-500">ID: {r.task_id}</div>
                    </div>
                  </td>
                  <td className="px-4 py-2">
                    <div className="text-sm">
                      <div className="font-medium">{r.location?.name || `Location ${r.location_id}`}</div>
                      <div className="text-gray-500">ID: {r.location_id}</div>
                    </div>
                  </td>
                  <td className="px-4 py-2">
                    <div className="text-sm">
                      <div className="font-medium">
                        {new Date(r.check_in_time).toLocaleDateString('vi-VN', { 
                          timeZone: 'Asia/Ho_Chi_Minh',
                          year: 'numeric',
                          month: '2-digit',
                          day: '2-digit'
                        })}
                      </div>
                      <div className="text-gray-500">
                        {new Date(r.check_in_time).toLocaleTimeString('vi-VN', { 
                          timeZone: 'Asia/Ho_Chi_Minh',
                          hour: '2-digit',
                          minute: '2-digit',
                          second: '2-digit'
                        })}
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-2">
                    {r.check_out_time ? (
                      <div className="text-sm">
                        <div className="font-medium">
                          {new Date(r.check_out_time).toLocaleDateString('vi-VN', { 
                            timeZone: 'Asia/Ho_Chi_Minh',
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit'
                          })}
                        </div>
                        <div className="text-gray-500">
                          {new Date(r.check_out_time).toLocaleTimeString('vi-VN', { 
                            timeZone: 'Asia/Ho_Chi_Minh',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit'
                          })}
                        </div>
                      </div>
                    ) : (
                      <span className="text-gray-400">-</span>
                    )}
                  </td>
                  <td className="px-4 py-2">
                    {r.photo_url ? (
                      <div className="flex items-center gap-2">
                        <img 
                          src={getImageUrl(r.photo_url)} 
                          alt="Patrol photo" 
                          className="w-12 h-12 object-cover rounded border cursor-pointer hover:opacity-80"
                          onClick={() => {
                            if (r.photo_url) {
                              setSelectedImageUrl(getImageUrl(r.photo_url));
                              setShowImageModal(true);
                            }
                          }}
                          onLoad={() => {
                            console.log('✅ Image loaded:', r.photo_url);
                          }}
                          onError={(e) => {
                            console.error('❌ Image failed to load:', r.photo_url);
                            // Hide broken image
                            const img = e.target as HTMLImageElement;
                            img.style.display = 'none';
                          }}
                        />
                        <button 
                          className="btn-secondary text-xs"
                          onClick={() => {
                            if (r.photo_url) {
                              setSelectedImageUrl(getImageUrl(r.photo_url));
                              setShowImageModal(true);
                            }
                          }}
                        >
                          Xem ảnh
                        </button>
                      </div>
                    ) : (
                      <span className="text-gray-400 text-sm">Không có ảnh</span>
                    )}
                  </td>
                  <td className="px-4 py-2">
                    <button
                      onClick={() => deleteRecord(r.id)}
                      disabled={isDeleting || deletingRecordId === r.id}
                      className="flex items-center gap-1 px-3 py-1 text-sm bg-red-100 text-red-700 rounded hover:bg-red-200 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                      title={deletingRecordId === r.id ? "Đang xóa..." : "Xóa bản ghi"}
                    >
                      <Trash2 className="w-4 h-4" />
                      {deletingRecordId === r.id ? 'Đang xóa...' : 'Xóa'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Image Modal */}
      {showImageModal && selectedImageUrl && (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-60 p-4">
          <div className="relative max-w-4xl max-h-full">
            <img
              src={selectedImageUrl}
              alt="Ảnh chấm công đầy đủ"
              className="max-w-full max-h-full object-contain rounded-lg"
            />
            <button
              onClick={() => setShowImageModal(false)}
              className="absolute top-4 right-4 bg-black bg-opacity-50 text-white p-2 rounded-full hover:bg-opacity-70 transition-colors"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

export default ReportsPage
