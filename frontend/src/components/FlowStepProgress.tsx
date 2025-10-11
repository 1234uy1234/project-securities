import React from 'react';

interface FlowStep {
  id: string;
  name: string;
  completed: boolean;
  completedAt?: string;
  completedBy?: string;
  isActive?: boolean;
  isOverdue?: boolean;
  locationId?: number;
  taskId?: number;
  scheduledTime?: string;
  statusText?: string;
  statusColor?: string;
  photoUrl?: string;  // Thêm field ảnh
  taskCreatedAt?: string;  // Thêm thời gian tạo nhiệm vụ
  onStepClick?: (step: FlowStep) => void;
}

interface FlowStepProgressProps {
  steps: FlowStep[];
  title?: string;
  className?: string;
}

const FlowStepProgress: React.FC<FlowStepProgressProps> = ({ 
  steps, 
  title = "FlowStep",
  className = ""
}) => {
  const formatDateTime = (dateString?: string) => {
    if (!dateString) return '';
    try {
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return '';
      // Sử dụng múi giờ Việt Nam (UTC+7)
      return date.toLocaleString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        year: 'numeric',
        month: 'numeric',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (e) {
      return '';
    }
  };

  const getStepStatus = (step: FlowStep, index: number) => {
    // Sử dụng trạng thái từ props thay vì tính toán lại
    // Điều này đảm bảo logic thống nhất với AdminDashboardPage
    
    if (step.completed) {
      return {
        circleClass: "bg-green-500 text-white",
        lineClass: "bg-green-500",
        icon: (
          <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8.486 8.486a1 1 0 01-1.414 0L3.293 12.179a1 1 0 011.414-1.414L8 13.059l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd"/>
          </svg>
        )
      };
    } else if (step.isOverdue) {
      return {
        circleClass: "bg-red-500 text-white",
        lineClass: "bg-red-500",
        icon: (
          <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd"/>
          </svg>
        )
      };
    } else if (step.isActive) {
      return {
        circleClass: "bg-yellow-500 text-white animate-pulse",
        lineClass: "bg-yellow-500",
        icon: (
          <div className="w-2 h-2 bg-white rounded-full"></div>
        )
      };
    } else {
      // Chưa chấm công và chưa đến giờ = màu xám (chờ thực hiện)
      return {
        circleClass: "bg-gray-400 text-white",
        lineClass: "bg-gray-400",
        icon: (
          <span className="text-sm font-medium">{index + 1}</span>
        )
      };
    }
  };

  return (
    <div className={`bg-white rounded-lg shadow-lg p-4 sm:p-6 ${className}`}>
      {title && (
        <div className="mb-4 sm:mb-6">
          <h3 className="text-base sm:text-lg font-semibold text-gray-900">{title}</h3>
          {/* Hiển thị thời gian tạo nhiệm vụ nếu có */}
          {steps.length > 0 && steps[0].taskCreatedAt && (
            <div className="mt-1 text-sm text-gray-600">
              📅 Nhiệm vụ được giao: {formatDateTime(steps[0].taskCreatedAt)}
            </div>
          )}
        </div>
      )}
      
      <div className="relative">
        {/* Progress line background */}
        <div className="absolute top-6 left-6 sm:left-8 right-6 sm:right-8 h-0.5 bg-gray-200"></div>
        
        {/* Progress line filled */}
        <div 
          className="absolute top-6 left-6 sm:left-8 h-0.5 bg-green-500 transition-all duration-500"
          style={{ 
            width: steps.length > 1 
              ? `calc(${((steps.filter(s => s.completed).length - 1) / (steps.length - 1)) * 100}% - ${steps.length > 1 ? '12px' : '0px'})` 
              : '0%' 
          }}
        ></div>

        <div className="flex justify-between items-start overflow-x-auto pb-2">
          {steps.map((step, index) => {
            const status = getStepStatus(step, index);
            const isLast = index === steps.length - 1;
            
            return (
              <div key={step.id} className="flex flex-col items-center relative z-10 min-w-0 flex-1 px-1">
                {/* Step circle */}
                <div 
                  className={`w-10 h-10 sm:w-12 sm:h-12 rounded-full flex items-center justify-center ${status.circleClass} shadow-lg flex-shrink-0 ${
                    step.onStepClick ? 'cursor-pointer hover:scale-110 transition-transform' : 'cursor-not-allowed opacity-75'
                  }`}
                  onClick={() => {
                    console.log('Step clicked:', step);
                    console.log('onStepClick function:', step.onStepClick);
                    if (step.onStepClick) {
                      step.onStepClick(step);
                    } else {
                      console.log('No onStepClick function available');
                    }
                  }}
                  title={
                    step.onStepClick 
                      ? (step.completed ? 'Nhấn để xem chi tiết chấm công' : 'Nhấn để xem thông tin vị trí')
                      : 'Chưa đến giờ chấm công'
                  }
                >
                  {status.icon}
                </div>
                
                {/* Step name */}
                <div className="mt-2 sm:mt-3 text-center min-w-0">
                  <div className="text-xs sm:text-sm font-medium text-gray-900 break-words leading-tight">
                    {step.name}
                  </div>
                  
                  {/* Scheduled time */}
                  {step.scheduledTime && step.scheduledTime !== 'Chưa xác định' && (
                    <div className="mt-1 text-xs text-green-600 font-medium">
                      {step.scheduledTime}
                    </div>
                  )}
                  
                  {/* Completion info */}
                  {step.completed && step.completedAt && (
                    <div className="mt-1 text-xs text-gray-500">
                      {/* Chỉ hiển thị thời gian check-in, không hiển thị ngày */}
                      <div className="break-words">✓ {new Date(step.completedAt).toLocaleTimeString('vi-VN', {
                        timeZone: 'Asia/Ho_Chi_Minh',
                        hour: '2-digit',
                        minute: '2-digit'
                      })}</div>
                      {step.completedBy && (
                        <div className="font-medium break-words">{step.completedBy}</div>
                      )}
                      {/* Hiển thị ngày task được giao (không phải ngày check-in) */}
                      {step.taskCreatedAt && (
                        <div className="text-xs text-blue-600 font-medium mt-1">
                          📅 {new Date(step.taskCreatedAt).toLocaleDateString('vi-VN', {
                            timeZone: 'Asia/Ho_Chi_Minh',
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric'
                          })}
                        </div>
                      )}
                      {/* Ảnh chỉ hiển thị trong modal chi tiết, không hiển thị ở đây */}
                    </div>
                  )}
                  
                  {/* Status indicator */}
                  {step.statusText && !step.completed && (
                    <div className={`mt-1 text-xs font-medium ${
                      step.statusColor === 'red' ? 'text-red-600' :
                      step.statusColor === 'yellow' ? 'text-yellow-600' :
                      step.statusColor === 'green' ? 'text-green-600' :
                      'text-gray-600'
                    }`}>
                      {step.statusText}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default FlowStepProgress;
