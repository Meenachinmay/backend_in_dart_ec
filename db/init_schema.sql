-- Enable UUID extension (still used for inventory/subscription IDs)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(128) PRIMARY KEY, -- Changed from UUID to VARCHAR to support Firebase UIDs
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Inventory Table
CREATE TABLE IF NOT EXISTS inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discounted_price DECIMAL(10, 2),
    expiry_in INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Subscriptions Table
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE, -- Matches users.id type
    inventory_id UUID REFERENCES inventory(id) ON DELETE CASCADE,
    alert_threshold INTEGER NOT NULL CHECK (alert_threshold IN (1, 2, 3)),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, inventory_id, alert_threshold)
);

-- Seed Data (Updated to use string IDs if needed, or let them be whatever)
-- Note: We can't easily seed a random string ID without knowing it for testing, 
-- but for now we'll insert a placeholder or skip seeding users if we rely on API creation.
INSERT INTO users (id, email) VALUES ('test-user-id', 'test@example.com') ON CONFLICT DO NOTHING;

INSERT INTO inventory (name, price, expiry_in) VALUES
('Milk', 2.50, 1),
('Bread', 1.50, 2),
('Eggs', 3.00, 3),
('Cheese', 5.00, 10);