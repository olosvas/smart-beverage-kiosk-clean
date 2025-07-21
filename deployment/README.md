# Smart Beverage Kiosk - Deployment Guide

## Quick Start for Raspberry Pi

1. **Clone and build:**
   ```bash
   git clone <your-repo-url>
   cd kiosk-project
   npm install
   npm run build
   ```

2. **Start the kiosk:**
   ```bash
   pm2 start deployment/ecosystem.config.cjs --env production
   ```

3. **Access the kiosk:**
   - Open browser: `http://localhost:3000`
   - Set browser to fullscreen/kiosk mode

## Configuration

The ecosystem.config.cjs contains the working configuration:
- `NODE_ENV=development` (required for API routes to work)
- `HARDWARE_MODE=production` (enables GPIO on Pi)
- Database connection to Neon PostgreSQL

## Admin Panel

The admin panel is available at the production URL:
https://smart-beverage-dispenser-uzisinapoj.replit.app/admin