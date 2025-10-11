import React, { useState, useEffect } from 'react';
import { Calendar, Clock, Play, Square } from 'lucide-react';

interface TimeRangePickerProps {
  value?: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  disabled?: boolean;
}

const TimeRangePicker: React.FC<TimeRangePickerProps> = ({
  value,
  onChange,
  placeholder = "Chọn ngày và khoảng thời gian",
  className = "",
  disabled = false
}) => {
  const [date, setDate] = useState('');
  const [startTime, setStartTime] = useState('');
  const [endTime, setEndTime] = useState('');
  const [isOpen, setIsOpen] = useState(false);

  // Khởi tạo giá trị mặc định
  useEffect(() => {
    if (value) {
      try {
        const data = JSON.parse(value);
        if (data.date) {
          setDate(data.date);
        }
        if (data.startTime) {
          setStartTime(data.startTime);
        }
        if (data.endTime) {
          setEndTime(data.endTime);
        }
      } catch (e) {
        // Nếu không phải JSON, thử parse như datetime cũ
        const dateTime = new Date(value);
        if (!isNaN(dateTime.getTime())) {
          const year = dateTime.getFullYear();
          const month = String(dateTime.getMonth() + 1).padStart(2, '0');
          const day = String(dateTime.getDate()).padStart(2, '0');
          const hours = String(dateTime.getHours()).padStart(2, '0');
          const minutes = String(dateTime.getMinutes()).padStart(2, '0');
          
          setDate(`${year}-${month}-${day}`);
          setStartTime(`${hours}:${minutes}`);
          const endHour = (parseInt(hours) + 1) % 24;
          setEndTime(`${String(endHour).padStart(2, '0')}:${minutes}`);
        }
      }
    } else {
      // Mặc định là thời gian hiện tại
      const now = new Date();
      const year = now.getFullYear();
      const month = String(now.getMonth() + 1).padStart(2, '0');
      const day = String(now.getDate()).padStart(2, '0');
      const hours = String(now.getHours()).padStart(2, '0');
      const minutes = String(now.getMinutes()).padStart(2, '0');
      
      setDate(`${year}-${month}-${day}`);
      setStartTime(`${hours}:${minutes}`);
      const endHour = (parseInt(hours) + 1) % 24;
      setEndTime(`${String(endHour).padStart(2, '0')}:${minutes}`);
    }
  }, [value]);

  // Gọi onChange khi có thay đổi - CHỈ MỘT useEffect
  useEffect(() => {
    if (date && startTime && endTime) {
      // Validate thời gian
      const startHour = parseInt(startTime.split(':')[0]);
      const endHour = parseInt(endTime.split(':')[0]);
      
      if (startHour >= 0 && startHour <= 23 && endHour >= 0 && endHour <= 23) {
        const timeRangeData = {
          date,
          startTime,
          endTime
        };
        onChange(JSON.stringify(timeRangeData));
      }
    }
  }, [date, startTime, endTime, onChange]);

  const formatDisplayValue = () => {
    if (date && startTime && endTime) {
      const dateObj = new Date(date);
      const formattedDate = dateObj.toLocaleDateString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
      });
      return `${formattedDate} | ${startTime} - ${endTime}`;
    }
    return placeholder;
  };

  return (
    <div className={`relative ${className}`}>
      <div
        className={`
          flex items-center space-x-3 p-4 border rounded-lg cursor-pointer
          ${disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white hover:border-blue-500'}
          ${isOpen ? 'border-blue-500 ring-2 ring-blue-200' : 'border-gray-300'}
        `}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        <Calendar className="w-5 h-5 text-gray-500" />
        <span className="flex-1 text-base text-gray-700 font-medium">
          {formatDisplayValue()}
        </span>
        <Clock className="w-5 h-5 text-gray-500" />
      </div>

      {isOpen && !disabled && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-300 rounded-lg shadow-lg z-50 p-4">
          <div className="space-y-4">
            {/* Date Picker */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Ngày tuần tra
              </label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                min={new Date().toISOString().split('T')[0]}
              />
            </div>

            {/* Time Range Picker */}
            <div className="grid grid-cols-2 gap-4">
              {/* Start Time */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                  <Play className="w-4 h-4 mr-1 text-green-600" />
                  Bắt đầu
                </label>
                <input
                  type="time"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>

              {/* End Time */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                  <Square className="w-4 h-4 mr-1 text-red-600" />
                  Kết thúc
                </label>
                <input
                  type="time"
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>

            {/* Time Range Display */}
            {startTime && endTime && (
              <div className="bg-blue-50 p-3 rounded-md">
                <div className="text-sm text-blue-800">
                  <div className="font-medium">Khoảng thời gian:</div>
                  <div className="flex items-center space-x-2 mt-1">
                    <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-xs">
                      {startTime}
                    </span>
                    <span className="text-gray-500">→</span>
                    <span className="px-2 py-1 bg-red-100 text-red-800 rounded text-xs">
                      {endTime}
                    </span>
                  </div>
                </div>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex justify-end space-x-2">
              <button
                onClick={() => setIsOpen(false)}
                className="px-4 py-2 text-sm text-gray-600 hover:text-gray-800"
              >
                Hủy
              </button>
              <button
                onClick={() => setIsOpen(false)}
                className="px-4 py-2 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700"
              >
                Xác nhận
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TimeRangePicker;
