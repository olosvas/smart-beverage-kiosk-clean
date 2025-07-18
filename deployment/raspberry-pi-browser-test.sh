#!/bin/bash

echo "🔍 Testovanie browser vs curl rozdielu..."

# Test 1: Curl (funguje)
echo "=== TEST 1: CURL (mal by fungovať) ==="
curl -s -H "Accept: application/json" -H "Origin: http://localhost:3000" \
  "https://smart-beverage-dispenser-uzisinapoj.replit.app/api/beverages" | head -c 200

echo ""
echo ""

# Test 2: Kontrola CORS hlavičiek
echo "=== TEST 2: CORS HEADERS ==="
curl -I -H "Origin: http://localhost:3000" \
  "https://smart-beverage-dispenser-uzisinapoj.replit.app/api/beverages"

echo ""

# Test 3: OPTIONS preflight request
echo "=== TEST 3: OPTIONS PREFLIGHT ==="
curl -X OPTIONS -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: accept" \
  "https://smart-beverage-dispenser-uzisinapoj.replit.app/api/beverages"

echo ""
echo ""

# Test 4: Lokálny kiosk odpoveď (mal by byť HTML)
echo "=== TEST 4: LOKÁLNY KIOSK ==="
curl -s "http://localhost:3000/" | head -c 100

echo ""
echo ""

# Test 5: Browser developer tools simulation
echo "=== TEST 5: BROWSER SIMULATION ==="
curl -s -H "Accept: application/json" \
  -H "Origin: http://localhost:3000" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36" \
  -H "Referer: http://localhost:3000/" \
  "https://smart-beverage-dispenser-uzisinapoj.replit.app/api/beverages" | head -c 200

echo ""
echo ""
echo "✅ Test dokončený. Skontroluj či sú CORS hlavičky správne."