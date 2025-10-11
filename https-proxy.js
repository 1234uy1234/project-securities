const https = require('https');
const fs = require('fs');
const { exec } = require('child_process');

// SSL options
const sslOptions = {
  key: fs.readFileSync('/Users/maybe/Documents/shopee/ssl/server.key'),
  cert: fs.readFileSync('/Users/maybe/Documents/shopee/ssl/server.crt')
};

// Start Vite dev server
console.log('🚀 Starting Vite dev server...');
const viteProcess = exec('npm run dev -- --host 10.10.68.200 --port 3000', {
  cwd: '/Users/maybe/Documents/shopee/frontend',
  env: { ...process.env, VITE_API_BASE_URL: 'https://semiprivate-interlamellar-phillis.ngrok-free.dev' }
});

viteProcess.stdout.on('data', (data) => {
  console.log(data.toString());
});

viteProcess.stderr.on('data', (data) => {
  console.error(data.toString());
});

// Wait for Vite to start
setTimeout(() => {
  console.log('🔐 Starting HTTPS proxy server...');
  
  // Create HTTPS proxy server
  const server = https.createServer(sslOptions, (req, res) => {
    // Proxy to Vite dev server
    const proxyReq = require('http').request({
      hostname: 'semiprivate-interlamellar-phillis.ngrok-free.dev',
      port: 3000,
      path: req.url,
      method: req.method,
      headers: req.headers
    }, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    });
    
    req.pipe(proxyReq);
  });

  server.listen(5173, '10.10.68.200', () => {
    console.log('✅ HTTPS Frontend running on https://semiprivate-interlamellar-phillis.ngrok-free.dev:5173');
  });
}, 5000);
