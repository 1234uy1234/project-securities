#!/bin/bash

echo "🔍 Test event checkin-success..."

# Tạo file HTML test để dispatch event
cat > /Users/maybe/Documents/shopee/test-event.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Event</title>
</head>
<body>
    <h1>Test Event checkin-success</h1>
    <button onclick="dispatchEvent()">Dispatch Event</button>
    <div id="log"></div>
    
    <script>
        function log(message) {
            document.getElementById('log').innerHTML += '<div>' + new Date().toISOString() + ': ' + message + '</div>';
        }
        
        // Listen for checkin-success event
        window.addEventListener('checkin-success', function(event) {
            log('✅ Event received: ' + JSON.stringify(event.detail));
        });
        
        function dispatchEvent() {
            log('🚀 Dispatching event...');
            window.dispatchEvent(new CustomEvent('checkin-success', { 
                detail: { 
                    qrData: 'test-qr',
                    photo: 'YES',
                    timestamp: new Date().toISOString()
                } 
            }));
            log('✅ Event dispatched');
        }
        
        log('📡 Event listener registered');
    </script>
</body>
</html>
EOF

echo "✅ Test file created: /Users/maybe/Documents/shopee/test-event.html"
echo "🌐 Open: https://10.10.68.200:5173/test-event.html"
echo "🔍 Click button to test event dispatch"

