#!/bin/bash

echo "🚀 Starting simple kiosk server..."

# Stop any existing processes
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Start simple server
pm2 start deployment/pi-simple-server.js --name kiosk-simple --env PORT=3000

# Check status
pm2 status

echo "✅ Simple kiosk server started on port 3000"
echo "🌐 Open browser: http://localhost:3000"