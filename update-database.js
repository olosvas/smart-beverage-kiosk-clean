#!/usr/bin/env node

// Simple script to update database connection and test it
import { Pool } from '@neondatabase/serverless';
import fs from 'fs';

// Your Raspberry Pi database URL
const NEW_DATABASE_URL = "postgresql://neondb_owner:npg_x4izKw3sGULf@ep-green-queen-a2ysqaa6-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require";

async function updateDatabase() {
    console.log('🔄 Updating database connection...');
    
    // Test the new connection
    try {
        const pool = new Pool({ connectionString: NEW_DATABASE_URL });
        const result = await pool.query('SELECT NOW()');
        console.log('✅ Database connection successful!');
        console.log('📅 Current time:', result.rows[0].now);
        
        // Check if tables exist
        const tables = await pool.query(`
            SELECT table_name FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        `);
        
        console.log('📊 Available tables:', tables.rows.map(r => r.table_name).join(', '));
        
        // Check beverages count
        const beverages = await pool.query('SELECT COUNT(*) FROM beverages');
        console.log('🍺 Beverages in database:', beverages.rows[0].count);
        
        await pool.end();
        
        // Update environment variable
        process.env.DATABASE_URL = NEW_DATABASE_URL;
        console.log('✅ Database URL updated successfully!');
        
        return true;
    } catch (error) {
        console.error('❌ Database connection failed:', error.message);
        return false;
    }
}

// Run the update
updateDatabase().then(success => {
    if (success) {
        console.log('\n🎉 Database update completed successfully!');
        console.log('🔄 Restart your application to use the new database connection.');
    } else {
        console.log('\n❌ Database update failed. Please check the connection string.');
    }
    process.exit(success ? 0 : 1);
});