import React, { useState, useEffect } from 'react';
import { api } from '../utils/api';
import { useAuthStore } from '../stores/authStore';
import toast from 'react-hot-toast';
import FlowStepProgress from '../components/FlowStepProgress';
import CheckinDetailModal from '../components/CheckinDetailModal';
import { PatrolTask } from '../utils/types';

interface CheckinRecord {
  id: number;
  user_name: string;
  user_username: string;
  task_title: string;
  location_name: string;
  check_in_time: string | null;
  check_out_time: string | null;
  photo_url: string | null;  // Ảnh check-in
  checkout_photo_url: string | null;  // Ảnh check-out
  notes: string;
  task_id?: number;
  location_id?: number;
  gps_latitude?: number;
  gps_longitude?: number;
}


const AdminDashboardPage: React.FC = () => {
  const { user } = useAuthStore();
  const [records, setRecords] = useState<CheckinRecord[]>([]);
  const [tasks, setTasks] = useState<PatrolTask[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [lastUpdate, setLastUpdate] = useState<Date>(new Date());
  const [newCheckins, setNewCheckins] = useState<CheckinRecord[]>([]);
  const [showTasks, setShowTasks] = useState(false);
  const [selectedCheckinRecord, setSelectedCheckinRecord] = useState<CheckinRecord | null>(null);
  const [showCheckinModal, setShowCheckinModal] = useState(false);

  useEffect(() => {
    if (user?.role === 'admin' || user?.role === 'manager') {
      fetchCheckinRecords();
      fetchTasks();
      
      // Auto refresh every 5 seconds for real-time updates
      const interval = setInterval(() => {
        fetchCheckinRecords(true);
        fetchTasks();
      }, 5000);
      
      // Listen for checkin success events
      const handleCheckinSuccess = (event: CustomEvent) => {
        console.log('🎉 ADMIN: Checkin success event received:', event.detail);
        console.log('🎉 ADMIN: Event detail:', JSON.stringify(event.detail, null, 2));
        
        // Immediate refresh when checkin happens
        Promise.all([
          fetchCheckinRecords(true),
          fetchTasks()
        ]).then(() => {
          console.log('🎉 ADMIN: Data refreshed successfully after checkin');
          toast.success('🔄 Đã cập nhật dữ liệu sau khi chấm công!');
        }).catch((error) => {
          console.error('❌ ADMIN: Error refreshing data:', error);
          toast.error('❌ Lỗi cập nhật dữ liệu');
        });
      };
      
      window.addEventListener('checkin-success', handleCheckinSuccess as EventListener);
      
      return () => {
        clearInterval(interval);
        window.removeEventListener('checkin-success', handleCheckinSuccess as EventListener);
      };
    }
  }, [user]);

  const fetchCheckinRecords = async (silent = false) => {
    try {
      const response = await api.get('/checkin/admin/all-records');
      const newRecords = response.data;
      
      // Debug: Check records
      console.log('📊 ADMIN: Total records:', newRecords.length);
      console.log('📊 ADMIN: Latest records:', newRecords.slice(0, 3));
      console.log('📊 ADMIN: All records:', newRecords);
      
      if (!silent && records.length > 0) {
        // Check for new checkins
        const newCheckinsFound = newRecords.filter((newRecord: CheckinRecord) => 
          !records.some(record => record.id === newRecord.id)
        );
        
        if (newCheckinsFound.length > 0) {
          setNewCheckins(newCheckinsFound);
          newCheckinsFound.forEach((checkin: CheckinRecord) => {
            toast.success(
              `🎉 ${checkin.user_name} vừa hoàn thành nhiệm vụ "${checkin.task_title}"!`,
              { duration: 5000 }
            );
          });
        }
      }
      
      setRecords(newRecords);
      setLastUpdate(new Date());
    } catch (error: any) {
      console.error('Error fetching checkin records:', error);
      setError(error.response?.data?.detail || 'Có lỗi xảy ra');
    } finally {
      setLoading(false);
    }
  };

  const fetchTasks = async () => {
    try {
      console.log('🔍 ADMIN DASHBOARD: Fetching tasks...');
      const response = await api.get('/patrol-tasks/');
      const list = response.data as any[];

      console.log('🔍 ADMIN DASHBOARD: Fetched tasks:', list);
      list.forEach((task, index) => {
        console.log(`🔍 ADMIN DASHBOARD: Task ${index + 1}:`, {
          id: task.id,
          title: task.title,
          stops: task.stops,
          stopsLength: task.stops ? task.stops.length : 0
        });
      });

      setTasks(list);
      console.log('📋 Tasks fetched:', list.length);
      console.log('📋 Task details:', list.map(t => ({ id: t.id, title: t.title, stops: t.stops?.length || 0 })));
      console.log('📋 All tasks:', list);
    } catch (error: any) {
      console.error('❌ ADMIN DASHBOARD: Error fetching tasks:', error);
      console.error('❌ ADMIN DASHBOARD: Error response:', error.response);
      toast.error('Không thể tải danh sách nhiệm vụ: ' + (error.response?.data?.detail || error.message));
    }
  };

  const deleteTask = async (taskId: number) => {
    if (!confirm('Bạn có chắc chắn muốn xóa nhiệm vụ này?')) {
      return;
    }
    
    try {
      await api.delete(`/patrol-tasks/${taskId}`);
      toast.success('Xóa nhiệm vụ thành công!');
      fetchTasks();
    } catch (error: any) {
      console.error('Error deleting task:', error);
      toast.error('Không thể xóa nhiệm vụ: ' + (error.response?.data?.detail || 'Lỗi không xác định'));
    }
  };

  const deleteRecord = async (recordId: number) => {
    if (!confirm('Bạn có chắc chắn muốn xóa bản ghi chấm công này?')) {
      return;
    }
    
    try {
      await api.delete(`/patrol-records/${recordId}`);
      toast.success('Xóa bản ghi chấm công thành công!');
      fetchCheckinRecords();
    } catch (error: any) {
      console.error('Error deleting record:', error);
      toast.error('Không thể xóa bản ghi: ' + (error.response?.data?.detail || 'Lỗi không xác định'));
    }
  };

  const formatDateTime = (dateString: string) => {
    try {
      if (!dateString) return '-'
      const d = new Date(dateString)
      if (isNaN(d.getTime())) return '-'
      // Sử dụng múi giờ Việt Nam (UTC+7)
      return d.toLocaleString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
    } catch (e) {
      return '-'
    }
  };

  const findCheckinRecord = (taskId: number, locationId: number, scheduledTime?: string, taskCreatedAt?: string): CheckinRecord | null => {
    // LOGIC ĐƠN GIẢN: Tìm checkin record cho task và location, không cần kiểm tra thời gian phức tạp
    console.log('🔍 Finding checkin record for task:', taskId, 'location:', locationId);
    
    // Tìm tất cả checkin records cho task và location này
    const matchingRecords = records.filter(record => 
      record.task_id === taskId && 
      record.location_id === locationId &&
      record.check_in_time // Phải có check_in_time
    );
    
    console.log('📋 Matching records count:', matchingRecords.length);
    console.log('Available records:', records.map(r => ({
      id: r.id,
      task_id: r.task_id,
      location_id: r.location_id,
      check_in_time: r.check_in_time,
      check_out_time: r.check_out_time,
      photo_url: r.photo_url
    })));
    
    if (matchingRecords.length > 0) {
      // Lấy record đầu tiên (hoặc có thể lấy record mới nhất)
      const found = matchingRecords[0];
      console.log('✅ Found checkin record:', {
        task_id: found.task_id,
        location_id: found.location_id,
        check_in_time: found.check_in_time,
        check_out_time: found.check_out_time,
        photo_url: found.photo_url
      });
      return found;
    }
    
    console.log('❌ No checkin record found');
    return null;
  };

  const updateTaskStatus = async (taskId: number, status: string) => {
    try {
      await api.put(`/patrol-tasks/${taskId}`, { status });
      console.log(`✅ Updated task ${taskId} status to ${status}`);
    } catch (error) {
      console.error(`❌ Error updating task ${taskId} status:`, error);
    }
  };

  // Hàm kiểm tra trạng thái vị trí dựa trên thời gian
  const getLocationStatus = (stop: any, task: any) => {
    // console.log(`🔍 getLocationStatus called for task ${task.id}, stop ${stop.location_id}, sequence ${stop.sequence}`);
    // console.log('🔍 Stop data:', stop);
    // console.log('🔍 Task data:', { id: task.id, title: task.title });
    // Kiểm tra null safety
    if (!stop || !task) {
      return { status: 'pending', color: 'gray', text: 'Chưa xác định' };
    }
    
  // SỬ DỤNG HÀM findCheckinRecord ĐÃ ĐƯỢC SỬA
  const hasCheckin = findCheckinRecord(task.id, stop.location_id, stop.scheduled_time, task.created_at);
    // Sử dụng múi giờ Việt Nam (UTC+7)
    const now = new Date();
    
    const vietnamTime = new Date(now.toLocaleString("en-US", {timeZone: "Asia/Ho_Chi_Minh"}));
    const currentDate = vietnamTime.toISOString().split('T')[0]; // YYYY-MM-DD
    const currentTime = vietnamTime.getHours() * 60 + vietnamTime.getMinutes(); // phút trong ngày
    
    // Debug: Check current time
    
    // Lấy thời gian dự kiến cho mốc này
    let scheduledTime = null;
    if (stop.scheduled_time && stop.scheduled_time !== 'Chưa xác định') {
      const [scheduledHour, scheduledMinute] = stop.scheduled_time.split(':').map(Number);
      scheduledTime = scheduledHour * 60 + scheduledMinute; // phút trong ngày
      // Using stop.scheduled_time
    } else {
      // Tính toán dựa trên sequence nếu không có scheduled_time
      try {
        const schedule = JSON.parse(task.schedule_week);
        if (schedule.startTime) {
          const startHour = parseInt(schedule.startTime.split(':')[0]);
          const startMinute = parseInt(schedule.startTime.split(':')[1]);
          const stopHour = startHour + stop.sequence;
          scheduledTime = stopHour * 60 + startMinute;
          // Calculated from schedule
        }
      } catch (e) {
        // Error parsing schedule
      }
    }
    
    // Lấy ngày của task từ created_at
    let taskDate = null;
    try {
      if (task.created_at) {
        const taskCreatedDate = new Date(task.created_at);
        taskDate = taskCreatedDate.toISOString().split('T')[0];
      }
    } catch (e) {
      console.log('Error parsing task date:', e);
    }
    
    // Nếu chưa chấm công
    if (!scheduledTime) {
      return { status: 'pending', color: 'gray', text: 'Chưa xác định' };
    }
    
    // Kiểm tra ngày của task so với ngày hiện tại
    const isToday = taskDate === currentDate;
    const isPastTask = taskDate && taskDate < currentDate; // Task hôm qua hoặc trước đó
    const isFutureTask = taskDate && taskDate > currentDate; // Task tương lai
    
    // LOGIC CỰC ĐƠN GIẢN: Có checkin record = hoàn thành (giống như Report)
    if (hasCheckin && hasCheckin.check_in_time) {
      console.log(`✅ Location ${stop.location_id} has checkin record - showing as completed`);
      return { status: 'completed', color: 'green', text: 'Đã chấm công' };
    }
    
    // Kiểm tra xem có quá hạn không (chỉ áp dụng cho task hôm nay)
    const isOverdue = isToday && currentTime > scheduledTime + 15; // Quá 15 phút
    
    // Nếu quá hạn, báo "Quá hạn" và không thể check-in nữa
    if (isOverdue) {
      console.log(`⏰ Location ${stop.location_id} is overdue - more than 15 minutes past scheduled time`);
      return { status: 'overdue', color: 'red', text: 'Quá hạn' };
    }
    
    // Debug: Time calculations
    
    // FALLBACK: Kiểm tra trạng thái completed từ stops (backend đã kiểm tra thời gian)
    if (stop.completed) {
      console.log(`✅ Task ${task.id} stop ${stop.location_id} is completed from stops:`, stop);
      
      // Cập nhật trạng thái task nếu cần
      if (task.status !== 'completed') {
        console.log(`🔄 Updating task ${task.id} status to completed`);
        // Gọi API để cập nhật trạng thái task
        updateTaskStatus(task.id, 'completed');
      }
      
      return { status: 'completed', color: 'green', text: 'Đã chấm công' };
    }
    
    // Xử lý task quá khứ (hôm qua hoặc trước đó) - CHỈ nếu chưa chấm công
    if (isPastTask) {
      // Kiểm tra lại xem có checkin record không (double check)
      if (hasCheckin && hasCheckin.check_in_time) {
        console.log('✅ PAST TASK COMPLETED: Task hôm qua đã chấm công');
        return { status: 'completed', color: 'green', text: 'Đã chấm công' };
      } else {
        console.log('🔴 PAST TASK OVERDUE: Task hôm qua chưa chấm công');
        return { status: 'overdue', color: 'red', text: 'Quá hạn (chưa chấm công)' };
      }
    }
    
    // Xử lý task tương lai
    if (isFutureTask) {
      console.log('⚪ FUTURE TASK: Chưa đến ngày');
      return { status: 'pending', color: 'gray', text: 'Chưa đến ngày' };
    }
    
    // Xử lý task hôm nay
    if (isToday) {
      // Nếu chưa chấm công
      if (isOverdue) {
        console.log('🔴 OVERDUE: Past deadline');
        return { status: 'overdue', color: 'red', text: 'Chưa chấm công (quá hạn)' };
      } else {
        console.log('🔵 PENDING: Waiting for checkin');
        return { status: 'pending', color: 'blue', text: 'Chờ chấm công' };
      }
    }
    
    // Fallback - không xác định được ngày
    console.log('⚪ UNKNOWN: Cannot determine task date');
    return { status: 'pending', color: 'gray', text: 'Chưa xác định' };
  };

  const handleStepClick = async (step: any) => {
    console.log('🔍 ADMIN: handleStepClick called with step:', step);
    console.log('🔍 ADMIN: step.taskId:', step.taskId);
    console.log('🔍 ADMIN: step.locationId:', step.locationId);
    console.log('🔍 ADMIN: step.scheduledTime:', step.scheduledTime);
    
    if (step.taskId && step.locationId) {
      // Tìm task để lấy created_at
      const task = tasks.find(t => t.id === step.taskId);
      let record = findCheckinRecord(step.taskId, step.locationId, step.scheduledTime, task?.created_at);
      console.log('🔍 ADMIN: Found record:', record);
      console.log('🔍 ADMIN: Record photo_url:', record?.photo_url);
      
      // Nếu không tìm thấy record trong local state, thử fetch từ API
      if (!record) {
        console.log('🔍 ADMIN: Record not found in local state, fetching from API...');
        try {
          const response = await api.get('/checkin/admin/all-records');
          const allRecords = response.data;
          console.log('🔍 ADMIN: All records from API:', allRecords.length);
          
          // LOGIC THÔNG MINH: Chỉ hiển thị check-in cho mốc thời gian gần nhất
          const allLocationRecords = allRecords.filter((r: any) => 
            r.location_id === step.locationId
          );
          console.log('🔍 ADMIN: Location records found:', allLocationRecords.length);
          console.log('🔍 ADMIN: Location records:', allLocationRecords);
          
          if (allLocationRecords.length > 0) {
            // Nếu có nhiều records, tìm record có thời gian gần nhất với scheduled_time của stop
            const stopScheduledTime = step.scheduledTime;
            if (stopScheduledTime && stopScheduledTime !== 'Chưa xác định') {
              const scheduledHour = parseInt(stopScheduledTime.split(':')[0]);
              const scheduledMinute = parseInt(stopScheduledTime.split(':')[1]);
              const scheduledTimeInMinutes = scheduledHour * 60 + scheduledMinute;
              
              record = allLocationRecords.reduce((closest: any, current: any) => {
                if (!current.check_in_time) return closest;
                
                const checkinTime = new Date(current.check_in_time);
                const checkinTimeInMinutes = checkinTime.getHours() * 60 + checkinTime.getMinutes();
                
                const currentDiff = Math.abs(checkinTimeInMinutes - scheduledTimeInMinutes);
                const closestDiff = closest ? Math.abs(
                  new Date(closest.check_in_time).getHours() * 60 + 
                  new Date(closest.check_in_time).getMinutes() - scheduledTimeInMinutes
                ) : Infinity;
                
                return currentDiff < closestDiff ? current : closest;
              }, null);
              
              // Chỉ hiển thị nếu check-in trong vòng 15 phút từ thời gian được giao
              if (record && record.check_in_time) {
                const checkinDate = new Date(record.check_in_time);
                const checkinHour = checkinDate.getHours();
                const checkinMinute = checkinDate.getMinutes();
                const checkinTimeInMinutes = checkinHour * 60 + checkinMinute;
                
                // Kiểm tra xem check-in có trong vòng 15 phút từ scheduled_time không
                const timeDiff = checkinTimeInMinutes - scheduledTimeInMinutes;
                console.log('🔍 ADMIN: Time diff:', timeDiff, 'minutes');
                
                // Chỉ hiển thị nếu check-in trong khoảng 0-15 phút sau scheduled_time
                if (timeDiff < 0 || timeDiff > 15) {
                  console.log('🔍 ADMIN: Record rejected due to time diff:', timeDiff);
                  record = null;
                }
              }
            }
          }
          
          console.log('🔍 ADMIN: Found record from API:', record);
          console.log('🔍 ADMIN: Final record photo_url:', record?.photo_url);
        } catch (error) {
          console.error('Error fetching records from API:', error);
        }
      }
      
      console.log('🔍 ADMIN: Final record to show in modal:', record);
      console.log('🔍 ADMIN: Final record photo_url:', record?.photo_url);
      
      // Logic đơn giản: Nếu có checkin record thì hiển thị
      if (record) {
        // Tìm task để lấy thông tin stop
        const task = tasks.find(t => t.id === step.taskId);
        const stop = task?.stops?.find(s => s.location_id === step.locationId);
        
        console.log(`✅ Showing checkin record for Stop ${stop?.sequence} (${stop?.scheduled_time}) - Has checkin record`);
        
        // Tạo record với thông tin đơn giản
        const enhancedRecord: CheckinRecord = {
          ...record,
          notes: `Vị trí "${step.name}" đã được chấm công. Thời gian: ${record.check_in_time ? new Date(record.check_in_time).toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }) : 'Chưa xác định'}. Trạng thái: Đã hoàn thành`
        };
        
        console.log('🔍 ADMIN: Enhanced record photo_url:', enhancedRecord.photo_url);
        console.log('🔍 ADMIN: Enhanced record:', enhancedRecord);
        
        setSelectedCheckinRecord(enhancedRecord);
        setShowCheckinModal(true);
      } else {
        // Tìm task để lấy thông tin
        const task = tasks.find(t => t.id === step.taskId);
        console.log('Found task:', task);
        
        // Tạo record giả để hiển thị thông tin vị trí chưa chấm công
        const mockRecord: CheckinRecord = {
          id: 0,
          user_name: task?.assigned_user_name || 'Nhân viên',
          user_username: 'user',
          task_title: task?.title || 'Nhiệm vụ',
          location_name: step.name,
          check_in_time: null, // Sử dụng null thay vì empty string
          check_out_time: null,
          photo_url: null,
          checkout_photo_url: null,
          notes: `Vị trí "${step.name}" chưa được chấm công. Thời gian dự kiến: ${step.scheduledTime || 'Chưa xác định'}. Trạng thái: ${step.statusText || 'Chưa xác định'}`,
          gps_latitude: undefined,
          gps_longitude: undefined
        };
        console.log('Showing mock record:', mockRecord);
        setSelectedCheckinRecord(mockRecord);
        setShowCheckinModal(true);
      }
    } else {
      console.log('Missing taskId or locationId:', { taskId: step.taskId, locationId: step.locationId });
    }
  };

  const getStatusBadge = (record: CheckinRecord) => {
    if (record.check_out_time) {
      return <span className="px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs">Hoàn thành</span>;
    } else {
      return <span className="px-2 py-1 bg-yellow-100 text-yellow-800 rounded-full text-xs">Đang làm</span>;
    }
  };

  if (user?.role !== 'admin' && user?.role !== 'manager') {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600 mb-4">Không có quyền truy cập</h1>
          <p className="text-gray-600">Chỉ admin và manager mới được truy cập trang này</p>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Đang tải dữ liệu...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header với thông tin real-time */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">📊 Admin Dashboard</h1>
              <p className="mt-2 text-gray-600">Quản lý chấm công và tuần tra real-time</p>
            </div>
            <div className="text-right">
              <div className="flex items-center space-x-4">
                <button
                  onClick={() => {
                    console.log('🔄 Manual refresh triggered');
                    fetchCheckinRecords();
                    fetchTasks();
                    toast.success('Đã làm mới dữ liệu');
                  }}
                  className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors text-sm"
                >
                  🔄 Làm mới
                </button>
                <div>
                  <div className="text-sm text-gray-500">Cập nhật lần cuối:</div>
                  <div className="text-sm font-medium text-gray-700">
                    {lastUpdate ? lastUpdate.toLocaleTimeString('vi-VN') : '-'}
                  </div>
                  <div className="flex items-center mt-1">
                    <div className="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse"></div>
                    <span className="text-xs text-green-600">Auto-refresh: 10s</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Thống kê nhanh */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8">
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng chấm công</p>
                <p className="text-2xl font-bold text-gray-900">{records.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Hoàn thành</p>
                <p className="text-2xl font-bold text-gray-900">
                  {records.filter(r => r.check_out_time).length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Đang làm</p>
                <p className="text-2xl font-bold text-gray-900">
                  {records.filter(r => !r.check_out_time).length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Hôm nay</p>
                <p className="text-2xl font-bold text-gray-900">
                  {records.filter(r => {
                    const today = new Date().toDateString();
                    return r.check_in_time && new Date(r.check_in_time).toDateString() === today;
                  }).length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {error && (
          <div className="mb-6 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
            {error}
          </div>
        )}

        {/* FlowStep Progress Section */}
        <div className="mb-8">
          <div className="bg-white shadow-xl rounded-2xl overflow-hidden">
            <div className="px-6 py-6 bg-gradient-to-r from-green-600 to-blue-600 text-white">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold">
                    🚀 Tiến trình nhiệm vụ tuần tra
                  </h2>
                  <p className="text-green-100 mt-1">
                    Theo dõi tiến trình thực hiện nhiệm vụ của nhân viên theo thời gian thực
                  </p>
                </div>
                <div className="text-right">
                  <div className="text-sm text-green-100">Tổng nhiệm vụ</div>
                  <div className="text-2xl font-bold">{tasks.length}</div>
                </div>
              </div>
            </div>
            
            <div className="p-4 sm:p-6 space-y-4 sm:space-y-6">
              {tasks.length > 0 ? (
                tasks.map((task) => (
                  <div key={task.id} className={`border rounded-lg p-3 sm:p-4 hover:shadow-md transition-shadow ${
                    (() => {
                      const status = getLocationStatus(task.stops?.[0], task);
                      return status?.color === 'red' ? 'border-red-300 bg-red-50' :
                             status?.color === 'green' ? 'border-green-300 bg-green-50' :
                             status?.color === 'blue' ? 'border-blue-300 bg-blue-50' :
                             'border-gray-200';
                    })()
                  }`}>
                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-4 space-y-2 sm:space-y-0">
                      <div className="flex-1 min-w-0">
                        <h3 className="text-base sm:text-lg font-semibold text-gray-900 truncate">{task.title}</h3>
                        <div className="flex flex-col sm:flex-row sm:items-center space-y-1 sm:space-y-0 sm:space-x-2 text-xs sm:text-sm text-gray-600">
                          <span>Nhân viên: {(task as any).assigned_user?.full_name || (task as any).assigned_user?.username || 'Chưa giao'}</span>
                          <span className="hidden sm:inline">•</span>
                          <span>Lịch: {(() => {
                            try {
                              const schedule = JSON.parse(task.schedule_week);
                              const dateObj = new Date(schedule.date);
                              const formattedDate = dateObj.toLocaleDateString('vi-VN', {
                                timeZone: 'Asia/Ho_Chi_Minh',
                                year: 'numeric',
                                month: '2-digit',
                                day: '2-digit'
                              });
                              return `${formattedDate} | ${schedule.startTime} - ${schedule.endTime}`;
                            } catch (e) {
                              return task.schedule_week;
                            }
                          })()}</span>
                          <span className="hidden sm:inline">•</span>
                          <span className="flex items-center">
                            Trạng thái: 
                            <span className={`ml-1 px-2 py-1 text-xs rounded-full ${
                              (() => {
                                const status = getLocationStatus(task.stops?.[0], task);
                                return status.color === 'red' ? 'bg-red-100 text-red-800' :
                                       status.color === 'green' ? 'bg-green-100 text-green-800' :
                                       status.color === 'blue' ? 'bg-blue-100 text-blue-800' :
                                       'bg-yellow-100 text-yellow-800';
                              })()
                            }`}>
                              {(() => {
                                const status = getLocationStatus(task.stops?.[0], task);
                                return status.text;
                              })()}
                            </span>
                          </span>
                        </div>
                      </div>
                      <button 
                        onClick={() => deleteTask(task.id)}
                        className="text-red-600 hover:text-red-800 text-sm self-start sm:self-auto"
                      >
                        Xóa
                      </button>
                    </div>
                    
                    {task.stops && task.stops.length > 0 ? (
                      <FlowStepProgress
                        steps={task.stops
                          .sort((a, b) => a.sequence - b.sequence)
                          .map((stop, index) => {
                            const status = getLocationStatus(stop, task);
                            
                            // Luôn cho phép bấm để xem thông tin chi tiết
                            // Logic kiểm tra thời gian sẽ được xử lý trong handleStepClick
                            const canClick = true;
                            
                            // Lấy thời gian cụ thể cho từng mốc
                            let scheduledTime = 'Chưa xác định';
                            
                            // Ưu tiên scheduled_time của stop trước
                            if (stop.scheduled_time) {
                              scheduledTime = stop.scheduled_time;
                            } else {
                              // Nếu không có, tính toán dựa trên sequence
                              try {
                                const schedule = JSON.parse(task.schedule_week);
                                if (schedule.startTime) {
                                  const startHour = parseInt(schedule.startTime.split(':')[0]);
                                  const startMinute = parseInt(schedule.startTime.split(':')[1]);
                                  
                                  // Tính thời gian cho mốc này (mỗi mốc cách nhau 1 giờ)
                                  const stopHour = startHour + stop.sequence;
                                  const formattedHour = String(stopHour).padStart(2, '0');
                                  const formattedMinute = String(startMinute).padStart(2, '0');
                                  
                                  scheduledTime = `${formattedHour}:${formattedMinute}`;
                                }
                              } catch (e) {
                                scheduledTime = 'Chưa xác định';
                              }
                            }

                            // LOGIC THÔNG MINH: Chỉ hiển thị check-in cho mốc thời gian gần nhất
                            let latestCheckin = null;
                            
                            // Tìm TẤT CẢ check-in records cho location này
                            const allLocationRecords = records.filter(record => 
                              record.location_id === stop.location_id &&
                              record.check_in_time
                            );
                            
                            if (allLocationRecords.length > 0 && stop.scheduled_time && stop.scheduled_time !== 'Chưa xác định') {
                              // Tìm check-in record gần nhất với thời gian được giao
                              const scheduledHour = parseInt(stop.scheduled_time.split(':')[0]);
                              const scheduledMinute = parseInt(stop.scheduled_time.split(':')[1]);
                              const scheduledTimeInMinutes = scheduledHour * 60 + scheduledMinute;
                              
                              // Tìm check-in record có thời gian gần nhất với scheduled_time
                              latestCheckin = allLocationRecords.reduce((closest: any, current) => {
                                if (!current.check_in_time) return closest;
                                
                                const checkinDate = new Date(current.check_in_time);
                                const checkinHour = checkinDate.getHours();
                                const checkinMinute = checkinDate.getMinutes();
                                const checkinTimeInMinutes = checkinHour * 60 + checkinMinute;
                                
                                const currentDiff = Math.abs(checkinTimeInMinutes - scheduledTimeInMinutes);
                                const closestDiff = closest ? Math.abs(
                                  new Date(closest.check_in_time).getHours() * 60 + 
                                  new Date(closest.check_in_time).getMinutes() - scheduledTimeInMinutes
                                ) : Infinity;
                                
                                return currentDiff < closestDiff ? current : closest;
                              }, null);
                              
                              // Chỉ hiển thị nếu check-in trong vòng 15 phút từ thời gian được giao
                              if (latestCheckin) {
                                const checkinDate = new Date(latestCheckin.check_in_time);
                                const checkinHour = checkinDate.getHours();
                                const checkinMinute = checkinDate.getMinutes();
                                const checkinTimeInMinutes = checkinHour * 60 + checkinMinute;
                                
                                // Kiểm tra xem check-in có trong vòng 15 phút từ scheduled_time không
                                const timeDiff = checkinTimeInMinutes - scheduledTimeInMinutes;
                                
                                // Chỉ hiển thị nếu check-in trong khoảng 0-15 phút sau scheduled_time
                                if (timeDiff < 0 || timeDiff > 15) {
                                  latestCheckin = null;
                                }
                              }
                            }
                            
                            // Debug: Kiểm tra thời gian hiển thị
                            console.log(`🔍 Stop ${stop.sequence} (${stop.location_id}):`, {
                              scheduled_time: stop.scheduled_time,
                              completed_at: (stop as any).completed_at,
                              latestCheckin_time: latestCheckin?.check_in_time,
                              latestCheckin_photo: latestCheckin?.photo_url,
                              final_completedAt: latestCheckin?.check_in_time || (stop as any).completed_at
                            });
                            
                            return {
                              id: `stop-${task.id}-${stop.location_id}-${stop.sequence}`,
                              name: stop.location_name,
                              completed: latestCheckin !== null, // Có checkin record = completed
                              completedAt: latestCheckin?.check_in_time || undefined, // Hiển thị thời gian thực tế chấm công
                              completedBy: (task as any).assigned_user?.full_name || (task as any).assigned_user?.username || 'Nhân viên',
                              isActive: status.status === 'active',
                              isOverdue: status.status === 'overdue',
                              locationId: stop.location_id,
                              taskId: task.id,
                              scheduledTime: scheduledTime,
                              statusText: status.text,
                              statusColor: status.color,
                              photoUrl: latestCheckin?.photo_url || null, // Chỉ hiển thị ảnh khi có checkin hợp lệ
                              taskCreatedAt: task.created_at, // Thêm thời gian tạo nhiệm vụ
                              onStepClick: canClick ? handleStepClick : undefined
                            };
                          })
                        }
                      />
                    ) : (
                      <div className="text-center text-gray-500 py-8">
                        <div className="text-sm">Nhiệm vụ đơn giản - không có điểm dừng</div>
                        <div className="text-xs mt-1">Vị trí: {task.location_name || 'Chưa xác định'}</div>
                      </div>
                    )}
                  </div>
                ))
              ) : (
                <div className="text-center text-gray-500 py-8">
                  <div className="text-lg">Chưa có nhiệm vụ nào</div>
                  <div className="text-sm mt-1">Tạo nhiệm vụ mới để bắt đầu theo dõi tiến trình</div>
                </div>
              )}
            </div>
          </div>
        </div>

      </div>

      {/* Checkin Detail Modal */}
      <CheckinDetailModal
        isOpen={showCheckinModal}
        onClose={() => {
          setShowCheckinModal(false);
          setSelectedCheckinRecord(null);
        }}
        record={selectedCheckinRecord as any}
      />

    </div>
  );
};

export default AdminDashboardPage;
