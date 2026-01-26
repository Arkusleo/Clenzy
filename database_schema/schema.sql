-- Clenzy Production Database Schema (MySQL)

CREATE DATABASE IF NOT EXISTS clenzy_db;
USE clenzy_db;

-- 1. Users Table (Customers)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    profile_photo_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    gender ENUM('Male', 'Female', 'Other', 'Prefer Not to Say'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Workers Table (Service Professionals)
CREATE TABLE workers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    profile_photo_url TEXT,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    is_active BOOLEAN DEFAULT TRUE,
    verification_status ENUM('Pending', 'Verified', 'Rejected') DEFAULT 'Pending',
    current_lat DECIMAL(10, 8),
    current_lng DECIMAL(11, 8),
    last_location_update TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Worker Verification (KYC Documents)
CREATE TABLE worker_verification (
    id INT AUTO_INCREMENT PRIMARY KEY,
    worker_id INT,
    doc_type ENUM('ID_Card', 'Police_Clearance', 'Skill_Certificate'),
    doc_url TEXT NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    reviewer_notes TEXT,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE
);

-- 4. Services Table
CREATE TABLE services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(50) NOT NULL, -- e.g., Cleaning, Plumbing, Electrical
    service_name VARCHAR(100) NOT NULL,
    base_price DECIMAL(10, 2),
    estimated_duration_minutes INT,
    is_available BOOLEAN DEFAULT TRUE
);

-- 5. Bookings Table
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    service_id INT,
    worker_id INT DEFAULT NULL,
    status ENUM('Pending', 'Assigned', 'InProgress', 'Completed', 'Cancelled') DEFAULT 'Pending',
    booking_time DATETIME NOT NULL,
    address_text TEXT NOT NULL,
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    risk_score DECIMAL(3, 2) DEFAULT 0.0,
    is_panic_triggered BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (service_id) REFERENCES services(id),
    FOREIGN KEY (worker_id) REFERENCES workers(id)
);

-- 6. Dispatch Logs (CRADE Decisions)
CREATE TABLE dispatch_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    decision_type ENUM('Solo', 'Dual', 'Escalated') NOT NULL,
    risk_factors TEXT, -- JSON blob of factors considered
    reasoning TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- 7. Panic Alerts
CREATE TABLE panic_alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    triggered_by_type ENUM('User', 'Worker') NOT NULL,
    triggered_by_id INT NOT NULL,
    status ENUM('Open', 'Investigating', 'Resolved') DEFAULT 'Open',
    resolver_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- 8. Emergency Contacts
CREATE TABLE user_emergency_contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    contact_name VARCHAR(100),
    phone_number VARCHAR(15),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 9. Payments Table
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('Cash', 'Card', 'UPI', 'Wallet'),
    status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- 10. Feedback & NLP Sentiment
CREATE TABLE feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    sentiment_score DECIMAL(3, 2), -- Output from ML Sentiment Model
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

-- 11. Worker Availability (Slots)
CREATE TABLE availability (
    id INT AUTO_INCREMENT PRIMARY KEY,
    worker_id INT,
    day_of_week INT, -- 0 for Sunday
    start_time TIME,
    end_time TIME,
    FOREIGN KEY (worker_id) REFERENCES workers(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_worker_location ON workers(current_lat, current_lng);
CREATE INDEX idx_booking_status ON bookings(status);
CREATE INDEX idx_panic_status ON panic_alerts(status);
