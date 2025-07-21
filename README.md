# Smart Beverage Dispensing Kiosk System

A modern touchscreen beverage dispensing system designed for Raspberry Pi 4B with 7" display and comprehensive admin management.

## Features

- **Touch-optimized Interface**: Designed for 7" touchscreen displays
- **Hardware Integration**: GPIO control for valves and flow sensors
- **Admin Dashboard**: Real-time order management and monitoring
- **Multilingual**: English and Slovak language support
- **Database Integration**: PostgreSQL with Drizzle ORM
- **WebSocket Communication**: Live updates between kiosk and admin

## Quick Start

### For Raspberry Pi Deployment

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Build the application:**
   ```bash
   npm run build
   ```

3. **Start the kiosk:**
   ```bash
   pm2 start deployment/ecosystem.config.cjs --env production
   ```

4. **Access the kiosk:**
   - Open browser to `http://localhost:3000`
   - Set browser to fullscreen/kiosk mode

### For Development

```bash
npm run dev
```

## Architecture

- **Frontend**: React + TypeScript + Vite
- **Backend**: Node.js + Express + TypeScript
- **Database**: PostgreSQL (Neon)
- **Hardware**: Raspberry Pi 4B with GPIO control
- **UI Components**: shadcn/ui + Radix UI + Tailwind CSS

## Admin Access

The admin panel is available at:
https://smart-beverage-dispenser-uzisinapoj.replit.app/admin

## Hardware Requirements

- Raspberry Pi 4B
- 7" touchscreen display
- YF-S301 flow sensors
- 12V solenoid valves
- GPIO connections for hardware control

See `deployment/README.md` for detailed deployment instructions.