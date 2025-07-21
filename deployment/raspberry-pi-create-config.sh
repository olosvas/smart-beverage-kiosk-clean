#!/bin/bash

echo "🔧 Vytváram PM2 konfiguráciu na Raspberry Pi..."

# 1. Zastaviť existujúce procesy
pm2 stop beverage-kiosk 2>/dev/null || true
pm2 delete beverage-kiosk 2>/dev/null || true

# 2. Vytvoriť ecosystem.config.cjs
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'beverage-kiosk',
    script: './dist/server/index.js',
    env: {
      NODE_ENV: 'development',
      PORT: 3000,
      DATABASE_URL: 'postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'
    },
    env_production: {
      NODE_ENV: 'development',
      PORT: 3000,
      HARDWARE_MODE: 'production',
      DATABASE_URL: 'postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true,
    exec_mode: 'fork',
    min_uptime: '10s',
    max_restarts: 10,
    restart_delay: 4000
  }]
};
EOF

# 3. Vytvoriť .env súbor
cat > .env << 'EOF'
NODE_ENV=development
DATABASE_URL=postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
PORT=3000
HARDWARE_MODE=production
EOF

# 4. Vytvoriť logs priečinok
mkdir -p logs

# 5. Spustiť aplikáciu
echo "🚀 Spúšťam aplikáciu..."
pm2 start ecosystem.config.cjs --env development

# 6. Čakať na spustenie
sleep 5

# 7. Test API
echo "🧪 Testujem API..."
curl -s "http://localhost:3000/api/beverages" | head -c 200

echo ""
echo "✅ Hotovo! Kiosk by mal teraz načítavať správne dáta."
echo "📱 Otvor: http://localhost:3000"
echo "📋 PM2 status: pm2 status"
echo "📋 PM2 logs: pm2 logs beverage-kiosk"