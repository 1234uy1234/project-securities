import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './index.css'
import * as serviceWorkerRegistration from './serviceWorkerRegistration';
import { Toaster } from 'react-hot-toast'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
      <Toaster 
        position="top-right"
        toastOptions={{
          duration: 2000, // Giảm xuống 2 giây
          style: {
            background: '#363636',
            color: '#fff',
            cursor: 'pointer',
            borderRadius: '8px',
            padding: '12px 16px',
            fontSize: '14px',
            maxWidth: '400px',
          },
          onClick: (event, toast) => {
            // Click để tắt toast
            toast.dismiss();
          },
        }}
      />
    </BrowserRouter>
  </React.StrictMode>,
)

// Register service worker for PWA
serviceWorkerRegistration.register({});
