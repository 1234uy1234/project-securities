/**
 * Utility functions để lấy cấu hình URL
 */

// NUCLEAR HTTPS - KHÔNG DÙNG BIẾN MÔI TRƯỜNG
const NUCLEAR_HTTPS_URL = 'https://biuniquely-wreckful-blake.ngrok-free.dev'

export const getBaseUrl = () => {
  return NUCLEAR_HTTPS_URL
}

// Lấy URL cho ảnh uploads
export const getImageUrl = (imagePath: string) => {
  const baseUrl = getBaseUrl()
  
  if (!imagePath) {
    return ''
  }
  
  // Nếu là dữ liệu base64 thì trả về trực tiếp
  if (imagePath.startsWith('data:image/')) {
    return imagePath
  }
  
  // Nếu đã có http/https thì dùng luôn
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath
  }
  
  // Nếu bắt đầu với /uploads/ thì chỉ cần thêm baseUrl
  if (imagePath.startsWith('/uploads/')) {
    return `${baseUrl}${imagePath}`
  }
  
  // Nếu chỉ có tên file thì thêm /uploads/
  return `${baseUrl}/uploads/${imagePath}`
}

// Lấy URL cho QR code
export const getQRCodeUrl = (qrCodeId: number) => {
  const baseUrl = getBaseUrl()
  return `${baseUrl}/api/qr-codes/${qrCodeId}/image`
}
