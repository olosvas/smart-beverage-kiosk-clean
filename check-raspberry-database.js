#!/usr/bin/env node
import { Pool, neonConfig } from '@neondatabase/serverless';
import ws from 'ws';

neonConfig.webSocketConstructor = ws;

const RASPBERRY_PI_DB_URL = "postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require";

console.log('🔍 Checking YOUR Raspberry Pi database...');
console.log('Database URL:', RASPBERRY_PI_DB_URL);

async function checkDatabase() {
    try {
        const pool = new Pool({ connectionString: RASPBERRY_PI_DB_URL });
        
        // Test connection
        const now = await pool.query('SELECT NOW()');
        console.log('✅ Connection successful at:', now.rows[0].now);
        
        // Check beverages count
        const beverageCount = await pool.query('SELECT COUNT(*) FROM beverages');
        console.log('🍺 Total beverages:', beverageCount.rows[0].count);
        
        // List all beverages
        const beverages = await pool.query('SELECT id, name, name_en, price_per_liter, flow_sensor_pin, valve_pin, current_stock, is_active FROM beverages ORDER BY created_at');
        console.log('\n📋 Beverages in YOUR database:');
        beverages.rows.forEach(bev => {
            console.log(`- ${bev.id}: ${bev.name} (${bev.name_en}) - €${bev.price_per_liter} - Pin ${bev.flow_sensor_pin}/${bev.valve_pin} - ${bev.current_stock}L - ${bev.is_active ? 'Active' : 'Inactive'}`);
        });
        
        // Check orders
        const orderCount = await pool.query('SELECT COUNT(*) FROM orders');
        console.log('\n📦 Total orders:', orderCount.rows[0].count);
        
        await pool.end();
        
    } catch (error) {
        console.error('❌ Error checking database:', error.message);
    }
}

checkDatabase();