import React, { useState, useEffect } from 'react';
import { Calendar, Clock } from 'lucide-react';

interface DateTimePickerProps {
  value?: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  disabled?: boolean;
}

const DateTimePicker: React.FC<DateTimePickerProps> = ({
  value,
  onChange,
  placeholder = "Chọn ngày và giờ",
  className = "",
  disabled = false
}) => {
  const [date, setDate] = useState('');
  const [time, setTime] = useState('');
  const [isOpen, setIsOpen] = useState(false);

  // Khởi tạo giá trị mặc định
  useEffect(() => {
    if (value) {
      const dateTime = new Date(value);
      const year = dateTime.getFullYear();
      const month = String(dateTime.getMonth() + 1).padStart(2, '0');
      const day = String(dateTime.getDate()).padStart(2, '0');
      const hours = String(dateTime.getHours()).padStart(2, '0');
      const minutes = String(dateTime.getMinutes()).padStart(2, '0');
      
      setDate(`${year}-${month}-${day}`);
      setTime(`${hours}:${minutes}`);
    } else {
      // Mặc định là thời gian hiện tại
      const now = new Date();
      const year = now.getFullYear();
      const month = String(now.getMonth() + 1).padStart(2, '0');
      const day = String(now.getDate()).padStart(2, '0');
      const hours = String(now.getHours()).padStart(2, '0');
      const minutes = String(now.getMinutes()).padStart(2, '0');
      
      setDate(`${year}-${month}-${day}`);
      setTime(`${hours}:${minutes}`);
    }
  }, [value]);

  // Cập nhật giá trị khi date hoặc time thay đổi
  useEffect(() => {
    if (date && time) {
      const dateTime = new Date(`${date}T${time}`);
      onChange(dateTime.toISOString());
    }
  }, [date, time, onChange]);

  const formatDisplayValue = () => {
    if (date && time) {
      const dateTime = new Date(`${date}T${time}`);
      return dateTime.toLocaleString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      });
    }
    return placeholder;
  };

  return (
    <div className={`relative ${className}`}>
      <div
        className={`
          flex items-center space-x-2 p-3 border rounded-lg cursor-pointer
          ${disabled ? 'bg-gray-100 cursor-not-allowed' : 'bg-white hover:border-blue-500'}
          ${isOpen ? 'border-blue-500 ring-2 ring-blue-200' : 'border-gray-300'}
        `}
        onClick={() => !disabled && setIsOpen(!isOpen)}
      >
        <Calendar className="w-4 h-4 text-gray-500" />
        <span className="flex-1 text-sm text-gray-700">
          {formatDisplayValue()}
        </span>
        <Clock className="w-4 h-4 text-gray-500" />
      </div>

      {isOpen && !disabled && (
        <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-300 rounded-lg shadow-lg z-50 p-4">
          <div className="space-y-4">
            {/* Date Picker */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Ngày
              </label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                min={new Date().toISOString().split('T')[0]}
              />
            </div>

            {/* Time Picker */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Giờ
              </label>
              <input
                type="time"
                value={time}
                onChange={(e) => setTime(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

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

export default DateTimePicker;
