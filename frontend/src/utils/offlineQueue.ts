import { openDB } from 'idb'
import { api } from './api'

type ScanPayload = {
  task_id: number
  location_id: number
  gps_latitude: number
  gps_longitude: number
  notes?: string
  photoDataUrl?: string
  createdAt: number
}

const DB_NAME = 'OfflineQueueDB'
const STORE_NAME = 'offlineQueue'

async function getDB() {
  return openDB(DB_NAME, 1, {
    upgrade(db) {
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        db.createObjectStore(STORE_NAME, { keyPath: 'createdAt' })
      }
    },
  })
}

export async function enqueueScan(data: ScanPayload) {
  try {
    const db = await getDB()
    await db.add(STORE_NAME, data)
    console.log('📱 Offline scan queued:', data.createdAt)
    
    // Show notification
    if ('serviceWorker' in navigator && 'Notification' in window) {
      if (Notification.permission === 'granted') {
        new Notification('📱 Check-in Offline', {
          body: 'Dữ liệu đã được lưu offline. Sẽ sync khi có mạng.',
          icon: '/logo.svg'
        })
      }
    }
  } catch (error) {
    console.error('❌ Failed to queue offline scan:', error)
    throw error
  }
}

export async function flushQueue() {
  try {
    console.log('🔄 Starting offline queue flush...')
    const db = await getDB()
    const tx = db.transaction(STORE_NAME, 'readwrite')
    const store = tx.store
    const all = await store.getAll()

    if (all.length === 0) {
      console.log('📱 No offline scans to sync')
      return
    }

    console.log(`📱 Found ${all.length} offline scans to sync`)

    let successCount = 0
    let errorCount = 0

    for (const item of all) {
      try {
        console.log(`🔄 Syncing scan ${item.createdAt}...`)
        
        const form = new FormData()
        form.append('qr_data', item.notes || '')
        
        // Convert photo data URL to blob
        if (item.photoDataUrl) {
          const blob = await (await fetch(item.photoDataUrl)).blob()
          form.append('photo', blob, `offline-scan-${item.createdAt}.jpg`)
        }

        const response = await api.post('/simple', form)
        
        if (response.status === 200) {
          await store.delete(item.createdAt)
          successCount++
          console.log(`✅ Synced scan ${item.createdAt}`)
        } else {
          console.error(`❌ Failed to sync scan ${item.createdAt}:`, response.status)
          errorCount++
          break // Stop on first error
        }
      } catch (err) {
        console.error(`❌ Error syncing scan ${item.createdAt}:`, err)
        errorCount++
        break // Stop on first error
      }
    }

    await tx.done
    
    console.log(`✅ Queue flush completed: ${successCount} success, ${errorCount} errors`)
    
    // Show notification
    if (successCount > 0) {
      if ('serviceWorker' in navigator && 'Notification' in window) {
        if (Notification.permission === 'granted') {
          new Notification('✅ Sync Hoàn Thành', {
            body: `Đã sync ${successCount} check-in offline`,
            icon: '/logo.svg'
          })
        }
      }
    }
    
  } catch (error) {
    console.error('❌ Queue flush failed:', error)
    throw error
  }
}

export async function getQueueStatus() {
  try {
    const db = await getDB()
    const tx = db.transaction(STORE_NAME, 'readonly')
    const store = tx.store
    const all = await store.getAll()
    
    return {
      count: all.length,
      items: all.map(item => ({
        createdAt: item.createdAt,
        notes: item.notes,
        hasPhoto: !!item.photoDataUrl
      }))
    }
  } catch (error) {
    console.error('❌ Failed to get queue status:', error)
    return { count: 0, items: [] }
  }
}

export async function clearQueue() {
  try {
    const db = await getDB()
    const tx = db.transaction(STORE_NAME, 'readwrite')
    const store = tx.store
    await store.clear()
    await tx.done
    console.log('🗑️ Offline queue cleared')
  } catch (error) {
    console.error('❌ Failed to clear queue:', error)
    throw error
  }
}

export function setupOnlineSync() {
  // Listen for online event
  window.addEventListener('online', async () => {
    console.log('🌐 Back online - starting sync...')
    
    try {
      await flushQueue()
    } catch (error) {
      console.error('❌ Online sync failed:', error)
    }
  })

  // Listen for offline event
  window.addEventListener('offline', () => {
    console.log('📱 Gone offline')
  })

  // Periodic sync check (every 30 seconds when online)
  setInterval(async () => {
    if (navigator.onLine) {
      try {
        const status = await getQueueStatus()
        if (status.count > 0) {
          console.log(`📱 Found ${status.count} pending offline scans`)
          await flushQueue()
        }
      } catch (error) {
        console.error('❌ Periodic sync failed:', error)
      }
    }
  }, 30000) // 30 seconds

  // Request notification permission
  if ('Notification' in window && Notification.permission === 'default') {
    Notification.requestPermission()
  }
}

// Background sync registration
export function registerBackgroundSync() {
  if ('serviceWorker' in navigator && 'sync' in window.ServiceWorkerRegistration.prototype) {
    navigator.serviceWorker.ready.then(registration => {
      return registration.sync.register('checkin-sync')
    }).catch(error => {
      console.error('❌ Background sync registration failed:', error)
    })
  }
}
