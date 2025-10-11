#!/bin/bash

echo "🔍 Test FlowStepProgress photoUrl logic..."

# Test với user admin để xem checkin records
LOGIN_RESPONSE=$(curl -k -s -X POST https://10.10.68.200:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo "1. Lấy checkin records..."
  CHECKIN_RECORDS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/checkin/admin/all-records)
  
  echo "Checkin records:"
  echo "$CHECKIN_RECORDS" | jq '.[0:3] | .[] | {id, task_id, location_id, check_in_time, photo_url, notes}'
  
  echo ""
  echo "2. Lấy patrol tasks..."
  PATROL_TASKS=$(curl -k -s -H "Authorization: Bearer $TOKEN" \
    https://10.10.68.200:8000/api/patrol-tasks/)
  
  echo "Patrol tasks:"
  echo "$PATROL_TASKS" | jq '.[0:2] | .[] | {id, title, status, stops: [.stops[] | {location_id, sequence, scheduled_time, completed}]}'
  
  echo ""
  echo "3. Kiểm tra logic thời gian..."
  
  # Lấy một checkin record cụ thể
  FIRST_RECORD=$(echo "$CHECKIN_RECORDS" | jq '.[0]')
  if [ "$FIRST_RECORD" != "null" ]; then
    TASK_ID=$(echo "$FIRST_RECORD" | jq -r '.task_id')
    LOCATION_ID=$(echo "$FIRST_RECORD" | jq -r '.location_id')
    CHECKIN_TIME=$(echo "$FIRST_RECORD" | jq -r '.check_in_time')
    PHOTO_URL=$(echo "$FIRST_RECORD" | jq -r '.photo_url')
    
    echo "First record:"
    echo "  Task ID: $TASK_ID"
    echo "  Location ID: $LOCATION_ID"
    echo "  Check-in time: $CHECKIN_TIME"
    echo "  Photo URL: $PHOTO_URL"
    
    # Tìm task tương ứng
    TASK=$(echo "$PATROL_TASKS" | jq ".[] | select(.id == $TASK_ID)")
    if [ "$TASK" != "null" ]; then
      echo "  Task found: $(echo "$TASK" | jq -r '.title')"
      
      # Tìm stop tương ứng
      STOP=$(echo "$TASK" | jq ".stops[] | select(.location_id == $LOCATION_ID)")
      if [ "$STOP" != "null" ]; then
        SCHEDULED_TIME=$(echo "$STOP" | jq -r '.scheduled_time')
        echo "  Stop scheduled time: $SCHEDULED_TIME"
        
        # Tính toán thời gian
        if [ "$SCHEDULED_TIME" != "null" ] && [ "$CHECKIN_TIME" != "null" ]; then
          echo "  Time comparison:"
          echo "    Scheduled: $SCHEDULED_TIME"
          echo "    Check-in: $CHECKIN_TIME"
          
          # Parse thời gian
          SCHEDULED_HOUR=$(echo "$SCHEDULED_TIME" | cut -d':' -f1)
          SCHEDULED_MINUTE=$(echo "$SCHEDULED_TIME" | cut -d':' -f2)
          SCHEDULED_TOTAL=$((SCHEDULED_HOUR * 60 + SCHEDULED_MINUTE))
          
          CHECKIN_HOUR=$(echo "$CHECKIN_TIME" | cut -d'T' -f2 | cut -d':' -f1)
          CHECKIN_MINUTE=$(echo "$CHECKIN_TIME" | cut -d'T' -f2 | cut -d':' -f2)
          CHECKIN_TOTAL=$((CHECKIN_HOUR * 60 + CHECKIN_MINUTE))
          
          echo "    Scheduled total minutes: $SCHEDULED_TOTAL"
          echo "    Check-in total minutes: $CHECKIN_TOTAL"
          echo "    Difference: $((CHECKIN_TOTAL - SCHEDULED_TOTAL)) minutes"
          
          if [ $CHECKIN_TOTAL -ge $SCHEDULED_TOTAL ] && [ $CHECKIN_TOTAL -le $((SCHEDULED_TOTAL + 15)) ]; then
            echo "    ✅ Within time window (0-15 minutes after scheduled)"
          else
            echo "    ❌ Outside time window"
          fi
        fi
      fi
    fi
  fi
  
else
  echo "❌ Không thể lấy token!"
fi

echo ""
echo "✅ Test hoàn tất!"
