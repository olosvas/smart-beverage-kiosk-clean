#!/usr/bin/env node
import { Pool, neonConfig } from '@neondatabase/serverless';
import ws from 'ws';

neonConfig.webSocketConstructor = ws;

const RASPBERRY_PI_DB_URL = "postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require";
const OLD_DB_URL = "postgresql://neondb_owner:npg_NUmHrFp2gq9M@ep-proud-butterfly-aeoejts5.c-2.us-east-2.aws.neon.tech/neondb?sslmode=require";

console.log('🔧 Initializing your Raspberry Pi database...');

async function initializeDatabase() {
    try {
        const raspberryPool = new Pool({ connectionString: RASPBERRY_PI_DB_URL });
        const oldPool = new Pool({ connectionString: OLD_DB_URL });
        
        // Create tables
        console.log('📋 Creating tables...');
        await raspberryPool.query(`
            CREATE TABLE IF NOT EXISTS beverages (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                name_en TEXT NOT NULL,
                name_sk TEXT NOT NULL,
                description TEXT,
                description_en TEXT,
                description_sk TEXT,
                price_per_liter DECIMAL(10,2) NOT NULL,
                volume_options JSONB NOT NULL DEFAULT '[0.3, 0.5]',
                image_url TEXT,
                flow_sensor_pin INTEGER NOT NULL,
                valve_pin INTEGER NOT NULL,
                total_capacity DECIMAL(10,2) NOT NULL,
                current_stock DECIMAL(10,2) NOT NULL,
                requires_age_verification BOOLEAN DEFAULT FALSE,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );
        `);
        
        await raspberryPool.query(`
            CREATE TABLE IF NOT EXISTS orders (
                id SERIAL PRIMARY KEY,
                order_number TEXT NOT NULL UNIQUE,
                items JSONB NOT NULL,
                total_amount DECIMAL(10,2) NOT NULL,
                language TEXT NOT NULL,
                age_verification_method TEXT,
                payment_method TEXT,
                status TEXT NOT NULL DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT NOW(),
                completed_at TIMESTAMP
            );
        `);
        
        await raspberryPool.query(`
            CREATE TABLE IF NOT EXISTS system_logs (
                id SERIAL PRIMARY KEY,
                level TEXT NOT NULL,
                message TEXT NOT NULL,
                context JSONB,
                timestamp TIMESTAMP DEFAULT NOW()
            );
        `);
        
        await raspberryPool.query(`
            CREATE TABLE IF NOT EXISTS inventory_logs (
                id SERIAL PRIMARY KEY,
                beverage_id TEXT NOT NULL,
                change_type TEXT NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                previous_stock DECIMAL(10,2) NOT NULL,
                new_stock DECIMAL(10,2) NOT NULL,
                order_id INTEGER,
                notes TEXT,
                timestamp TIMESTAMP DEFAULT NOW()
            );
        `);
        
        console.log('✅ Tables created successfully');
        
        // Copy beverages from old database
        console.log('📦 Copying beverages from old database...');
        const oldBeverages = await oldPool.query('SELECT * FROM beverages');
        
        for (const beverage of oldBeverages.rows) {
            await raspberryPool.query(`
                INSERT INTO beverages (
                    id, name, name_en, name_sk, description, description_en, description_sk,
                    price_per_liter, volume_options, image_url, flow_sensor_pin, valve_pin,
                    total_capacity, current_stock, requires_age_verification, is_active,
                    created_at, updated_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
                ON CONFLICT (id) DO UPDATE SET
                    name = EXCLUDED.name,
                    name_en = EXCLUDED.name_en,
                    name_sk = EXCLUDED.name_sk,
                    updated_at = NOW()
            `, [
                beverage.id, beverage.name, beverage.name_en, beverage.name_sk,
                beverage.description, beverage.description_en, beverage.description_sk,
                beverage.price_per_liter, beverage.volume_options, beverage.image_url,
                beverage.flow_sensor_pin, beverage.valve_pin, beverage.total_capacity,
                beverage.current_stock, beverage.requires_age_verification, beverage.is_active,
                beverage.created_at, beverage.updated_at
            ]);
        }
        
        // Verify the data
        const newBeverageCount = await raspberryPool.query('SELECT COUNT(*) FROM beverages');
        console.log(`✅ Successfully copied ${newBeverageCount.rows[0].count} beverages`);
        
        // List copied beverages
        const beverages = await raspberryPool.query('SELECT id, name, name_en, price_per_liter FROM beverages ORDER BY created_at');
        console.log('\n🍺 Beverages in your Raspberry Pi database:');
        beverages.rows.forEach(bev => {
            console.log(`- ${bev.id}: ${bev.name} (${bev.name_en}) - €${bev.price_per_liter}`);
        });
        
        await raspberryPool.end();
        await oldPool.end();
        
        console.log('\n🎉 Database initialization complete!');
        
    } catch (error) {
        console.error('❌ Error initializing database:', error.message);
        console.error('Stack:', error.stack);
    }
}

initializeDatabase();