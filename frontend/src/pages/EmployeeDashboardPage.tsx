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
  user_id?: number;
  gps_latitude?: number;
  gps_longitude?: number;
}

const EmployeeDashboardPage: React.FC = () => {
  const { user } = useAuthStore();
  const [records, setRecords] = useState<CheckinRecord[]>([]);
  const [tasks, setTasks] = useState<PatrolTask[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [lastUpdate, setLastUpdate] = useState<Date>(new Date());
  const [newCheckins, setNewCheckins] = useState<CheckinRecord[]>([]);
  const [selectedCheckinRecord, setSelectedCheckinRecord] = useState<CheckinRecord | null>(null);
  const [showCheckinModal, setShowCheckinModal] = useState(false);
  const [currentTime, setCurrentTime] = useState<Date>(new Date()); // Thêm state để force re-render

  useEffect(() => {
    if (user?.role === 'employee') {
      fetchCheckinRecords();
      fetchTasks();
      
      // Auto refresh every 10 seconds
      const interval = setInterval(() => {
        fetchCheckinRecords(true);
        fetchTasks();
      }, 10000);
      
      // Listen for checkin success events
      const handleCheckinSuccess = (event: CustomEvent) => {
        console.log('🎉 EMPLOYEE: Checkin success event received:', event.detail);
        console.log('🎉 EMPLOYEE: Event detail:', JSON.stringify(event.detail, null, 2));
        
        // Immediate refresh when checkin happens
        Promise.all([
          fetchCheckinRecords(true),
          fetchTasks()
        ]).then(() => {
          console.log('🎉 EMPLOYEE: Data refreshed successfully after checkin');
          toast.success('🔄 Đã cập nhật dữ liệu sau khi chấm công!');
        }).catch((error) => {
          console.error('❌ EMPLOYEE: Error refreshing data:', error);
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

  // Cập nhật thời gian mỗi giây để force re-render và cập nhật trạng thái real-time
  useEffect(() => {
    const timeInterval = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000); // Cập nhật mỗi giây

    return () => clearInterval(timeInterval);
  }, []);

  const fetchCheckinRecords = async (silent = false) => {
    try {
      console.log('🔍 Fetching checkin records for employee:', user?.username);
      
      // Thử nhiều endpoints khác nhau cho employee
      let response;
      let allRecords = [];
      
      try {
        // 1. Thử endpoint admin trước để lấy tất cả dữ liệu
        response = await api.get('/checkin/admin/all-records');
        allRecords = response.data;
        console.log('✅ Used /checkin/admin/all-records:', allRecords.length, 'records');
        
        // Filter records cho employee hiện tại
        console.log('🔍 EMPLOYEE: All records before filtering:', allRecords.length);
        console.log('🔍 EMPLOYEE: User info:', { username: user?.username, full_name: user?.full_name, id: user?.id });
        
        allRecords = allRecords.filter((record: CheckinRecord) => 
          record.user_username === user?.username || 
          record.user_name === user?.full_name ||
          record.user_id === user?.id
        );
        console.log('🔍 EMPLOYEE: Filtered records for employee:', allRecords.length, 'records');
        console.log('🔍 EMPLOYEE: Filtered records:', allRecords);
      } catch (error) {
        try {
          // 2. Fallback: Thử endpoint employee-specific
          response = await api.get('/patrol-records/my-records');
          allRecords = response.data;
          console.log('✅ Used /patrol-records/my-records (fallback):', allRecords.length, 'records');
        } catch (error2) {
          try {
            // 3. Fallback: Thử endpoint với user_id parameter
            response = await api.get('/patrol-records/', {
              params: { user_id: user?.id }
            });
            allRecords = response.data;
            console.log('✅ Used /patrol-records/ with user_id (fallback):', allRecords.length, 'records');
          } catch (error3) {
            console.error('❌ All endpoints failed:', error3);
            allRecords = [];
          }
        }
      }
      
      const newRecords = allRecords;
      
      // Debug: Log tất cả records trước khi filter
      console.log('🔍 All records before filtering:', allRecords.map((record: any) => ({
        id: record.id,
        task_id: record.task_id,
        location_id: record.location_id,
        user_username: record.user_username,
        user_name: record.user_name,
        user_id: record.user_id,
        check_in_time: record.check_in_time
      })));
      
      console.log('🔍 Final employee records:', {
        totalRecords: allRecords.length,
        filteredRecords: newRecords.length,
        employeeUsername: user?.username,
        employeeName: user?.full_name,
        employeeId: user?.id,
        filteredRecordsDetails: newRecords.map((record: any) => ({
          id: record.id,
          task_id: record.task_id,
          location_id: record.location_id,
          user_username: record.user_username,
          check_in_time: record.check_in_time
        }))
      });
      
      if (!silent && records.length > 0) {
        // Check for new checkins
        const newCheckinsFound = newRecords.filter((newRecord: CheckinRecord) => 
          !records.some(record => record.id === newRecord.id)
        );
        
        if (newCheckinsFound.length > 0) {
          setNewCheckins(newCheckinsFound);
          newCheckinsFound.forEach((checkin: CheckinRecord) => {
            toast.success(
              `🎉 Bạn vừa hoàn thành nhiệm vụ "${checkin.task_title}"!`,
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
      console.log('🔍 Fetching tasks for employee:', user?.username);
      
      // Thử nhiều endpoints khác nhau cho employee
      let response;
      let allTasks = [];
      
      try {
        // 1. Thử endpoint admin trước để lấy tất cả dữ liệu
        response = await api.get('/patrol-tasks/');
        allTasks = response.data;
        console.log('✅ Used /patrol-tasks/ (admin):', allTasks.length, 'tasks');
      } catch (error) {
        try {
          // 2. Fallback: Thử endpoint employee-specific
          response = await api.get('/patrol-tasks/my-tasks');
          allTasks = response.data;
          console.log('✅ Used /patrol-tasks/my-tasks (fallback):', allTasks.length, 'tasks');
        } catch (error2) {
          console.error('❌ All task endpoints failed:', error2);
          allTasks = [];
        }
      }
      
      // Debug: Log tất cả tasks trước khi filter
      console.log('🔍 All tasks before filtering:', allTasks.map((task: any) => ({
        id: task.id,
        title: task.title,
        assigned_user: task.assigned_user,
        stops: task.stops?.map((stop: any) => ({
          id: stop.id,
          location_name: stop.location_name,
          location_id: stop.location_id,
          sequence: stop.sequence
        }))
      })));
      
      // Luôn filter tasks cho employee hiện tại
      let list = allTasks.filter((task: any) => {
        const isAssigned = task.assigned_user?.username === user?.username ||
                          task.assigned_user?.full_name === user?.full_name ||
                          task.assigned_user?.id === user?.id;
        
        console.log('🔍 Task filter check:', {
          taskId: task.id,
          taskTitle: task.title,
          assignedUser: task.assigned_user,
          currentUser: {
            username: user?.username,
            full_name: user?.full_name,
            id: user?.id
          },
          isAssigned
        });
        
        return isAssigned;
      });
      
      // Nếu không tìm thấy task nào, hiển thị danh sách rỗng (không fallback)
      if (list.length === 0) {
        console.log('ℹ️ No tasks found for employee:', user?.username);
        list = [];
      }
      
      console.log('🔍 Final employee tasks:', {
        totalTasks: allTasks.length,
        filteredTasks: list.length,
        employeeUsername: user?.username,
        employeeName: user?.full_name,
        employeeId: user?.id,
        filteredTasksDetails: list.map((task: any) => ({
          id: task.id,
          title: task.title,
          assigned_user: task.assigned_user,
          stopsCount: task.stops?.length || 0
        }))
      });
      
      setTasks(list);
    } catch (error: any) {
      console.error('Error fetching tasks:', error);
      toast.error('Không thể tải danh sách nhiệm vụ');
    }
  };

  const formatTime = (timeString: string) => {
    try {
      if (!timeString || timeString === 'Chưa xác định') return 'Chưa xác định';
      const date = new Date(timeString);
      if (isNaN(date.getTime())) return 'Chưa xác định';
      return date.toLocaleString('vi-VN', { 
        timeZone: 'Asia/Ho_Chi_Minh',
        hour: '2-digit',
        minute: '2-digit',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      });
    } catch (e) {
      return '-'
    }
  };

  const findCheckinRecord = (taskId: number, locationId: number, scheduledTime?: string): CheckinRecord | null => {
    // LOGIC ĐƠN GIẢN: Tìm checkin record cho task và location, không cần kiểm tra thời gian phức tạp
    console.log('🔍 EMPLOYEE: Finding checkin record for task:', taskId, 'location:', locationId);
    
    // Tìm tất cả checkin records cho task và location này
    const matchingRecords = records.filter(record => 
      record.task_id === taskId && 
      record.location_id === locationId &&
      record.check_in_time // Phải có check_in_time
    );
    
    console.log('📋 EMPLOYEE: Matching records count:', matchingRecords.length);
    
    if (matchingRecords.length > 0) {
      // Lấy record đầu tiên (hoặc có thể lấy record mới nhất)
      const found = matchingRecords[0];
      console.log('✅ EMPLOYEE: Found checkin record:', {
        task_id: found.task_id,
        location_id: found.location_id,
        check_in_time: found.check_in_time,
        check_out_time: found.check_out_time,
        photo_url: found.photo_url
      });
      return found;
    }
    
    console.log('❌ EMPLOYEE: No checkin record found');
    return null;
  };

  // Hàm kiểm tra trạng thái vị trí dựa trên thời gian (COPY NGUYÊN VĂN TỪ ADMIN)
  const getLocationStatus = (stop: any, task: any) => {
    // Kiểm tra null safety
    if (!stop || !task) {
      return { status: 'pending', color: 'gray', text: 'Chưa xác định' };
    }
    
  // LOGIC ĐÚNG: Chỉ hiển thị check-in CÙNG NGÀY với task được giao
  const now = new Date();
  const vietnamTime = new Date(now.toLocaleString("en-US", {timeZone: "Asia/Ho_Chi_Minh"}));
  const todayStr = vietnamTime.toISOString().split('T')[0]; // YYYY-MM-DD format
  
  // Lấy ngày task được tạo
  let taskCreatedDate = null;
  if (task.created_at) {
    const taskCreated = new Date(task.created_at);
    taskCreatedDate = taskCreated.toISOString().split('T')[0];
  }
  
  // SỬ DỤNG HÀM findCheckinRecord ĐÃ ĐƯỢC SỬA
  const hasCheckin = findCheckinRecord(task.id, stop.location_id, stop.scheduled_time);
    
    // Sử dụng múi giờ Việt Nam (UTC+7) - sử dụng currentTime state để force re-render
    const nowTime = currentTime; // Sử dụng state thay vì new Date()
    const vietnamTimeNow = new Date(nowTime.toLocaleString("en-US", {timeZone: "Asia/Ho_Chi_Minh"}));
    const currentDate = vietnamTimeNow.toISOString().split('T')[0]; // YYYY-MM-DD
    const currentTimeInMinutes = vietnamTimeNow.getHours() * 60 + vietnamTimeNow.getMinutes(); // phút trong ngày
    
    // Debug: Log thời gian hiện tại
    console.log(`🕐 EMPLOYEE: Current time: ${vietnamTimeNow.toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' })}`);
    console.log(`🕐 EMPLOYEE: Stop ${stop.location_id} scheduled_time: ${stop.scheduled_time}`);
    console.log(`🕐 EMPLOYEE: Current date: ${currentDate}, Current time in minutes: ${currentTimeInMinutes}`);
    
    // Lấy thời gian dự kiến cho mốc này
    let scheduledTimeInMinutes = null;
    if (stop.scheduled_time && stop.scheduled_time !== 'Chưa xác định') {
      const [scheduledHour, scheduledMinute] = stop.scheduled_time.split(':').map(Number);
      scheduledTimeInMinutes = scheduledHour * 60 + scheduledMinute; // phút trong ngày
      console.log(`🕐 EMPLOYEE: Using stop.scheduled_time: ${stop.scheduled_time} = ${scheduledTimeInMinutes} minutes`);
    } else {
      // Tính toán dựa trên sequence nếu không có scheduled_time
      try {
        const schedule = JSON.parse(task.schedule_week);
        if (schedule.startTime) {
          const startHour = parseInt(schedule.startTime.split(':')[0]);
          const startMinute = parseInt(schedule.startTime.split(':')[1]);
          const stopHour = startHour + stop.sequence;
          scheduledTimeInMinutes = stopHour * 60 + startMinute;
          console.log(`🕐 EMPLOYEE: Calculated from schedule: startTime=${schedule.startTime}, sequence=${stop.sequence}, result=${scheduledTimeInMinutes} minutes`);
        }
      } catch (e) {
        console.log('🕐 EMPLOYEE: Error parsing schedule:', e);
      }
    }
    
    // Lấy ngày của task từ created_at
    let taskDate = null;
    try {
      if (task.created_at) {
        const taskCreatedDate = new Date(task.created_at);
        taskDate = taskCreatedDate.toISOString().split('T')[0];
        console.log(`🕐 EMPLOYEE: Task created_at: ${task.created_at}, parsed date: ${taskDate}`);
      }
    } catch (e) {
      console.log('🕐 EMPLOYEE: Error parsing task date:', e);
    }
    
    // Nếu chưa chấm công
    if (!scheduledTimeInMinutes) {
      console.log(`🕐 EMPLOYEE: No scheduled time found for stop ${stop.location_id}`);
      return { status: 'pending', color: 'gray', text: 'Chưa xác định' };
    }
    
    // Kiểm tra ngày của task so với ngày hiện tại
    const isToday = taskDate === currentDate;
    const isPastTask = taskDate && taskDate < currentDate; // Task hôm qua hoặc trước đó
    const isFutureTask = taskDate && taskDate > currentDate; // Task tương lai
    
    console.log(`🕐 EMPLOYEE: Date comparison:`, {
      taskDate: taskDate,
      currentDate: currentDate,
      isToday: isToday,
      isPastTask: isPastTask,
      isFutureTask: isFutureTask
    });
    
    // LOGIC ĐỒNG BỘ: Có checkin record = hoàn thành (giống Admin Dashboard)
    if (hasCheckin && hasCheckin.check_in_time) {
      console.log(`✅ EMPLOYEE: Location ${stop.location_id} has checkin record - showing as completed`);
      return { status: 'completed', color: 'green', text: 'Đã chấm công' };
    }
    
    // FALLBACK: Kiểm tra trạng thái completed từ stops (backend đã kiểm tra thời gian)
    if (stop.completed) {
      console.log(`✅ EMPLOYEE: Task ${task.id} stop ${stop.location_id} is completed from stops:`, stop);
      return { status: 'completed', color: 'green', text: 'Đã chấm công' };
    }
    
    // Kiểm tra xem có quá hạn không (chỉ áp dụng cho task hôm nay)
    const isOverdue = isToday && currentTimeInMinutes > scheduledTimeInMinutes + 15; // Quá 15 phút
    
    console.log(`🕐 EMPLOYEE: Time comparison:`, {
      currentTimeInMinutes: currentTimeInMinutes,
      scheduledTimeInMinutes: scheduledTimeInMinutes,
      timeDiff: currentTimeInMinutes - scheduledTimeInMinutes,
      isOverdue: isOverdue
    });
    
    // Nếu quá hạn, báo "Quá hạn" và không thể check-in nữa
    if (isOverdue) {
      console.log(`⏰ EMPLOYEE: Location ${stop.location_id} is overdue - more than 15 minutes past scheduled time`);
      return { status: 'overdue', color: 'red', text: 'Quá hạn' };
    }
    
    // Xử lý task quá khứ (hôm qua hoặc trước đó) - CHỈ nếu chưa chấm công
    if (isPastTask) {
      // Kiểm tra lại xem có checkin record không (double check)
      if (hasCheckin && hasCheckin.check_in_time) {
        console.log('✅ EMPLOYEE: PAST TASK COMPLETED: Task hôm qua đã chấm công');
        return { status: 'completed', color: 'green', text: 'Đã chấm công' };
      } else {
        console.log('🔴 EMPLOYEE: PAST TASK OVERDUE: Task hôm qua chưa chấm công');
        return { status: 'overdue', color: 'red', text: 'Quá hạn (chưa chấm công)' };
      }
    }
    
    // Xử lý task tương lai
    if (isFutureTask) {
      console.log('⚪ EMPLOYEE: FUTURE TASK: Chưa đến ngày');
      return { status: 'pending', color: 'gray', text: 'Chưa đến ngày' };
    }
    
    // Xử lý task hôm nay
    if (isToday) {
      // Nếu chưa chấm công
      if (isOverdue) {
        console.log('🔴 EMPLOYEE: OVERDUE: Past deadline');
        return { status: 'overdue', color: 'red', text: 'Chưa chấm công (quá hạn)' };
      } else {
        console.log('🔵 EMPLOYEE: PENDING: Waiting for checkin');
        return { status: 'pending', color: 'blue', text: 'Chờ chấm công' };
      }
    }
    
    // Fallback - không xác định được ngày
    console.log('⚪ EMPLOYEE: UNKNOWN: Cannot determine task date');
    return { status: 'pending', color: 'gray', text: 'Chưa xác định' };
  };

  const handleStepClick = async (step: any) => {
    console.log('handleStepClick called with step:', step);
    
    if (step.taskId && step.locationId) {
      // LOGIC THÔNG MINH: Chỉ hiển thị check-in cho mốc thời gian gần nhất (COPY TỪ ADMIN)
      const allLocationRecords = records.filter(r => 
        r.location_id === step.locationId &&
        r.check_in_time
      );
      
      let record = null;
      if (allLocationRecords.length > 0 && step.scheduledTime && step.scheduledTime !== 'Chưa xác định') {
        // Tìm check-in record gần nhất với thời gian được giao
        const scheduledHour = parseInt(step.scheduledTime.split(':')[0]);
        const scheduledMinute = parseInt(step.scheduledTime.split(':')[1]);
        const scheduledTimeInMinutes = scheduledHour * 60 + scheduledMinute;
        
        record = allLocationRecords.reduce((closest: any, current) => {
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
        if (record) {
          const checkinDate = new Date(record.check_in_time);
          const checkinHour = checkinDate.getHours();
          const checkinMinute = checkinDate.getMinutes();
          const checkinTimeInMinutes = checkinHour * 60 + checkinMinute;
          
          // Kiểm tra xem check-in có trong vòng 15 phút từ scheduled_time không
          const timeDiff = checkinTimeInMinutes - scheduledTimeInMinutes;
          
          // Chỉ hiển thị nếu check-in trong khoảng 0-15 phút sau scheduled_time
          if (timeDiff < 0 || timeDiff > 15) {
            record = null;
          }
        }
      }
      
      if (record) {
        const task = tasks.find(t => t.id === step.taskId);
        const stop = task?.stops?.find(s => s.location_id === step.locationId);
        
        console.log(`✅ Showing checkin record for Stop ${stop?.sequence} (${stop?.scheduled_time}) - Has checkin record`);
        
        // Tạo record với thông tin đơn giản
        const enhancedRecord: CheckinRecord = {
          ...record,
          notes: `Vị trí "${step.name}" đã được chấm công. Thời gian: ${record.check_in_time ? new Date(record.check_in_time).toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }) : 'Chưa xác định'}. Trạng thái: Đã hoàn thành`,
          photo_url: record.photo_url || null,
          user_name: record.user_name || user?.full_name || 'Nhân viên',
          user_username: record.user_username || user?.username || 'user'
        };
        
        setSelectedCheckinRecord(enhancedRecord);
        setShowCheckinModal(true);
      } else {
        // Tạo record giả để hiển thị thông tin vị trí chưa chấm công
        const task = tasks.find(t => t.id === step.taskId);
        const mockRecord: CheckinRecord = {
          id: 0,
          user_name: user?.full_name || 'Nhân viên',
          user_username: user?.username || 'user',
          task_title: task?.title || 'Nhiệm vụ',
          location_name: step.name,
          check_in_time: null,
          check_out_time: null,
          photo_url: null,
          checkout_photo_url: null,
          notes: `Vị trí "${step.name}" chưa được chấm công. Thời gian dự kiến: ${step.scheduledTime || 'Chưa xác định'}. Trạng thái: ${step.statusText || 'Chưa xác định'}`,
          gps_latitude: undefined,
          gps_longitude: undefined
        };
        setSelectedCheckinRecord(mockRecord);
        setShowCheckinModal(true);
      }
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-white text-xl">Đang tải...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 text-xl mb-4">Lỗi: {error}</div>
          <button 
            onClick={() => {
              setError('');
              setLoading(true);
              fetchCheckinRecords();
              fetchTasks();
            }}
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Thử lại
          </button>
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
              <h1 className="text-3xl font-bold text-gray-900">👤 Employee Dashboard</h1>
              <p className="mt-2 text-gray-600">Nhiệm vụ tuần tra của bạn</p>
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
                  <div className="text-sm text-gray-500">Thời gian hiện tại:</div>
                  <div className="text-sm font-medium text-gray-700">
                    {currentTime.toLocaleTimeString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' })}
                  </div>
                  <div className="text-xs text-gray-500 mt-1">
                    Cập nhật: {lastUpdate ? lastUpdate.toLocaleTimeString('vi-VN') : '-'}
                  </div>
                  <div className="flex items-center mt-1">
                    <div className="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse"></div>
                    <span className="text-xs text-green-600">Real-time: 1s</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {newCheckins.length > 0 && (
          <div className="mb-6 p-4 bg-green-100 border border-green-300 rounded-lg">
            <h3 className="text-green-800 font-semibold mb-2">🎉 Hoạt động mới!</h3>
            {newCheckins.map((checkin) => (
              <div key={checkin.id} className="text-sm text-green-700">
                Bạn vừa hoàn thành nhiệm vụ "{checkin.task_title}" tại {checkin.location_name}
              </div>
            ))}
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
                    Theo dõi tiến trình thực hiện nhiệm vụ của bạn theo thời gian thực
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
            tasks.map((task) => {
              const status = getLocationStatus(task.stops?.[0] || {}, task);
              
              return (
                    <div key={task.id} className={`border rounded-lg p-3 sm:p-4 hover:shadow-md transition-shadow ${
                      status?.color === 'red' ? 'border-red-300 bg-red-50' :
                      status?.color === 'green' ? 'border-green-300 bg-green-50' :
                      status?.color === 'blue' ? 'border-blue-300 bg-blue-50' :
                      status?.color === 'yellow' ? 'border-yellow-300 bg-yellow-50' :
                      'border-gray-200 bg-white'
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
                            status.color === 'red' ? 'bg-red-100 text-red-800' :
                            status.color === 'green' ? 'bg-green-100 text-green-800' :
                            status.color === 'blue' ? 'bg-blue-100 text-blue-800' :
                            status.color === 'yellow' ? 'bg-yellow-100 text-yellow-800' :
                            'bg-gray-100 text-gray-800'
                          }`}>
                            {status.text}
                          </span>
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="mt-6">
                    {task.stops && task.stops.length > 0 ? (
                      <FlowStepProgress
                        steps={task.stops.map((stop: any) => {
                          const status = getLocationStatus(stop, task);
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

                          // LOGIC THÔNG MINH: Chỉ hiển thị check-in cho mốc thời gian gần nhất (COPY TỪ ADMIN)
                          const allLocationRecords = records.filter(record => 
                            record.location_id === stop.location_id &&
                            record.check_in_time
                          );
                          
                          let latestCheckin = null;
                          if (allLocationRecords.length > 0 && stop.scheduled_time && stop.scheduled_time !== 'Chưa xác định') {
                            // Tìm check-in record gần nhất với thời gian được giao
                            const scheduledHour = parseInt(stop.scheduled_time.split(':')[0]);
                            const scheduledMinute = parseInt(stop.scheduled_time.split(':')[1]);
                            const scheduledTimeInMinutes = scheduledHour * 60 + scheduledMinute;
                            
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
                          
                          return {
                            id: `stop-${task.id}-${stop.location_id}-${stop.sequence}`,
                            name: stop.location_name,
                            completed: latestCheckin !== null, // Có checkin record = completed
                            completedAt: latestCheckin?.check_in_time || undefined, // Hiển thị thời gian thực tế chấm công
                            completedBy: latestCheckin?.user_name || latestCheckin?.user_username || user?.full_name || user?.username || 'Nhân viên',
                            isActive: status.status === 'active',
                            isOverdue: status.status === 'overdue',
                            locationId: stop.location_id,
                            taskId: task.id,
                            scheduledTime: scheduledTime,
                            statusText: status.text,
                            statusColor: status.color,
                            photoUrl: latestCheckin?.photo_url || undefined, // Chỉ hiển thị ảnh khi có checkin hợp lệ
                            taskCreatedAt: task.created_at, // Thêm thời gian tạo nhiệm vụ
                            onStepClick: canClick ? handleStepClick : undefined
                          };
                        })}
                      />
                    ) : (
                      <div className="text-center text-gray-500 py-8">
                        <div className="text-sm">Nhiệm vụ đơn giản - không có điểm dừng</div>
                        <div className="text-xs mt-1">Vị trí: {task.location_name || 'Chưa xác định'}</div>
                      </div>
                    )}
                  </div>
                </div>
              );
            })
          ) : (
            <div className="text-center text-gray-500 py-8">
              <div className="text-lg">Chưa có nhiệm vụ nào</div>
              <div className="text-sm mt-1">Liên hệ admin để được giao nhiệm vụ</div>
          </div>
        )}
            </div>
          </div>
        </div>
      </div>

      {showCheckinModal && selectedCheckinRecord && (
        <CheckinDetailModal
          isOpen={showCheckinModal}
          record={selectedCheckinRecord as any}
          onClose={() => {
            setShowCheckinModal(false);
            setSelectedCheckinRecord(null);
          }}
        />
      )}
    </div>
  );
};

export default EmployeeDashboardPage;
