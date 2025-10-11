// Test timezone display
const testTimes = [
  '2025-10-03 15:59:59.722633',
  '2025-10-03 15:54:55.293854', 
  '2025-10-03 15:38:49.396835'
];

console.log('🔍 Test hiển thị thời gian:');
console.log('Thời gian hiện tại:', new Date().toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' }));
console.log();

testTimes.forEach((timeStr, index) => {
  const date = new Date(timeStr);
  const vietnamTime = date.toLocaleString('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh' });
  
  console.log(`Test ${index + 1}:`);
  console.log(`  Input: ${timeStr}`);
  console.log(`  Output: ${vietnamTime}`);
  console.log();
});
