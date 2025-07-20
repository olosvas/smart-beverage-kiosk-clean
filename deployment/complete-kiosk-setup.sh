#!/bin/bash

# Complete Kiosk Setup - Browser + Hardware Bridge
echo "Complete Kiosk Setup - Cloud API + Local Hardware"
echo "================================================"

cd /home/oliver/kiosk-app

# Kill any existing processes
pm2 kill 2>/dev/null || true
pkill -f node || true
pkill -f python3 || true
pkill chromium-browser || true

# Install Python requests if not available
echo "Installing Python dependencies..."
pip3 install requests --user 2>/dev/null || echo "Requests already installed"

# Make hardware bridge executable
chmod +x deployment/hardware-bridge.py

# Start hardware bridge in background
echo "Starting hardware bridge..."
python3 deployment/hardware-bridge.py &
BRIDGE_PID=$!

echo "Hardware bridge started with PID: $BRIDGE_PID"

# Create systemd service for hardware bridge (persistent)
echo "Creating systemd service..."
sudo tee /etc/systemd/system/kiosk-hardware.service > /dev/null << EOF
[Unit]
Description=Kiosk Hardware Bridge
After=network.target

[Service]
Type=simple
User=oliver
WorkingDirectory=/home/oliver/kiosk-app
ExecStart=/usr/bin/python3 /home/oliver/kiosk-app/deployment/hardware-bridge.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable kiosk-hardware.service
sudo systemctl start kiosk-hardware.service

echo "Hardware bridge service installed and started"

# Setup browser autostart
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/kiosk-browser.desktop << EOF
[Desktop Entry]
Type=Application
Name=Kiosk Browser
Exec=chromium-browser --kiosk --disable-web-security --disable-infobars --disable-dev-shm-usage https://smart-beverage-dispenser-uzisinapoj.replit.app
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Start browser
echo "Starting kiosk browser..."
chromium-browser --kiosk --disable-web-security --disable-infobars --disable-dev-shm-usage https://smart-beverage-dispenser-uzisinapoj.replit.app &

echo ""
echo "✅ Complete Kiosk Setup Finished!"
echo "================================"
echo "🌐 Browser: Running kiosk interface from cloud"
echo "🔧 Hardware: Bridge service running in background"
echo "💾 Database: Using production PostgreSQL"
echo "🔄 Auto-start: Configured for reboot"
echo ""
echo "System Status:"
echo "- Kiosk URL: https://smart-beverage-dispenser-uzisinapoj.replit.app"
echo "- Admin URL: https://smart-beverage-dispenser-uzisinapoj.replit.app/admin"
echo "- Hardware Bridge: systemctl status kiosk-hardware"
echo ""
echo "The kiosk interface connects to the cloud API,"
echo "while the hardware bridge controls local GPIO pins"
echo "for valve and sensor operations."