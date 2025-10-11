#!/bin/bash

echo "🔍 Dispatch event checkin-success thủ công..."

# Tạo file HTML để dispatch event
cat > /Users/maybe/Documents/shopee/dispatch-event.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Dispatch Event</title>
</head>
<body>
    <h1>Dispatch Event checkin-success</h1>
    <button onclick="dispatchEvent()">Dispatch Event</button>
    <div id="log"></div>
    
    <script>
        function log(message) {
            document.getElementById('log').innerHTML += '<div>' + new Date().toISOString() + ': ' + message + '</div>';
        }
        
        function dispatchEvent() {
            log('🚀 Dispatching checkin-success event...');
            
            // Dispatch event với data giống như QRScannerPage
            window.dispatchEvent(new CustomEvent('checkin-success', { 
                detail: { 
                    qrData: 'test-flowstep',
                    photo: 'YES',
                    timestamp: new Date().toISOString()
                } 
            }));
            
            log('✅ Event dispatched! Check Admin Dashboard for updates.');
        }
        
        log('📡 Ready to dispatch events');
    </script>
</body>
</html>
EOF

echo "✅ File created: /Users/maybe/Documents/shopee/dispatch-event.html"
echo "🌐 Open: https://10.10.68.200:5173/dispatch-event.html"
echo "🔍 Click button to dispatch event, then check Admin Dashboard"

