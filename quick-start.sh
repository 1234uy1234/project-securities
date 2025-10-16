#!/bin/bash

# Quick Start Script for Smart Patrol System
# This script provides a simple way to start the development environment

echo "🚀 Smart Patrol System - Quick Start"
echo "===================================="

# Check if we're in the right directory
if [ ! -f "run-dev.sh" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Check dependencies
echo "🔍 Checking dependencies..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python3 first."
    exit 1
fi

# Check ngrok
if ! command -v ngrok &> /dev/null; then
    echo "⚠️  ngrok is not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install ngrok/ngrok/ngrok
        else
            echo "❌ Homebrew not found. Please install ngrok manually: https://ngrok.com/download"
            exit 1
        fi
    else
        echo "❌ Please install ngrok manually: https://ngrok.com/download"
        exit 1
    fi
fi

# Check cloudflared (optional)
if ! command -v cloudflared &> /dev/null; then
    echo "⚠️  cloudflared is not installed. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install cloudflared
        else
            echo "⚠️  Homebrew not found. cloudflared will be skipped (fallback won't work)"
        fi
    else
        echo "⚠️  Please install cloudflared manually for fallback support: https://github.com/cloudflare/cloudflared/releases"
    fi
fi

echo "✅ Dependencies check completed"

# Install project dependencies
echo "📦 Installing project dependencies..."

# Install frontend dependencies
if [ -d "frontend" ]; then
    echo "Installing frontend dependencies..."
    cd frontend
    if [ ! -d "node_modules" ]; then
        npm install
    fi
    cd ..
else
    echo "❌ Frontend directory not found"
    exit 1
fi

# Install backend dependencies
if [ -d "backend" ]; then
    echo "Installing backend dependencies..."
    cd backend
    if [ ! -d "venv" ] && [ ! -d ".venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        echo "Virtual environment already exists"
    fi
    cd ..
else
    echo "❌ Backend directory not found"
    exit 1
fi

echo "✅ Dependencies installation completed"

# Make run-dev.sh executable
chmod +x run-dev.sh

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "To start the development environment, run:"
echo "  npm run dev"
echo "  or"
echo "  ./run-dev.sh"
echo ""
echo "The system will automatically:"
echo "  ✅ Start backend on port 8000"
echo "  ✅ Start frontend on port 5173"
echo "  ✅ Start ngrok tunnel"
echo "  ✅ Switch to Cloudflare if ngrok fails"
echo ""
echo "Happy coding! 🚀"
