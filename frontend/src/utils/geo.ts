export function getCurrentPosition(options?: PositionOptions): Promise<GeolocationPosition> {
  return new Promise((resolve, reject) => {
    if (!('geolocation' in navigator)) {
      reject(new Error('Thiết bị không hỗ trợ định vị'))
      return
    }
    navigator.geolocation.getCurrentPosition(resolve, reject, options)
  })
}
