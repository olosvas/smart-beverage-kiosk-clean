# Raspberry Pi Deployment Instructions

## 🚀 Ako dostať zmeny na Raspberry Pi

### Možnosť 1: Kompletný setup script (ODPORÚČANÉ)

1. **Skopíruj tento súbor na Pi:**
   ```bash
   scp deployment/raspberry-pi-complete-setup.sh pi@tvoj-pi-ip:/home/pi/kiosk-app/
   ```

2. **Na Raspberry Pi spusti:**
   ```bash
   cd /home/pi/kiosk-app
   bash raspberry-pi-complete-setup.sh
   ```

3. **Hotovo!** Aplikácia beží na `http://localhost:3000`

### Možnosť 2: Manuálny prenos súborov

1. **Skopíruj tieto súbory na Pi:**
   - `deployment/ecosystem.config.js`
   - `deployment/raspberry-pi-env-setup.sh`

2. **Na Pi vytvor .env.production:**
   ```bash
   cat > .env.production << 'EOF'
   NODE_ENV=production
   DATABASE_URL=postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   PORT=3000
   HARDWARE_MODE=production
   SESSION_SECRET=raspberry-pi-kiosk-secret-2025
   EOF
   ```

3. **Spusti aplikáciu:**
   ```bash
   pm2 start ecosystem.config.js --env production
   pm2 save
   ```

### Možnosť 3: USB stick

1. **Skopíruj na USB:**
   - `deployment/raspberry-pi-complete-setup.sh`
   - `deployment/ecosystem.config.js`

2. **Na Pi:**
   ```bash
   cp /media/pi/USB/raspberry-pi-complete-setup.sh /home/pi/kiosk-app/
   bash raspberry-pi-complete-setup.sh
   ```

## 📋 Databázové pripojenie

**Databáza URL:**
```
postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

**Nápoje v databáze:**
- pivo1: šariš 12 - €5.00
- kofola2: kofola - €4.00  
- biel: birel - €6.00
- neviem: neviem - €7.00
- final-test: Final Test - €3.00

## 🔧 Užitočné príkazy na Pi

```bash
# Status aplikácie
pm2 status

# Logy
pm2 logs beverage-kiosk

# Reštart
pm2 restart beverage-kiosk

# Test API
curl http://localhost:3000/api/beverages

# Test databázy
node -e "
const { Pool } = require('@neondatabase/serverless');
const pool = new Pool({connectionString: process.env.DATABASE_URL});
pool.query('SELECT COUNT(*) FROM beverages').then(r => console.log('Beverages:', r.rows[0].count));
"
```

## 🌐 Kiosk aplikácia

Po spustení je dostupná na: `http://localhost:3000`

- **Kiosk rozhranie**: Dotykové ovládanie pre zákazníkov
- **Admin panel**: `/admin` pre správu nápojov
- **API**: `/api/beverages` pre dáta nápojov