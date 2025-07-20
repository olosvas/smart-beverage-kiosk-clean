#!/bin/bash

# Emergency Kiosk Setup - Direct HTML file approach
echo "Emergency Kiosk Setup - Using Production API Directly"
echo "===================================================="

cd /home/oliver/kiosk-app

# Kill everything
pm2 kill 2>/dev/null || true
pkill -f node || true
pkill chromium-browser || true

# Create a simple HTTP server using Python
echo "Starting simple HTTP server for kiosk..."

# Copy the HTML file to a simple location
cp deployment/simple-kiosk.html /tmp/kiosk.html

# Start Python HTTP server in background
cd /tmp
python3 -m http.server 8080 &
SERVER_PID=$!

echo "HTTP server started with PID: $SERVER_PID"
sleep 2

# Test if server is running
if curl -s http://localhost:8080 >/dev/null; then
    echo "✅ Local server is running on port 8080"
else
    echo "❌ Local server failed to start"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

# Create autostart for the simple kiosk
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/kiosk.desktop << EOF
[Desktop Entry]
Type=Application
Name=Emergency Kiosk
Exec=chromium-browser --kiosk --disable-web-security --disable-infobars https://smart-beverage-dispenser-uzisinapoj.replit.app
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Start browser directly to production URL
echo "🌐 Starting browser with production kiosk..."
chromium-browser --kiosk --disable-web-security --disable-infobars https://smart-beverage-dispenser-uzisinapoj.replit.app &

echo ""
echo "✅ Emergency Kiosk is Running!"
echo "=============================="
echo "The browser should now show the full kiosk interface"
echo "It's connecting directly to the production server"
echo "No local server needed - everything runs from the cloud"
echo ""
echo "URLs:"
echo "- Kiosk: https://smart-beverage-dispenser-uzisinapoj.replit.app"
echo "- Admin: https://smart-beverage-dispenser-uzisinapoj.replit.app/admin"
echo ""
echo "This setup bypasses all local server issues"
echo "Your Pi will connect directly to the production API"