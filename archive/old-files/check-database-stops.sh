#!/bin/bash

echo "🔍 Kiểm tra database patrol_task_stops..."

# Kiểm tra trực tiếp database
cd /Users/maybe/Documents/shopee/backend

echo "1. Kiểm tra patrol_task_stops table..."
python3 -c "
import sqlite3
conn = sqlite3.connect('patrol.db')
cursor = conn.cursor()

print('Patrol task stops:')
cursor.execute('SELECT id, task_id, location_id, sequence, scheduled_time, completed FROM patrol_task_stops ORDER BY task_id, sequence')
rows = cursor.fetchall()
for row in rows:
    print(f'  ID: {row[0]}, Task: {row[1]}, Location: {row[2]}, Sequence: {row[3]}, Scheduled: \"{row[4]}\", Completed: {row[5]}')

print()
print('Tasks with stops:')
cursor.execute('SELECT id, title, status FROM patrol_tasks WHERE id IN (SELECT DISTINCT task_id FROM patrol_task_stops)')
tasks = cursor.fetchall()
for task in tasks:
    print(f'  Task {task[0]}: {task[1]} (Status: {task[2]})')

conn.close()
"

echo ""
echo "2. Kiểm tra checkin records..."
python3 -c "
import sqlite3
conn = sqlite3.connect('patrol.db')
cursor = conn.cursor()

print('Recent checkin records:')
cursor.execute('SELECT id, task_id, location_id, check_in_time, photo_url FROM patrol_records ORDER BY check_in_time DESC LIMIT 5')
rows = cursor.fetchall()
for row in rows:
    print(f'  ID: {row[0]}, Task: {row[1]}, Location: {row[2]}, Time: {row[3]}, Photo: {row[4]}')

conn.close()
"
