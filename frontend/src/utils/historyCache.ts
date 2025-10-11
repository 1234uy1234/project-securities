import { openDB } from 'idb'
import { PatrolRecord } from './types'

const DB_NAME = 'patrol-offline-db'
const STORE = 'history-cache'

async function getDB() {
  return openDB(DB_NAME, 1, {
    upgrade(db) {
      if (!db.objectStoreNames.contains(STORE)) {
        db.createObjectStore(STORE)
      }
    },
  })
}

export async function saveHistory(records: PatrolRecord[]) {
  const db = await getDB()
  await db.put(STORE, records, 'my-history')
}

export async function loadHistory(): Promise<PatrolRecord[] | null> {
  const db = await getDB()
  return (await db.get(STORE, 'my-history')) || null
}
