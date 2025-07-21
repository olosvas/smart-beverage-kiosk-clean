# Troubleshooting 500 Error on Beverage Creation

## Common Causes and Solutions

### 1. Database Connection Issues

**Problem**: Database URL not properly configured or connection failing
**Solution**:
```bash
# Check environment variables
echo $DATABASE_URL
echo $NODE_ENV

# Test database connection
npm run db:push

# Run migration manually
psql "$DATABASE_URL" -f deployment/database-migration.sql
```

### 2. Missing Database Tables

**Problem**: Tables not created or schema mismatch
**Solution**:
```bash
# Check if tables exist
psql "$DATABASE_URL" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"

# Create missing tables
psql "$DATABASE_URL" -f deployment/database-migration.sql
```

### 3. Environment Configuration

**Problem**: NODE_ENV or other environment variables not set
**Solution**: Create `.env.production` file:
```env
NODE_ENV=production
DATABASE_URL=postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
HARDWARE_MODE=production
PORT=3000
```

### 4. Schema Validation Errors

**Problem**: Invalid data types or missing required fields
**Solution**: 
```javascript
// Check the exact request payload
const validBeverage = {
  id: "unique-id",
  name: "Name",
  nameEn: "English Name",
  nameSk: "Slovak Name",
  pricePerLiter: "4.50",        // String, not number
  volumeOptions: [0.3, 0.5],    // Array of numbers
  flowSensorPin: 17,            // Integer
  valvePin: 26,                 // Integer
  totalCapacity: "50.00",       // String, not number
  currentStock: "45.00",        // String, not number
  isActive: true,               // Boolean
  requiresAgeVerification: false // Boolean (optional)
};
```

### 5. Permission Issues

**Problem**: Database user doesn't have INSERT permissions
**Solution**:
```sql
-- Grant permissions (run as database owner)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO neondb_owner;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO neondb_owner;
```

### 6. JSONB Column Issues

**Problem**: volumeOptions field causing JSON parsing errors
**Solution**:
```javascript
// Ensure volumeOptions is properly formatted
"volumeOptions": [0.3, 0.5]  // Array of numbers, not strings
```

## Debugging Steps

### 1. Check Server Logs
```bash
# If using PM2
pm2 logs beverage-kiosk

# If using systemd
journalctl -u beverage-kiosk -f

# If running manually
node dist/server/index.js
```

### 2. Test Database Connection
```bash
# Test connection with psql
psql "$DATABASE_URL" -c "SELECT NOW();"

# Test with Node.js
node -e "
const { Pool } = require('@neondatabase/serverless');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
pool.query('SELECT NOW()').then(res => console.log('Connected:', res.rows[0])).catch(err => console.error('Error:', err));
"
```

### 3. Test API Endpoint
```bash
# Test with curl
curl -X POST "http://localhost:3000/api/admin/beverages" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "test-debug",
    "name": "Test",
    "nameEn": "Test",
    "nameSk": "Test",
    "pricePerLiter": "3.50",
    "volumeOptions": [0.3, 0.5],
    "flowSensorPin": 19,
    "valvePin": 25,
    "totalCapacity": "50.00",
    "currentStock": "45.00",
    "isActive": true
  }'
```

### 4. Check Database Schema
```sql
-- Check table structure
\d beverages

-- Check constraints
SELECT constraint_name, constraint_type FROM information_schema.table_constraints WHERE table_name = 'beverages';

-- Check data types
SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'beverages';
```

## Error Logging Enhancement

Add this to your server code for better error tracking:

```javascript
// In server/routes.ts
app.post('/api/admin/beverages', async (req, res) => {
  try {
    console.log('Received beverage creation request:', JSON.stringify(req.body, null, 2));
    
    const beverage = await storage.createBeverage(req.body);
    
    console.log('Successfully created beverage:', beverage.id);
    res.json(beverage);
  } catch (error) {
    console.error('Error creating beverage:', error);
    console.error('Stack trace:', error.stack);
    console.error('Request body:', JSON.stringify(req.body, null, 2));
    res.status(500).json({ 
      error: 'Failed to create beverage',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
});
```

## Quick Fix Commands

### Reset Database Tables
```bash
# Drop and recreate tables (WARNING: This will delete all data)
psql "$DATABASE_URL" -c "DROP TABLE IF EXISTS beverages CASCADE;"
psql "$DATABASE_URL" -c "DROP TABLE IF EXISTS orders CASCADE;"
psql "$DATABASE_URL" -c "DROP TABLE IF EXISTS system_logs CASCADE;"
psql "$DATABASE_URL" -c "DROP TABLE IF EXISTS inventory_logs CASCADE;"
psql "$DATABASE_URL" -f deployment/database-migration.sql
```

### Restart Services
```bash
# PM2
pm2 restart beverage-kiosk
pm2 logs beverage-kiosk --lines 50

# Systemd
sudo systemctl restart beverage-kiosk
sudo journalctl -u beverage-kiosk -f
```

### Clear Node.js Cache
```bash
# Clear npm cache
npm cache clean --force

# Rebuild node_modules
rm -rf node_modules package-lock.json
npm install
```

## Environment-Specific Issues

### Raspberry Pi Specific
```bash
# Install Python build tools if needed
sudo apt-get install python3-dev build-essential

# Set correct NODE_ENV
export NODE_ENV=production
export HARDWARE_MODE=production
```

### Neon Database Specific
```bash
# Test SSL connection
psql "$DATABASE_URL" -c "SELECT version();"

# Check connection pooling
psql "$DATABASE_URL" -c "SHOW max_connections;"
```

## Prevention

1. **Always test locally first** with the same database URL
2. **Use environment variable validation** on startup
3. **Implement proper error handling** with detailed logging
4. **Add health check endpoints** for monitoring
5. **Use database migrations** instead of manual schema changes

## Contact Information

If the issue persists after trying these solutions:
1. Check the server logs for specific error messages
2. Test the exact same request locally
3. Verify the database schema matches the application expectations
4. Ensure all environment variables are properly set