#!/bin/bash

# Raspberry Pi Environment Setup Script
# Vytvorí .env.production súbor s databázovým pripojením

echo "🔧 Nastavujem environment variables na Raspberry Pi..."

# Vytvor .env.production súbor
cat > .env.production << 'EOF'
NODE_ENV=production
DATABASE_URL=postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
PORT=3000
HARDWARE_MODE=production
SESSION_SECRET=your-secret-key-here
EOF

echo "✅ .env.production súbor vytvorený"

# Otestuj databázové pripojenie
echo "🔍 Testujem databázové pripojenie..."
node -e "
const { Pool, neonConfig } = require('@neondatabase/serverless');
const ws = require('ws');
neonConfig.webSocketConstructor = ws;

const pool = new Pool({
  connectionString: 'postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'
});

async function testConnection() {
  try {
    const result = await pool.query('SELECT COUNT(*) FROM beverages');
    console.log('✅ Databáza OK - nápojov:', result.rows[0].count);
    await pool.end();
  } catch (error) {
    console.error('❌ Databáza ERROR:', error.message);
  }
}

testConnection();
"

echo "🎉 Environment setup dokončený!"
echo ""
echo "Ďalšie kroky:"
echo "1. Spusti aplikáciu: pm2 start ecosystem.config.js --env production"
echo "2. Skontroluj stav: pm2 status"
echo "3. Pozri logy: pm2 logs beverage-kiosk"
echo "4. Otestuj API: curl http://localhost:3000/api/beverages"