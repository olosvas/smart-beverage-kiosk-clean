# Git Push Instructions

## Aktuálne zmeny na push

### Hlavné úpravy:
- ✅ Opravené databázové pripojenie na Raspberry Pi
- ✅ Aktualizovaný ecosystem.config.js s produkčnou databázou
- ✅ Vytvorené deployment skripty
- ✅ Databáza inicializovaná s 5 nápojmi
- ✅ Všetky API endpointy testované a funkčné

### Nové/upravené súbory:
```
deployment/ecosystem.config.js          # PM2 konfigurácia
deployment/raspberry-pi-env-setup.sh    # Environment setup
deployment/setup-environment.sh         # Kompletný setup
check-raspberry-database.js            # Databázový test
initialize-raspberry-database.js       # Databázová inicializácia
deployment/git-push-instructions.md    # Tento súbor
```

## Ako pushnúť zmeny:

### Možnosť 1: Manuálne na svojom počítači
```bash
# Klonuj repozitár (ak nemáš)
git clone https://github.com/olosvas/BeerDispenser.git
cd BeerDispenser

# Skopíruj nové súbory z Replit prostredia
# Potom:
git add .
git commit -m "Fix database connection and add Raspberry Pi deployment scripts

- Fixed production database connection issues
- Added ecosystem.config.js with proper PostgreSQL connection
- Created raspberry-pi-env-setup.sh for environment configuration
- Added database initialization and testing scripts
- Updated deployment documentation
- All API endpoints now working with production database"

git push origin main
```

### Možnosť 2: GitHub web interface
1. Choď na https://github.com/olosvas/BeerDispenser
2. Nahraj súbory cez "Upload files"
3. Vytvor commit s opisom zmien

### Možnosť 3: GitHub CLI (ak máš)
```bash
gh repo clone olosvas/BeerDispenser
cd BeerDispenser
# Skopíruj súbory a potom:
git add .
git commit -m "Fix database connection and add deployment scripts"
git push
```

## Po synchronizácii na Raspberry Pi:

```bash
cd /home/pi/kiosk-app
git pull origin main
bash deployment/raspberry-pi-env-setup.sh
pm2 restart beverage-kiosk
```

## Databázové pripojenie:
```
postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

## Stav databázy:
- ✅ 5 nápojov (pivo1, kofola2, biel, neviem, final-test)
- ✅ Všetky tabuľky vytvorené
- ✅ GPIO piny nakonfigurované
- ✅ API endpointy testované a funkčné