// Cấu hình động cho frontend
// File này được tạo tự động bởi script setup

export const config = {
  // Địa chỉ backend - được cập nhật tự động
  API_BASE_URL: 'https://biuniquely-wreckful-blake.ngrok-free.dev',
  API_TIMEOUT: 10000,
  SSL_VERIFY: false
}

// Hàm để cập nhật cấu hình từ bên ngoài
export const updateConfig = (newConfig) => {
  Object.assign(config, newConfig)
}
