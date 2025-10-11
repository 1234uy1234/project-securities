import React, { useState } from 'react';
import { getImageUrl } from '../utils/config';

interface CheckinRecord {
  id: number;
  user_name: string;
  user_username: string;
  task_title: string;
  location_name: string;
  check_in_time: string;
  check_out_time: string | null;
  photo_url: string | null;
  checkout_photo_url: string | null;
  notes: string;
  gps_latitude?: number;
  gps_longitude?: number;
}

interface CheckinDetailModalProps {
  isOpen: boolean;
  onClose: () => void;
  record: CheckinRecord | null;
}

const CheckinDetailModal: React.FC<CheckinDetailModalProps> = ({ isOpen, onClose, record }) => {
  const [showImageModal, setShowImageModal] = useState(false);
  
  if (!isOpen || !record) return null;
  
  // Debug logs
  console.log('🖼️ ===== CHECKIN DETAIL MODAL OPENED =====');
  console.log('🖼️ CheckinDetailModal opened with record:', record);
  console.log('🖼️ Record photo_url:', record.photo_url);
  console.log('🖼️ Record check_in_time:', record.check_in_time);
  console.log('🖼️ Record keys:', Object.keys(record));
  console.log('🖼️ ===========================================');
  
  // Test log để kiểm tra hot reload
  console.log('🔥 HOT RELOAD TEST - CheckinDetailModal updated!');
  console.log('🔥 TEST: record.photo_url =', record.photo_url);
  console.log('🔥 TEST: typeof record.photo_url =', typeof record.photo_url);

  // Debug log để kiểm tra record
  console.log('🔍 CheckinDetailModal - Record:', {
    id: record.id,
    check_in_time: record.check_in_time,
    photo_url: record.photo_url,
    task_title: record.task_title,
    location_name: record.location_name
  });

  const formatDateTime = (dateString: string) => {
    try {
      if (!dateString) return '-';
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return '-';
      // Sử dụng múi giờ Việt Nam (UTC+7)
      return date.toLocaleString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
    } catch (e) {
      return '-';
    }
  };

  const formatLocation = (lat?: number, lng?: number) => {
    if (!lat || !lng) return 'Không có thông tin GPS';
    return `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">
            Chi tiết chấm công
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Employee Info */}
          <div className="flex items-center space-x-4">
            <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center text-white text-xl font-bold">
              {record.user_name?.charAt(0) || 'U'}
            </div>
            <div>
              <h3 className="text-lg font-semibold text-gray-900">{record.user_name}</h3>
              <p className="text-gray-600">@{record.user_username || record.user_name?.toLowerCase()}</p>
            </div>
          </div>

          {/* Task Info */}
          <div className="bg-gray-50 rounded-lg p-4">
            <h4 className="font-medium text-gray-900 mb-2">Thông tin nhiệm vụ</h4>
            <div className="space-y-2 text-sm">
              <div>
                <span className="font-medium">Nhiệm vụ:</span> {record.task_title}
              </div>
              <div>
                <span className="font-medium">Vị trí:</span> {record.location_name}
              </div>
            </div>
          </div>

          {/* Time Info */}
          <div className={`rounded-lg p-4 ${
            record.check_in_time && record.check_in_time.trim() 
              ? (record.notes?.includes('đúng giờ') ? 'bg-green-50' : 
                 record.notes?.includes('quá sớm') ? 'bg-blue-50' : 
                 record.notes?.includes('quá muộn') ? 'bg-red-50' : 'bg-orange-50')
              : 'bg-red-50'
          }`}>
            <h4 className={`font-medium mb-2 ${
              record.check_in_time && record.check_in_time.trim() 
                ? (record.notes?.includes('đúng giờ') ? 'text-green-900' : 
                   record.notes?.includes('quá sớm') ? 'text-blue-900' : 
                   record.notes?.includes('quá muộn') ? 'text-red-900' : 'text-orange-900')
                : 'text-red-900'
            }`}>
              {record.check_in_time && record.check_in_time.trim() ? 'Thời gian chấm công' : 'Trạng thái chấm công'}
            </h4>
            <p className={`text-lg font-semibold ${
              record.check_in_time && record.check_in_time.trim() 
                ? (record.notes?.includes('đúng giờ') ? 'text-green-800' : 
                   record.notes?.includes('quá sớm') ? 'text-blue-800' : 
                   record.notes?.includes('quá muộn') ? 'text-red-800' : 'text-orange-800')
                : 'text-red-800'
            }`}>
              {record.check_in_time && record.check_in_time.trim() 
                ? formatDateTime(record.check_in_time) 
                : 'Chưa chấm công'
              }
            </p>
            {record.check_in_time && record.check_in_time.trim() && (
              <p className={`text-sm mt-1 ${
                record.notes?.includes('đã được chấm công') ? 'text-green-700' : 
                record.notes?.includes('quá sớm') ? 'text-blue-700' : 
                record.notes?.includes('quá muộn') ? 'text-red-700' : 'text-green-700'
              }`}>
                {record.notes?.includes('đã được chấm công') ? '✅ Đã chấm công' : 
                 record.notes?.includes('quá sớm') ? '⏰ Chấm công quá sớm' : 
                 record.notes?.includes('quá muộn') ? '⚠️ Chấm công quá muộn' : '✅ Đã chấm công'}
              </p>
            )}
          </div>

          {/* Photo */}
          <div>
            <h4 className="font-medium text-gray-900 mb-4">Ảnh chấm công</h4>
            {record.photo_url ? (
              <div className="relative">
            {(() => {
              const imageUrl = getImageUrl(record.photo_url);
              console.log('🖼️ ===== IMAGE LOADING START =====');
              console.log('🖼️ Loading image with URL:', imageUrl);
              console.log('🖼️ Full imageUrl length:', imageUrl.length);
              console.log('🖼️ record.photo_url:', record.photo_url);
              console.log('🖼️ ================================');
              return (
                    <img
                      src={imageUrl}
                      alt="Ảnh chấm công"
                      className="w-full h-64 object-cover rounded-lg border border-gray-200"
                      onLoad={(e) => {
                        console.log('✅ Image loaded successfully:', imageUrl);
                        // Ẩn placeholder khi ảnh tải thành công
                        const target = e.target as HTMLImageElement;
                        target.style.display = 'block';
                        const placeholder = target.nextElementSibling as HTMLElement;
                        if (placeholder) placeholder.style.display = 'none';
                      }}
                      onError={(e) => {
                        console.error('❌ ===== IMAGE LOAD ERROR =====');
                        console.error('❌ Lỗi tải ảnh:', e);
                        console.error('❌ URL ảnh:', imageUrl);
                        console.error('❌ record.photo_url gốc:', record.photo_url);
                        console.error('❌ =============================');
                        // Hiển thị placeholder khi ảnh lỗi
                        const target = e.target as HTMLImageElement;
                        target.style.display = 'none';
                        const placeholder = target.nextElementSibling as HTMLElement;
                        if (placeholder) placeholder.style.display = 'flex';
                      }}
                    />
                  );
                })()}
                {/* Placeholder khi ảnh đang tải hoặc lỗi */}
                <div className="w-full h-64 bg-gray-100 rounded-lg border border-gray-200 flex flex-col items-center justify-center text-gray-500" style={{display: 'none'}}>
                  <svg className="w-12 h-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  <p className="text-sm">Không thể tải ảnh</p>
                  <p className="text-xs text-gray-400 mt-1">Vui lòng thử lại sau</p>
                </div>
                <button
                  onClick={() => setShowImageModal(true)}
                  className="absolute top-2 right-2 bg-black bg-opacity-50 text-white p-2 rounded-full hover:bg-opacity-70 transition-colors"
                  title="Xem ảnh đầy đủ"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
                  </svg>
                </button>
              </div>
            ) : (
              <div className={`w-full h-64 rounded-lg flex flex-col items-center justify-center ${
                record.check_in_time && record.check_in_time.trim() 
                  ? (record.notes?.includes('đã được chấm công') ? 'bg-green-100 text-green-700' : 
                     record.notes?.includes('quá sớm') ? 'bg-blue-100 text-blue-700' : 
                     record.notes?.includes('quá muộn') ? 'bg-red-100 text-red-700' : 'bg-orange-100 text-orange-700')
                  : 'bg-red-100 text-red-600'
              }`}>
                {(() => {
                  console.log('🖼️ No photo_url found in record:', record);
                  console.log('🖼️ Record keys:', Object.keys(record));
                  return null;
                })()}
                <div className="flex items-center justify-center mb-2">
                  {record.check_in_time && record.check_in_time.trim() ? (
                    record.notes?.includes('đã được chấm công') ? (
                      <svg className="w-8 h-8 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    ) : record.notes?.includes('quá sớm') ? (
                      <svg className="w-8 h-8 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    ) : record.notes?.includes('quá muộn') ? (
                      <svg className="w-8 h-8 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                      </svg>
                    ) : (
                      <svg className="w-8 h-8 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    )
                  ) : (
                    <svg className="w-8 h-8 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  )}
                </div>
                <p className="font-medium text-center">
                  {record.check_in_time && record.check_in_time.trim() 
                    ? (record.notes?.includes('đã được chấm công') ? 'Đã chấm công nhưng không có ảnh' : 
                       record.notes?.includes('quá sớm') ? 'Đã chấm công quá sớm nhưng không có ảnh' : 
                       record.notes?.includes('quá muộn') ? 'Đã chấm công quá muộn nhưng không có ảnh' : 'Đã chấm công nhưng không có ảnh')
                    : 'Chưa chấm công'
                  }
                </p>
                <p className="text-sm mt-1 text-center px-4">
                  {record.check_in_time && record.check_in_time.trim() 
                    ? 'Có thể do lỗi upload ảnh hoặc không chụp ảnh'
                    : 'Cần quét QR và chụp ảnh để hoàn thành'
                  }
                </p>
              </div>
            )}
          </div>

          {/* Notes */}
          {record.notes && (
            <div>
              <h4 className="font-medium text-gray-900 mb-2">Ghi chú</h4>
              <div className="bg-gray-50 rounded-lg p-4">
                <p className="text-gray-700">{record.notes}</p>
              </div>
            </div>
          )}

          {/* GPS Info */}
          {(record.gps_latitude && record.gps_longitude) && (
            <div>
              <h4 className="font-medium text-gray-900 mb-2">Vị trí GPS</h4>
              <div className="bg-gray-50 rounded-lg p-4">
                <p className="text-sm text-gray-700">
                  {formatLocation(record.gps_latitude, record.gps_longitude)}
                </p>
                <a
                  href={`https://maps.google.com/?q=${record.gps_latitude},${record.gps_longitude}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-600 hover:text-blue-800 text-sm mt-2 inline-block"
                >
                  Xem trên Google Maps →
                </a>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex justify-end p-6 border-t border-gray-200">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
          >
            Đóng
          </button>
        </div>
      </div>

      {/* Image Modal */}
      {showImageModal && record.photo_url && (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-60 p-4">
          <div className="relative max-w-4xl max-h-full">
            <img
              src={getImageUrl(record.photo_url)}
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
  );
};

export default CheckinDetailModal;
