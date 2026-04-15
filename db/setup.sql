CREATE DATABASE blood_donation_db;
\c blood_donation_db;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100),
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'donor',
    blood_group VARCHAR(5),
    district VARCHAR(50),
    upazila VARCHAR(50),
    is_available BOOLEAN DEFAULT TRUE,
    last_donation DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE blood_inventory (
    id SERIAL PRIMARY KEY,
    hospital_id INT REFERENCES users(id),
    blood_group VARCHAR(5) NOT NULL,
    quantity INT DEFAULT 0,
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'sufficient',
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE emergency_requests (
    id SERIAL PRIMARY KEY,
    blood_group VARCHAR(5) NOT NULL,
    hospital_name VARCHAR(100),
    district VARCHAR(50),
    contact VARCHAR(15),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE donations (
    id SERIAL PRIMARY KEY,
    donor_id INT REFERENCES users(id),
    donation_date DATE DEFAULT CURRENT_DATE,
    location VARCHAR(100)
);
