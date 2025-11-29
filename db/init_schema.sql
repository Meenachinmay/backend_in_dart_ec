-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Inventory Table
CREATE TABLE IF NOT EXISTS inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discounted_price DECIMAL(10, 2), -- Can be null, calculated on fetch
    expiry_in INTEGER NOT NULL, -- Days remaining
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Subscriptions Table
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    inventory_id UUID REFERENCES inventory(id) ON DELETE CASCADE,
    alert_threshold INTEGER NOT NULL CHECK (alert_threshold IN (1, 2, 3)),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, inventory_id, alert_threshold) -- Prevent duplicate subscriptions for same alert
);

-- Seed Data
INSERT INTO users (email) VALUES ('test@example.com');

INSERT INTO inventory (name, price, expiry_in) VALUES
('Milk', 2.50, 1),
('Bread', 1.50, 2),
('Eggs', 3.00, 3),
('Cheese', 5.00, 10);
