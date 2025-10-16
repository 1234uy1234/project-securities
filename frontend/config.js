// Cấu hình động cho frontend
export const config = {
  API_BASE_URL: 'https://manhtoan-patrol.serveo.net',
  API_TIMEOUT: 10000,
  SSL_VERIFY: false
}

export const updateConfig = (newConfig) => {
  Object.assign(config, newConfig)
}
