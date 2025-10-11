import React, { useState, useEffect } from 'react';
import { Users, MapPin, QrCode, ClipboardList, BarChart3, TrendingUp, UserCheck, Clock, CheckCircle, AlertCircle, Calendar, Camera, Settings } from 'lucide-react';
import { useAuthStore } from '../stores/authStore';
import { toast } from 'react-hot-toast';
import { api } from '../utils/api';
import { useNavigate } from 'react-router-dom';

interface DashboardStats {
  totalUsers: number;
  totalTasks: number;
  totalLocations: number;
  totalQRCodes: number;
  completedTasks: number;
  pendingTasks: number;
  activeUsers: number;
  recentActivity: Array<{
    id: number;
    type: string;
    description: string;
    timestamp: string;
    user: string;
  }>;
}

const DashboardPage: React.FC = () => {
  const { user } = useAuthStore();
  const navigate = useNavigate();
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    totalTasks: 0,
    totalLocations: 0,
    totalQRCodes: 0,
    completedTasks: 0,
    pendingTasks: 0,
    activeUsers: 0,
    recentActivity: []
  });
  const [loading, setLoading] = useState(true);
  const [myTasks, setMyTasks] = useState<any[]>([]);
  const [newTasksCount, setNewTasksCount] = useState(0);

  useEffect(() => {
    fetchDashboardStats();
    if (user?.role === 'employee') {
      fetchMyTasks();
      checkNewTasks();
    }
  }, [user]);

  // Auto-refresh tasks mỗi 30 giây để cập nhật real-time
  useEffect(() => {
    if (user?.role === 'employee') {
      const interval = setInterval(() => {
        fetchMyTasks();
      }, 30000); // 30 giây

      return () => clearInterval(interval);
    }
  }, [user]);

  // Listen for task completion events
  useEffect(() => {
    const handleTaskCompleted = () => {
      if (user?.role === 'employee') {
        fetchDashboardStats();
        fetchMyTasks();
        checkNewTasks();
      }
    };

    window.addEventListener('taskCompleted', handleTaskCompleted);
    return () => window.removeEventListener('taskCompleted', handleTaskCompleted);
  }, [user]);

  const checkNewTasks = async () => {
    try {
      if (user?.role === 'employee' && user.id) {
        const response = await api.get(`/patrol-tasks/user/${user.id}/new-tasks`);
        const newTasks = response.data;
        setNewTasksCount(newTasks ? newTasks.length : 0);
      }
    } catch (error) {
      console.error('Error checking new tasks:', error);
    }
  };

  const fetchDashboardStats = async () => {
    try {
      console.log('Fetching dashboard stats...');
      console.log('Auth token:', useAuthStore.getState().token);
      console.log('Is authenticated:', useAuthStore.getState().isAuthenticated);
      
      let totalUsers = 0;
      let totalQRCodes = 0;
      let activeUsers = 0;
      
      // Chỉ admin/manager mới được xem thống kê người dùng
      if (user?.role === 'admin' || user?.role === 'manager') {
        try {
          const usersResponse = await api.get('/users/');
          const users = usersResponse.data || [];
          totalUsers = users.length;
          activeUsers = users.filter((u: any) => u.is_active).length;
        } catch (error) {
          console.log('Cannot fetch users (403 expected for employee):', error);
        }
        
        try {
          const qrResponse = await api.get('/qr-codes/');
          const qrCodes = qrResponse.data || [];
          totalQRCodes = qrCodes.length;
        } catch (error) {
          console.log('Cannot fetch QR codes (403 expected for employee):', error);
        }
      }
      
      // Fetch tasks with authentication - different endpoint for employee vs admin/manager
      let tasks = [];
      if (user?.role === 'employee') {
        // Employee chỉ xem nhiệm vụ của mình
        try {
          const tasksResponse = await api.get('/patrol-tasks/my-tasks');
          tasks = tasksResponse.data || [];
        } catch (error) {
          console.log('Cannot fetch my-tasks (expected for employee):', error);
          tasks = [];
        }
      } else {
        // Admin/Manager xem tất cả nhiệm vụ
        try {
          const tasksResponse = await api.get('/patrol-tasks/');
          tasks = tasksResponse.data || [];
        } catch (error) {
          console.log('Cannot fetch all tasks (403 expected for employee):', error);
          tasks = [];
        }
      }
      
      // Fetch locations with authentication
      let locations = [];
      try {
        const locationsResponse = await api.get('/locations/');
        locations = locationsResponse.data || [];
      } catch (error) {
        console.log('Cannot fetch locations:', error);
        locations = [];
      }
      
      // Calculate stats
      const completedTasks = tasks.filter((t: any) => t.status === 'completed').length;
      const pendingTasks = tasks.filter((t: any) => t.status === 'pending').length;
      
      // Mock recent activity (in real app, this would come from backend)
      const recentActivity = [
        {
          id: 1,
          type: 'task_created',
          description: 'Tạo nhiệm vụ mới: Tuần tra khu vực A',
          timestamp: new Date().toISOString(),
          user: 'Admin'
        },
        {
          id: 2,
          type: 'qr_generated',
          description: 'Tạo mã QR cho vị trí: Cổng chính',
          timestamp: new Date(Date.now() - 3600000).toISOString(),
          user: 'Manager'
        },
        {
          id: 3,
          type: 'user_registered',
          description: 'Đăng ký nhân viên mới: Nguyễn Văn A',
          timestamp: new Date(Date.now() - 7200000).toISOString(),
          user: 'Admin'
        }
      ];

      console.log('Dashboard data:', { totalUsers, tasks, locations, totalQRCodes, activeUsers });
      
      setStats({
        totalUsers,
        totalTasks: tasks.length,
        totalLocations: locations.length,
        totalQRCodes,
        completedTasks,
        pendingTasks,
        activeUsers,
        recentActivity
      });
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
      toast.error('Không thể tải thống kê dashboard');
    } finally {
      setLoading(false);
    }
  };

  const fetchMyTasks = async () => {
    try {
      console.log('Fetching my tasks...');
      const response = await api.get('/patrol-tasks/my-tasks');
      console.log('API response:', response.data);
      const tasks = response.data || [];
      console.log('Tasks found:', tasks.length);
      
      // Cập nhật trạng thái real-time cho từng task
      const updatedTasks = tasks.map((task: any) => {
        const realTimeStatus = getTaskRealTimeStatus(task);
        return {
          ...task,
          status: realTimeStatus.status,
          statusText: realTimeStatus.text,
          statusColor: realTimeStatus.color
        };
      });
      
      console.log('Updated tasks:', updatedTasks);
      setMyTasks(updatedTasks);
    } catch (error) {
      console.error('Error fetching my tasks:', error);
    }
  };

  const completeTask = async (taskId: number) => {
    try {
      console.log('Completing task:', taskId);
      const response = await api.post(`/patrol-tasks/${taskId}/complete`);
      console.log('Task completed:', response.data);
      
      // Refresh tasks after completion
      await fetchMyTasks();
      
      // Show success message
      alert('Nhiệm vụ đã được hoàn thành thành công!');
    } catch (error: any) {
      console.error('Error completing task:', error);
      alert('Lỗi khi hoàn thành nhiệm vụ: ' + (error.response?.data?.detail || error.message));
    }
  };

  // Hàm kiểm tra trạng thái real-time của task
  const getTaskRealTimeStatus = (task: any) => {
    const now = new Date();
    // Sử dụng timezone Việt Nam trực tiếp
    const vietnamTime = new Date(now.toLocaleString("en-US", {timeZone: "Asia/Ho_Chi_Minh"}));
    const currentDate = vietnamTime.toISOString().split('T')[0];
    const currentTime = vietnamTime.getHours() * 60 + vietnamTime.getMinutes();
    
    console.log('=== TASK STATUS DEBUG ===');
    console.log('Task:', task.title);
    console.log('Current time (Vietnam):', vietnamTime.toLocaleString('vi-VN'));
    console.log('Current time (minutes):', currentTime);
    console.log('Current date:', currentDate);
    
    // Lấy ngày của task
    let taskDate = null;
    try {
      const schedule = JSON.parse(task.schedule_week);
      taskDate = schedule.date;
    } catch (e) {
      // Fallback
    }
    
    // Kiểm tra ngày của task so với ngày hiện tại
    const isToday = taskDate === currentDate;
    const isPastTask = taskDate && taskDate < currentDate; // Task hôm qua hoặc trước đó
    const isFutureTask = taskDate && taskDate > currentDate; // Task tương lai
    
    // Nếu đã hoàn thành thực sự
    if (task.status === 'completed') {
      return { status: 'completed', text: '✅ Hoàn thành', color: 'green' };
    }
    
    // Xử lý task quá khứ (hôm qua hoặc trước đó)
    if (isPastTask) {
      if (task.status === 'completed') {
        return { status: 'completed', text: '✅ Hoàn thành', color: 'green' };
      } else {
        return { status: 'overdue', text: '🔴 Quá hạn', color: 'red' };
      }
    }
    
    // Xử lý task tương lai
    if (isFutureTask) {
      return { status: 'pending', text: '⏳ Chưa đến ngày', color: 'gray' };
    }
    
    // Xử lý task hôm nay
    if (isToday) {
      // Lấy thời gian bắt đầu và kết thúc từ stops
      let startTime = null;
      let endTime = null;
      
      if (task.stops && task.stops.length > 0) {
        // Tìm thời gian sớm nhất (bắt đầu)
        const startStop = task.stops.reduce((earliest: any, stop: any) => {
          if (stop.scheduled_time) {
            const [hours, minutes] = stop.scheduled_time.split(':').map(Number);
            const time = hours * 60 + minutes;
            if (!earliest || time < earliest.time) {
              return { time, stop };
            }
          }
          return earliest;
        }, null);
        
        // Tìm thời gian muộn nhất (kết thúc)
        const endStop = task.stops.reduce((latest: any, stop: any) => {
          if (stop.scheduled_time) {
            const [hours, minutes] = stop.scheduled_time.split(':').map(Number);
            const time = hours * 60 + minutes;
            if (!latest || time > latest.time) {
              return { time, stop };
            }
          }
          return latest;
        }, null);
        
        if (startStop) startTime = startStop.time;
        if (endStop) endTime = endStop.time;
      }
      
      if (startTime && endTime) {
        // Thêm 30 phút buffer cho thời gian kết thúc
        const endTimeWithBuffer = endTime + 30;
        
        console.log('Start time (minutes):', startTime);
        console.log('End time (minutes):', endTime);
        console.log('End time with buffer:', endTimeWithBuffer);
        console.log('Current < Start?', currentTime < startTime);
        console.log('Current >= Start && <= End?', currentTime >= startTime && currentTime <= endTimeWithBuffer);
        console.log('Current > End?', currentTime > endTimeWithBuffer);
        
        if (task.status === 'completed') {
          console.log('Status: COMPLETED');
          return { status: 'completed', text: '✅ Hoàn thành', color: 'green' };
        } else if (currentTime < startTime) {
          console.log('Status: PENDING (chưa đến giờ)');
          return { status: 'pending', text: '⏳ Chờ thực hiện', color: 'blue' };
        } else if (currentTime >= startTime && currentTime <= endTimeWithBuffer) {
          console.log('Status: IN_PROGRESS (trong giờ làm việc)');
          return { status: 'in_progress', text: '🟡 Đang thực hiện', color: 'yellow' };
        } else {
          console.log('Status: OVERDUE (quá hạn)');
          return { status: 'overdue', text: '🔴 Quá hạn', color: 'red' };
        }
      } else {
        // Nếu không có scheduled time, kiểm tra trạng thái gốc
        if (task.status === 'completed') {
          return { status: 'completed', text: '✅ Hoàn thành', color: 'green' };
        } else {
          return { status: 'pending', text: '⏳ Chờ thực hiện', color: 'blue' };
        }
      }
    }
    
    // Fallback về trạng thái gốc
    return {
      status: task.status,
      text: task.status === 'completed' ? '✅ Hoàn thành' : 
            task.status === 'in_progress' ? '🔄 Đang thực hiện' : 
            '⏳ Đang chờ',
      color: task.status === 'completed' ? 'green' : 
             task.status === 'in_progress' ? 'blue' : 'yellow'
    };
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-green-500"></div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Dashboard</h1>
            <p className="text-gray-600">Chào mừng bạn trở lại, {user?.full_name || user?.username}!</p>
            {user?.role === 'employee' && newTasksCount > 0 && (
              <div className="mt-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                <div className="flex items-center">
                  <AlertCircle className="w-5 h-5 text-blue-600 mr-2" />
                  <span className="text-blue-800 font-medium">
                    Bạn có {newTasksCount} nhiệm vụ mới cần thực hiện!
                  </span>
                </div>
              </div>
            )}
          </div>
        </div>
        
        
      </div>

      {/* Stats Cards - Employee chỉ hiển thị nhiệm vụ */}
      {user?.role === 'employee' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
            <div className="flex items-center">
              <div className="p-2 bg-green-100 rounded-lg">
                <ClipboardList className="w-6 h-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng nhiệm vụ</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.totalTasks}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6 border-l-4 border-purple-500">
            <div className="flex items-center">
              <div className="p-2 bg-purple-100 rounded-lg">
                <MapPin className="w-6 h-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng vị trí</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.totalLocations}</p>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
            <div className="flex items-center">
              <div className="p-2 bg-blue-100 rounded-lg">
                <Users className="w-6 h-6 text-blue-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng người dùng</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.totalUsers}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
            <div className="flex items-center">
              <div className="p-2 bg-green-100 rounded-lg">
                <ClipboardList className="w-6 h-6 text-green-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng nhiệm vụ</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.totalTasks}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6 border-l-4 border-purple-500">
            <div className="flex items-center">
              <div className="p-2 bg-purple-100 rounded-lg">
                <MapPin className="w-6 h-6 text-purple-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng vị trí</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.totalLocations}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow p-6 border-l-4 border-orange-500">
            <div className="flex items-center">
              <div className="p-2 bg-orange-100 rounded-lg">
                <QrCode className="w-6 h-6 text-orange-600" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Tổng mã QR</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.totalQRCodes}</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Task Status */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Trạng thái nhiệm vụ</h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <CheckCircle className="w-5 h-5 text-green-500 mr-2" />
                <span className="text-gray-700">Hoàn thành</span>
              </div>
              <span className="text-lg font-semibold text-green-600">{stats.completedTasks}</span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <Clock className="w-5 h-5 text-yellow-500 mr-2" />
                <span className="text-gray-700">Đang chờ</span>
              </div>
              <span className="text-lg font-semibold text-yellow-600">{stats.pendingTasks}</span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <AlertCircle className="w-5 h-5 text-blue-500 mr-2" />
                <span className="text-gray-700">Đang thực hiện</span>
              </div>
              <span className="text-lg font-semibold text-blue-600">{stats.totalTasks - stats.completedTasks - stats.pendingTasks}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Thống kê người dùng</h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <UserCheck className="w-5 h-5 text-green-500 mr-2" />
                <span className="text-gray-700">Đang hoạt động</span>
              </div>
              <span className="text-lg font-semibold text-green-600">{stats.activeUsers}</span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <Users className="w-5 h-5 text-gray-500 mr-2" />
                <span className="text-gray-700">Tổng cộng</span>
              </div>
              <span className="text-lg font-semibold text-gray-600">{stats.totalUsers}</span>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <TrendingUp className="w-5 h-5 text-blue-500 mr-2" />
                <span className="text-gray-700">Tỷ lệ hoạt động</span>
              </div>
              <span className="text-lg font-semibold text-blue-600">
                {stats.totalUsers > 0 ? Math.round((stats.activeUsers / stats.totalUsers) * 100) : 0}%
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Hoạt động gần đây</h3>
        <div className="space-y-4">
          {stats.recentActivity.map((activity) => (
            <div key={activity.id} className="flex items-center space-x-4 p-3 bg-gray-50 rounded-lg">
              <div className="p-2 bg-blue-100 rounded-lg">
                <BarChart3 className="w-4 h-4 text-blue-600" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">{activity.description}</p>
                <p className="text-xs text-gray-500">
                  {new Date(activity.timestamp).toLocaleString('vi-VN')} • {activity.user}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      {(user?.role === 'manager' || user?.role === 'admin') && (
        <div className="bg-white rounded-lg shadow p-6 mt-8">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Thao tác nhanh</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button 
              onClick={() => window.location.href = '/tasks'}
              className="p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-green-500 hover:bg-green-50 transition-colors"
            >
              <ClipboardList className="w-8 h-8 text-gray-400 mx-auto mb-2" />
              <p className="text-sm font-medium text-gray-700">Tạo nhiệm vụ mới</p>
            </button>
            <button 
              onClick={() => window.location.href = '/tasks?tab=qr'}
              className="p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-green-500 hover:bg-green-50 transition-colors"
            >
              <QrCode className="w-8 h-8 text-gray-400 mx-auto mb-2" />
              <p className="text-sm font-medium text-gray-700">Tạo mã QR</p>
            </button>
            <button 
              onClick={() => window.location.href = '/users'}
              className="p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-green-500 hover:bg-green-50 transition-colors"
            >
              <Users className="w-8 h-8 text-gray-400 mx-auto mb-2" />
              <p className="text-sm font-medium text-gray-700">Quản lý người dùng</p>
            </button>
          </div>
        </div>
      )}

      {user?.role === 'employee' && (
        <div className="bg-white rounded-lg shadow p-6 mt-8">
          <h3 className="text-2xl font-bold text-gray-900 mb-6">📋 Nhiệm vụ được giao</h3>
          <div className="space-y-6">
            {myTasks.length === 0 ? (
              <div className="text-center py-8">
                <p className="text-lg text-gray-500">Bạn chưa có nhiệm vụ nào được giao.</p>
              </div>
            ) : (
              myTasks.map((task) => (
                <div key={task.id} className={`rounded-lg p-6 border-2 ${
                  task.statusColor === 'green' 
                    ? 'bg-green-50 border-green-200' 
                    : task.statusColor === 'red'
                    ? 'bg-red-50 border-red-200'
                    : task.statusColor === 'yellow'
                    ? 'bg-yellow-50 border-yellow-200'
                    : task.statusColor === 'blue'
                    ? 'bg-blue-50 border-blue-200'
                    : 'bg-gray-50 border-gray-200'
                }`}>
                  <div className="flex items-center justify-between mb-4">
                    <h4 className="text-xl font-bold text-gray-900">{task.title}</h4>
                    <span className={`px-4 py-2 rounded-full text-lg font-bold ${
                      task.statusColor === 'green' 
                        ? 'bg-green-500 text-white' 
                        : task.statusColor === 'red'
                        ? 'bg-red-500 text-white'
                        : task.statusColor === 'yellow'
                        ? 'bg-yellow-500 text-white'
                        : task.statusColor === 'blue'
                        ? 'bg-blue-500 text-white'
                        : 'bg-gray-500 text-white'
                    }`}>
                      {task.statusText || '⏳ Đang chờ'}
                    </span>
                  </div>
                  
                  {/* Nút hoàn thành - chỉ hiển thị khi task chưa hoàn thành và không quá hạn */}
                  {(() => {
                    const isCompleted = task.status === 'completed';
                    const isOverdue = task.status === 'overdue' || task.statusText?.includes('Quá hạn');
                    const shouldShowButton = !isCompleted && !isOverdue;
                    console.log('Task:', task.title, 'Status:', task.status, 'StatusText:', task.statusText, 'IsOverdue:', isOverdue, 'Should show button:', shouldShowButton);
                    return shouldShowButton;
                  })() && (
                    <div className="mb-4">
                      <button
                        onClick={() => completeTask(task.id)}
                        className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition-colors font-medium"
                      >
                        ✓ Hoàn thành
                      </button>
                    </div>
                  )}
                  
                  {task.description && (
                    <p className="text-lg text-gray-700 mb-3">{task.description}</p>
                  )}
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="flex items-start">
                      <MapPin className="w-6 h-6 text-gray-500 mr-3 mt-1" />
                      <div className="flex-1">
                        <p className="text-sm text-gray-600 mb-2">Vị trí cần tuần tra:</p>
                        {task.stops && task.stops.length > 0 ? (
                          <div className="space-y-2">
                            {console.log('Task stops:', task.stops)}
                            {task.stops
                              .sort((a: any, b: any) => a.sequence - b.sequence)
                              .map((stop: any, index: number) => {
                                console.log('Stop data:', stop, 'Scheduled time:', stop.scheduled_time);
                                return (
                                <div key={stop.location_id} className="flex items-center">
                                  <span className={`w-6 h-6 rounded-full flex items-center justify-center text-sm mr-3 ${
                                    stop.visited ? 'bg-green-500 text-white' : 'bg-gray-300 text-gray-600'
                                  }`}>
                                    {stop.visited ? '✓' : index + 1}
                                  </span>
                                  <div className="flex-1">
                                    <p className={`text-sm font-medium ${stop.visited ? 'text-green-700' : 'text-gray-900'}`}>
                                      {stop.location_name}
                                      {stop.scheduled_time && (
                                        <span className="ml-2 text-green-600 font-medium">
                                          ({stop.scheduled_time})
                                        </span>
                                      )}
                                    </p>
                                    {stop.visited_at && (
                                      <p className="text-xs text-gray-500">
                                        ✓ Đã chấm công: {new Date(stop.visited_at).toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh',
                                          month: '2-digit',
                                          day: '2-digit',
                                          hour: '2-digit',
                                          minute: '2-digit'
                                        })}
                                        {stop.scheduled_time && (
                                          <span className="ml-2 text-blue-600 font-medium">
                                            (Giao: {stop.scheduled_time})
                                          </span>
                                        )}
                                      </p>
                                    )}
                                  </div>
                                </div>
                                );
                              })
                            }
                          </div>
                        ) : (
                          <p className="text-lg font-semibold text-gray-900">
                            {task.location_name || 'Chưa xác định'}
                          </p>
                        )}
                      </div>
                    </div>
                    
                    {task.schedule_week && (
                      <div className="flex items-center">
                        <Clock className="w-6 h-6 text-gray-500 mr-3" />
                        <div>
                          <p className="text-sm text-gray-600">Thời gian:</p>
                          <p className="text-lg font-semibold text-gray-900">
                            {(() => {
                              try {
                                const schedule = JSON.parse(task.schedule_week);
                                const date = schedule.date;
                                const startTime = schedule.startTime;
                                const endTime = schedule.endTime;
                                
                                // Format ngày
                                const dateObj = new Date(date);
                                const formattedDate = dateObj.toLocaleDateString('vi-VN', {
                                  day: '2-digit',
                                  month: '2-digit',
                                  year: 'numeric'
                                });
                                
                                return `${formattedDate} | ${startTime} - ${endTime}`;
                              } catch (e) {
                                return task.schedule_week;
                              }
                            })()}
                          </p>
                        </div>
                      </div>
                    )}
                  </div>
                  
                  {task.due_date && (
                    <div className="mt-4 flex items-center">
                      <Calendar className="w-6 h-6 text-gray-500 mr-3" />
                      <div>
                        <p className="text-sm text-gray-600">Ngày hạn:</p>
                        <p className="text-lg font-semibold text-gray-900">
                          {new Date(task.due_date).toLocaleDateString('vi-VN')}
                        </p>
                      </div>
                    </div>
                  )}
                </div>
              ))
            )}
          </div>
        </div>
      )}

      {/* Face Authentication Section */}
      <div className="bg-white rounded-lg shadow p-6 mb-8">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">Xác thực khuôn mặt</h3>
          <button
            onClick={() => navigate('/face-auth-settings')}
            className="flex items-center space-x-2 text-blue-600 hover:text-blue-800 transition-colors"
          >
            <Settings className="w-4 h-4" />
            <span className="text-sm">Cài đặt</span>
          </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="flex items-center space-x-3 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <Camera className="w-6 h-6 text-blue-600" />
            <div>
              <p className="font-medium text-blue-800">Đăng nhập nhanh</p>
              <p className="text-sm text-blue-600">Sử dụng khuôn mặt để đăng nhập</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-3 p-4 bg-green-50 border border-green-200 rounded-lg">
            <CheckCircle className="w-6 h-6 text-green-600" />
            <div>
              <p className="font-medium text-green-800">Bảo mật cao</p>
              <p className="text-sm text-green-600">Dữ liệu được mã hóa an toàn</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
