#!/bin/bash

echo "🚀 Final Pi setup - no database needed"

# Stop existing
pm2 stop beverage-kiosk 2>/dev/null || true
pm2 delete beverage-kiosk 2>/dev/null || true

# Build
npm run build

# Start without database dependency
pm2 start dist/index.js --name beverage-kiosk --env NODE_ENV=development --env PORT=3000

# Check
sleep 3
pm2 status
curl -s http://localhost:3000 | head -c 100

echo "✅ Kiosk ready at http://localhost:3000"
