#!/bin/bash

# Copy photos from backend/uploads to frontend/public
echo "📸 Copying photos to frontend public folder..."

# Copy all photos
cp /Users/maybe/Documents/shopee/backend/uploads/*.jpg /Users/maybe/Documents/shopee/frontend/public/ 2>/dev/null || true

echo "✅ Photos copied successfully!"
