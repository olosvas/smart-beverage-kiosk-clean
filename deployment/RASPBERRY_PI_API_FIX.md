# Raspberry Pi API Fix - DOCTYPE HTML Problem

## Problém
Raspberry Pi dostáva HTML namiesto JSON pri volaní `/api/beverages` endpointu.

## Príčina
V production móde aplikácia používa `serveStatic` funkciu, ktorá má catch-all route `*` 
ktorý prepisuje API endpointy a posiela HTML namiesto JSON.

## Riešenie
Spustiť aplikáciu v development móde na Raspberry Pi:

### 1. Upraviť .env.production
```bash
NODE_ENV=development
DATABASE_URL=postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
PORT=3000
HARDWARE_MODE=production
SESSION_SECRET=raspberry-pi-kiosk-secret-2025
```

### 2. Spustiť PM2 v development móde
```bash
pm2 start ecosystem.config.js --env development
```

### 3. Alebo použiť opravný script
```bash
bash deployment/raspberry-pi-fix-database.sh
```

## Vysvetlenie
- **NODE_ENV=development**: Zabezpečuje, že API endpointy fungujú
- **HARDWARE_MODE=production**: Zabezpečuje použitie reálnych GPIO pinov
- **PORT=3000**: Kiosk port na Raspberry Pi

## Test
Po oprave by mal endpoint vrátiť JSON:
```bash
curl http://localhost:3000/api/beverages
```

Očakávaný výstup:
```json
[{"id":"pivo1","name":"Pivo","nameEn":"šariš 12"...}]
```

Nie HTML:
```html
<!DOCTYPE html>...
```