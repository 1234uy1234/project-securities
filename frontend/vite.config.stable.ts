import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react({
      // Tắt hot reload để tránh auto-reload
      fastRefresh: false
    }),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        skipWaiting: true,
        clientsClaim: true
      },
      manifest: {
        name: 'MANHTOAN PLASTIC - Hệ thống Tuần tra thông minh',
        short_name: 'Tuần tra MT',
        description: 'Hệ thống tuần tra thông minh sử dụng mã QR và GPS cho ManhToan Plastic',
        theme_color: '#10b981',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait-primary',
        scope: '/',
        start_url: '/',
        lang: 'vi',
        categories: ['business', 'productivity', 'utilities'],
        icons: [
          {
            src: '/logo-192x192.png',
            sizes: '192x192',
            type: 'image/png',
            purpose: 'any maskable'
          },
          {
            src: '/logo-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable'
          },
          {
            src: '/logo.svg',
            sizes: 'any',
            type: 'image/svg+xml',
            purpose: 'any'
          }
        ]
      }
    })
  ],
  server: {
    host: true,
    port: 5173,
    https: {
      key: '/Users/maybe/Documents/shopee/ssl/server.key',
      cert: '/Users/maybe/Documents/shopee/ssl/server.crt'
    },
    strictPort: false,
    // Tắt HMR để tránh auto-reload
    hmr: false,
    // Tắt watch để tránh auto-reload
    watch: {
      ignored: ['**/node_modules/**', '**/dist/**']
    }
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          ui: ['lucide-react']
        }
      }
    }
  }
})
