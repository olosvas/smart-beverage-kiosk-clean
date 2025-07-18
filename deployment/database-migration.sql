-- Database Migration Script for PostgreSQL (Neon)
-- Run this to ensure all required tables exist

-- Create beverages table
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

-- Create orders table
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

-- Create system_logs table
CREATE TABLE IF NOT EXISTS system_logs (
    id SERIAL PRIMARY KEY,
    level TEXT NOT NULL,
    message TEXT NOT NULL,
    context JSONB,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Create inventory_logs table
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_beverages_active ON beverages(is_active);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_system_logs_timestamp ON system_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_beverage_id ON inventory_logs(beverage_id);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_timestamp ON inventory_logs(timestamp);

-- Insert sample beverages if none exist
INSERT INTO beverages (id, name, name_en, name_sk, price_per_liter, flow_sensor_pin, valve_pin, total_capacity, current_stock, requires_age_verification, is_active)
SELECT 'sample-beer', 'Sample Beer', 'Sample Beer', 'Ukážkové pivo', 4.50, 17, 26, 50.00, 45.00, true, true
WHERE NOT EXISTS (SELECT 1 FROM beverages WHERE id = 'sample-beer');

INSERT INTO beverages (id, name, name_en, name_sk, price_per_liter, flow_sensor_pin, valve_pin, total_capacity, current_stock, requires_age_verification, is_active)
SELECT 'sample-juice', 'Sample Juice', 'Sample Juice', 'Ukážková šťava', 2.50, 18, 27, 50.00, 40.00, false, true
WHERE NOT EXISTS (SELECT 1 FROM beverages WHERE id = 'sample-juice');

-- Verify tables exist
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;