// Test FlowStep Logic Fix
// Kiểm tra xem task có được đánh dấu hoàn thành đúng không

console.log('🧪 Testing FlowStep Logic Fix...\n');

// Mock data - giả lập dữ liệu từ database
const mockTasks = [
  {
    id: 1,
    title: "Tuần tra khu vực A",
    status: "COMPLETED", // Task đã hoàn thành
    created_at: "2024-01-15T08:00:00+07:00"
  },
  {
    id: 2,
    title: "Tuần tra khu vực B", 
    status: "PENDING", // Task chưa hoàn thành
    created_at: "2024-01-15T08:00:00+07:00"
  }
];

const mockCheckinRecords = [
  {
    id: 1,
    task_id: 1,
    location_id: 101,
    check_in_time: "2024-01-15T09:00:00+07:00",
    check_out_time: "2024-01-15T10:30:00+07:00", // Có checkout - hoàn thành
    user_name: "Nguyễn Văn A"
  },
  {
    id: 2,
    task_id: 2,
    location_id: 102,
    check_in_time: "2024-01-15T09:15:00+07:00",
    check_out_time: null, // Chưa checkout - chưa hoàn thành
    user_name: "Nguyễn Văn B"
  }
];

const mockStops = [
  {
    id: 1,
    task_id: 1,
    location_id: 101,
    location_name: "Khu vực A",
    sequence: 1,
    required: true
  },
  {
    id: 2,
    task_id: 2,
    location_id: 102,
    location_name: "Khu vực B",
    sequence: 1,
    required: true
  }
];

// Hàm tìm checkin record
function findCheckinRecord(taskId, locationId) {
  const record = mockCheckinRecords.find(record => 
    record.task_id === taskId && record.location_id === locationId
  );
  console.log(`🔍 Finding checkin record for task: ${taskId}, location: ${locationId}`);
  console.log('Found record:', record);
  if (record) {
    console.log('Record details:', {
      task_id: record.task_id,
      location_id: record.location_id,
      check_in_time: record.check_in_time,
      check_out_time: record.check_out_time,
      has_checkout: !!(record.check_out_time && record.check_out_time !== null && record.check_out_time !== '')
    });
  }
  return record;
}

// Hàm kiểm tra trạng thái vị trí (FlowStep logic)
function getLocationStatus(stop, task) {
  console.log(`\n📍 Checking status for stop: ${stop.location_name} (Task: ${task.title})`);
  
  // Tìm checkin record
  const hasCheckin = findCheckinRecord(stop.task_id, stop.location_id);
  
  // Nếu đã chấm công thực sự VÀ có check-out (hoàn thành)
  if (hasCheckin && hasCheckin.check_out_time && hasCheckin.check_out_time !== null && hasCheckin.check_out_time !== '') {
    console.log('✅ COMPLETED: Has checkin with checkout - Task is completed');
    return { status: 'completed', color: 'green', text: 'Đã hoàn thành' };
  }
  
  // Nếu chưa chấm công
  if (!hasCheckin) {
    console.log('🔵 PENDING: No checkin record found');
    return { status: 'pending', color: 'blue', text: 'Chờ chấm công' };
  }
  
  // Nếu đã check-in nhưng chưa check-out
  if (hasCheckin && (!hasCheckin.check_out_time || hasCheckin.check_out_time === null || hasCheckin.check_out_time === '')) {
    console.log('🟡 ACTIVE: Has checkin but no checkout');
    return { status: 'active', color: 'yellow', text: 'Đang thực hiện' };
  }
  
  console.log('⚪ UNKNOWN: Cannot determine status');
  return { status: 'pending', color: 'gray', text: 'Chưa xác định' };
}

// Test cases
console.log('📋 Test Cases:\n');

// Test Case 1: Task hoàn thành (có checkout)
console.log('🧪 Test Case 1: Task hoàn thành');
const stop1 = mockStops[0];
const task1 = mockTasks[0];
const status1 = getLocationStatus(stop1, task1);
console.log(`Result: ${status1.text} (${status1.color})`);
console.log(`Expected: Đã hoàn thành (green)`);
console.log(`✅ ${status1.color === 'green' && status1.text === 'Đã hoàn thành' ? 'PASS' : 'FAIL'}\n`);

// Test Case 2: Task chưa hoàn thành (chưa checkout)
console.log('🧪 Test Case 2: Task chưa hoàn thành');
const stop2 = mockStops[1];
const task2 = mockTasks[1];
const status2 = getLocationStatus(stop2, task2);
console.log(`Result: ${status2.text} (${status2.color})`);
console.log(`Expected: Đang thực hiện (yellow)`);
console.log(`✅ ${status2.color === 'yellow' && status2.text === 'Đang thực hiện' ? 'PASS' : 'FAIL'}\n`);

// Test Case 3: Task chưa chấm công
console.log('🧪 Test Case 3: Task chưa chấm công');
const stop3 = { ...mockStops[0], location_id: 999 }; // Không có record
const task3 = mockTasks[0];
const status3 = getLocationStatus(stop3, task3);
console.log(`Result: ${status3.text} (${status3.color})`);
console.log(`Expected: Chờ chấm công (blue)`);
console.log(`✅ ${status3.color === 'blue' && status3.text === 'Chờ chấm công' ? 'PASS' : 'FAIL'}\n`);

console.log('🎯 Summary:');
console.log('- Task có checkout → Hiển thị "Đã hoàn thành" (xanh)');
console.log('- Task chưa checkout → Hiển thị "Đang thực hiện" (vàng)');
console.log('- Task chưa chấm công → Hiển thị "Chờ chấm công" (xanh dương)');
console.log('\n✅ FlowStep logic đã được sửa!');
