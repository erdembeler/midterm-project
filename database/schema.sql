-- =============================================
-- LIBRARY BORROWING & RESERVATION SYSTEM
-- Database Schema
-- Date: 24.11.2025
-- =============================================

-- 1. USERS TABLE
-- Stores all system actors (Members, Librarians, Admins)
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Passwords should be hashed
    email VARCHAR(100) NOT NULL,
    role ENUM('Member', 'Librarian', 'Admin') DEFAULT 'Member',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. BOOKS TABLE (Catalog)
-- Stores general information about book titles
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    isbn VARCHAR(20) UNIQUE,
    publisher VARCHAR(100),
    publication_year INT
);

-- 3. BOOK COPIES TABLE (Inventory)
-- Represents physical copies on the shelf.
-- This allows managing multiple copies of the same book (Stock Tracking).
CREATE TABLE BookCopies (
    copy_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    inventory_code VARCHAR(50) UNIQUE, -- E.g., "HP-001"
    status ENUM('Available', 'Borrowed', 'Lost', 'Maintenance') DEFAULT 'Available',
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);

-- 4. LOANS TABLE (Transactions)
-- Tracks active and past borrowing history.
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrow_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME, -- Calculated automatically by system (e.g., +15 days)
    return_date DATETIME NULL, -- NULL means not returned yet
    status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (copy_id) REFERENCES BookCopies(copy_id)
);

-- 5. RESERVATIONS TABLE
-- Manages requests for books that are currently unavailable.
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    book_id INT NOT NULL, -- Reservation is made on a Title, not a specific copy
    request_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Approved', 'Rejected', 'Fulfilled') DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- =============================================
-- DUMMY DATA (FOR TESTING)
-- =============================================

-- Insert Users
INSERT INTO Users (username, password_hash, email, role) VALUES 
('taylan_admin', 'hashed_secret_123', 'taylan@library.com', 'Librarian'),
('ahmet_member', 'hashed_pass_456', 'ahmet@student.com', 'Member'),
('ela_member', 'hashed_pass_789', 'ela@student.com', 'Member');

-- Insert Books
INSERT INTO Books (title, author, category, isbn, publication_year) VALUES 
('Clean Code', 'Robert C. Martin', 'Software Engineering', '978-0132350884', 2008),
('Introduction to Algorithms', 'Thomas H. Cormen', 'Computer Science', '978-0262033848', 2009),
('Harry Potter and the Sorcerers Stone', 'J.K. Rowling', 'Fiction', '978-0747532743', 1997);

-- Insert Book Copies (Stock)
-- Clean Code has 2 copies, Harry Potter has 1 copy
INSERT INTO BookCopies (book_id, inventory_code, status) VALUES 
(1, 'CC-001', 'Available'),
(1, 'CC-002', 'Borrowed'), -- One copy is currently out
(2, 'ALGO-001', 'Available'),
(3, 'HP-001', 'Available');

-- Insert Active Loan (Ahmet borrowed Clean Code Copy #2)
INSERT INTO Loans (user_id, copy_id, borrow_date, due_date, status) VALUES 
(2, 2, '2025-11-20 10:00:00', '2025-12-05 10:00:00', 'Active');

-- Insert Reservation (Ela wants Harry Potter)
INSERT INTO Reservations (user_id, book_id, request_date, status) VALUES 
(3, 3, '2025-11-24 09:30:00', 'Pending');
