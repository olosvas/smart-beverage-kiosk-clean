#!/bin/bash

# Environment Setup Script for Raspberry Pi Deployment
# This script configures the environment and database for the kiosk system

set -e

echo "=== Smart Beverage Kiosk - Environment Setup ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Check if we're on Raspberry Pi
if [[ -f /proc/device-tree/model ]] && grep -q "Raspberry Pi" /proc/device-tree/model; then
    print_status "Detected Raspberry Pi hardware"
    IS_RASPBERRY_PI=true
else
    print_warning "Not running on Raspberry Pi - hardware control will be simulated"
    IS_RASPBERRY_PI=false
fi

# Check for required tools
print_status "Checking required tools..."
command -v node >/dev/null 2>&1 || { print_error "Node.js is required but not installed. Please install Node.js 18+ first."; exit 1; }
command -v npm >/dev/null 2>&1 || { print_error "npm is required but not installed."; exit 1; }
command -v psql >/dev/null 2>&1 || { print_warning "psql not found. Database testing will be limited."; }

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2)
REQUIRED_VERSION="18.0.0"
if ! npm --version >/dev/null 2>&1; then
    print_error "Node.js version $NODE_VERSION is too old. Minimum required: $REQUIRED_VERSION"
    exit 1
fi

print_status "Node.js version: $NODE_VERSION ✓"

# Set up environment variables
print_status "Setting up environment variables..."

# Create .env.production file
cat > .env.production << EOF
NODE_ENV=production
DATABASE_URL=postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
PORT=3000
SESSION_SECRET=\$(openssl rand -base64 32)
EOF

if [[ "$IS_RASPBERRY_PI" == true ]]; then
    echo "HARDWARE_MODE=production" >> .env.production
    print_status "Hardware mode set to production (GPIO control enabled)"
else
    echo "HARDWARE_MODE=development" >> .env.production
    print_status "Hardware mode set to development (GPIO simulation)"
fi

# Load environment variables
set -a
source .env.production
set +a

print_status "Environment file created: .env.production"

# Test database connection
print_status "Testing database connection..."
if command -v psql >/dev/null 2>&1; then
    if psql "$DATABASE_URL" -c "SELECT NOW();" >/dev/null 2>&1; then
        print_status "Database connection successful ✓"
    else
        print_error "Database connection failed!"
        print_error "Please check your DATABASE_URL in .env.production"
        exit 1
    fi
else
    print_warning "psql not available - skipping database connection test"
fi

# Install dependencies
print_status "Installing dependencies..."
npm ci --only=production

# Install Raspberry Pi specific dependencies
if [[ "$IS_RASPBERRY_PI" == true ]]; then
    print_status "Installing Raspberry Pi GPIO dependencies..."
    npm install rpi-gpio@^2.1.7 --save-optional
fi

# Run database migrations
print_status "Running database migrations..."
if [[ -f "deployment/database-migration.sql" ]]; then
    if command -v psql >/dev/null 2>&1; then
        psql "$DATABASE_URL" -f deployment/database-migration.sql
        print_status "Database migration completed ✓"
    else
        print_warning "psql not available - please run database migration manually"
        print_warning "Command: psql \"\$DATABASE_URL\" -f deployment/database-migration.sql"
    fi
else
    print_warning "Database migration file not found"
fi

# Build the application
print_status "Building application..."
npm run build

# Create logs directory
mkdir -p logs
chmod 755 logs

print_status "Setting up PM2 configuration..."
if ! command -v pm2 >/dev/null 2>&1; then
    print_status "Installing PM2 globally..."
    npm install -g pm2
fi

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'beverage-kiosk',
    script: 'dist/server/index.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'development',
      PORT: 3000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3000,
      HARDWARE_MODE: process.env.HARDWARE_MODE || 'development'
    },
    log_file: 'logs/combined.log',
    out_file: 'logs/out.log',
    error_file: 'logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_restarts: 10,
    min_uptime: '10s',
    max_memory_restart: '1G',
    watch: false,
    ignore_watch: ['node_modules', 'logs'],
    restart_delay: 4000
  }]
};
EOF

print_status "PM2 configuration created ✓"

# Set up systemd service for auto-start (Raspberry Pi)
if [[ "$IS_RASPBERRY_PI" == true ]]; then
    print_status "Setting up systemd service for auto-start..."
    
    sudo tee /etc/systemd/system/beverage-kiosk.service > /dev/null << EOF
[Unit]
Description=Smart Beverage Kiosk
After=network.target

[Service]
Type=forking
User=pi
WorkingDirectory=$(pwd)
Environment=NODE_ENV=production
ExecStart=/usr/bin/pm2 start ecosystem.config.js --env production
ExecReload=/usr/bin/pm2 reload ecosystem.config.js --env production
ExecStop=/usr/bin/pm2 delete beverage-kiosk
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable beverage-kiosk.service
    print_status "Systemd service configured ✓"
fi

# Create test script
cat > test-system.sh << 'EOF'
#!/bin/bash
echo "Testing system components..."

# Test database connection
echo "Testing database..."
if psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM beverages;" 2>/dev/null; then
    echo "✓ Database connection working"
else
    echo "✗ Database connection failed"
fi

# Test API endpoint
echo "Testing API..."
if curl -s -f "http://localhost:3000/api/beverages" >/dev/null; then
    echo "✓ API endpoint working"
else
    echo "✗ API endpoint not responding"
fi

# Test GPIO (if on Raspberry Pi)
if [[ -f /proc/device-tree/model ]] && grep -q "Raspberry Pi" /proc/device-tree/model; then
    echo "Testing GPIO..."
    if command -v gpio >/dev/null 2>&1; then
        gpio -v >/dev/null 2>&1 && echo "✓ GPIO tools available" || echo "✗ GPIO tools not working"
    else
        echo "! GPIO tools not installed (install with: sudo apt install wiringpi)"
    fi
fi

echo "System test complete"
EOF

chmod +x test-system.sh

print_status "Test script created: ./test-system.sh"

# Final summary
echo ""
echo "=== Setup Complete ==="
print_status "Environment configuration: .env.production"
print_status "PM2 configuration: ecosystem.config.js"
print_status "Test script: ./test-system.sh"
echo ""
echo "Next steps:"
echo "1. Start the application: pm2 start ecosystem.config.js --env production"
echo "2. Save PM2 configuration: pm2 save"
echo "3. Test the system: ./test-system.sh"
echo "4. Monitor logs: pm2 logs beverage-kiosk"
echo ""
if [[ "$IS_RASPBERRY_PI" == true ]]; then
    echo "Raspberry Pi specific:"
    echo "- Hardware GPIO control is enabled"
    echo "- Auto-start service is configured"
    echo "- Reboot to test auto-start: sudo reboot"
fi
echo ""
print_status "Setup completed successfully!"
EOF

chmod +x deployment/setup-environment.sh