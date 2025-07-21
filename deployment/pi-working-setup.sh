#!/bin/bash

echo "🔧 Obnovujem fungovujúcu konfiguráciu Pi..."

# 1. Zastaviť aplikáciu
pm2 stop beverage-kiosk 2>/dev/null || true
pm2 delete beverage-kiosk 2>/dev/null || true

# 2. Vytvoriť správny .env súbor (development mode)
cat > .env << 'EOF'
NODE_ENV=development
DATABASE_URL=postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
PORT=3000
HARDWARE_MODE=production
EOF

# 3. Načítať environment variables
export NODE_ENV=development
export DATABASE_URL="postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
export PORT=3000
export HARDWARE_MODE=production

# 4. Build aplikácie
echo "🔨 Building aplikáciu..."
npm run build

# 5. Vytvoriť logs priečinok
mkdir -p logs

# 6. Spustiť s development environment (čo je kľúčové!)
echo "🚀 Spúšťam aplikáciu..."
pm2 start deployment/ecosystem.config.cjs --env development

# 7. Čakať na spustenie
sleep 5

# 8. Kontrola
pm2 status

echo "✅ Aplikácia by mala bežať na http://localhost:3000"
echo "🔍 Skontroluj logy: pm2 logs beverage-kiosk"