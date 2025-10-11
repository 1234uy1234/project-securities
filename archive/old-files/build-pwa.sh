#!/bin/bash

echo "🚀 Building MANHTOAN PLASTIC PWA..."

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf dist

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Build PWA
echo "🔨 Building PWA..."
npm run build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Check PWA files
    echo "🔍 Checking PWA files..."
    
    if [ -f "dist/manifest.json" ]; then
        echo "✅ Manifest file found"
    else
        echo "❌ Manifest file missing"
    fi
    
    if [ -f "dist/sw.js" ] || [ -f "dist/workbox-*.js" ]; then
        echo "✅ Service worker found"
    else
        echo "❌ Service worker missing"
    fi
    
    if [ -f "dist/index.html" ]; then
        echo "✅ HTML file found"
    else
        echo "❌ HTML file missing"
    fi
    
    # Check for PWA icons
    icon_count=$(find dist -name "*.png" -o -name "*.svg" | wc -l)
    echo "📱 Found $icon_count icon files"
    
    # Show build size
    build_size=$(du -sh dist | cut -f1)
    echo "📊 Build size: $build_size"
    
    # Start preview server
    echo "🌐 Starting preview server..."
    echo "📱 Test PWA at: http://localhost:4173"
    echo "🔧 Use Chrome DevTools → Application tab to test PWA features"
    echo "📊 Use Lighthouse to audit PWA score"
    
    npm run preview
    
else
    echo "❌ Build failed!"
    exit 1
fi
