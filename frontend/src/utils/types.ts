export type UserRole = 'employee' | 'manager' | 'admin'
export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled'

export interface Location {
  id: number
  name: string
  description?: string
  address?: string
  gps_latitude?: number
  gps_longitude?: number
  qr_code: string
  created_at: string
  updated_at?: string
}

export interface PatrolTask {
  id: number
  title: string
  description?: string
  location_id: number
  assigned_to: number
  schedule_week: string
  status: TaskStatus
  created_by: number
  created_at: string
  updated_at?: string
  location?: Location
  assigned_user_name?: string
  location_name?: string
  stops?: Array<{
    id: number
    location_id: number
    location_name: string
    sequence: number
    scheduled_time: string
    visited_at?: string
  }>
}

export interface PatrolRecord {
  id: number
  user_id: number
  task_id: number
  location_id: number
  check_in_time: string
  check_out_time?: string
  gps_latitude: number
  gps_longitude: number
  photo_url?: string
  notes?: string
  created_at: string
}
