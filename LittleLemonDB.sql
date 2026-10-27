-- =====================================================================
--  Little Lemon Database  -  Capstone data model + stored procedures
--
--  Built from LittleLemon_data.xlsx (Orders sheet, 21 columns).
--  Normalized into Customers, Menu, Orders and Bookings.
--  Includes the five required stored procedures:
--    GetMaxQuantity(), ManageBooking(), AddBooking(),
--    UpdateBooking(), CancelBooking()
-- =====================================================================

CREATE DATABASE IF NOT EXISTS LittleLemonDB
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE LittleLemonDB;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Menu;
DROP TABLE IF EXISTS Customers;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- Customers : one row per customer (from Customer ID / Name / location)
-- ---------------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID    VARCHAR(20)  NOT NULL PRIMARY KEY,
    CustomerName  VARCHAR(255) NOT NULL,
    City          VARCHAR(100),
    Country       VARCHAR(100),
    PostalCode    VARCHAR(20),
    CountryCode   VARCHAR(5)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Menu : the dish composition of an order
--        (course, cuisine, starter, dessert, drink, sides)
-- ---------------------------------------------------------------------
CREATE TABLE Menu (
    MenuID        INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CourseName    VARCHAR(100),
    CuisineName   VARCHAR(100),
    StarterName   VARCHAR(100),
    DesertName    VARCHAR(100),
    Drink         VARCHAR(100),
    Sides         VARCHAR(100),
    UNIQUE KEY uq_menu (CourseName, CuisineName, StarterName, DesertName, Drink, Sides)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Orders : the sales fact of the business
-- ---------------------------------------------------------------------
CREATE TABLE Orders (
    OrderRecordID INT          NOT NULL PRIMARY KEY,   -- unique Row Number from the source data
    OrderID       VARCHAR(20),                         -- business order id (can repeat across lines)
    OrderDate     DATE,
    DeliveryDate  DATE,
    CustomerID    VARCHAR(20)  NOT NULL,
    MenuID        INT,
    Cost          DECIMAL(10,2),
    Sales         DECIMAL(10,2),
    Quantity      INT,
    Discount      DECIMAL(10,2),
    DeliveryCost  DECIMAL(10,2),
    KEY idx_order_id (OrderID),
    CONSTRAINT fk_order_customer FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
    CONSTRAINT fk_order_menu     FOREIGN KEY (MenuID)     REFERENCES Menu (MenuID)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Bookings : table reservations (used by the stored procedures)
-- ---------------------------------------------------------------------
CREATE TABLE Bookings (
    BookingID     INT          NOT NULL PRIMARY KEY,
    BookingDate   DATE         NOT NULL,
    TableNumber   INT          NOT NULL,
    CustomerID    VARCHAR(20),
    CONSTRAINT fk_booking_customer FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
) ENGINE=InnoDB;

-- =====================================================================
--  STORED PROCEDURES
-- =====================================================================
DELIMITER //

-- 1. GetMaxQuantity: shows the maximum quantity ordered in a single order
DROP PROCEDURE IF EXISTS GetMaxQuantity //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS "Max Quantity in Order" FROM Orders;
END //

-- 2. ManageBooking: checks whether a table is free or already booked on a date
DROP PROCEDURE IF EXISTS ManageBooking //
CREATE PROCEDURE ManageBooking(IN p_BookingDate DATE, IN p_TableNumber INT)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    SELECT COUNT(*) INTO v_count
      FROM Bookings
     WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;

    IF v_count > 0 THEN
        SELECT CONCAT('Table ', p_TableNumber, ' is already booked on ', p_BookingDate)
               AS "Booking status";
    ELSE
        SELECT CONCAT('Table ', p_TableNumber, ' is available on ', p_BookingDate)
               AS "Booking status";
    END IF;
END //

-- 3. AddBooking: adds a new table booking
DROP PROCEDURE IF EXISTS AddBooking //
CREATE PROCEDURE AddBooking(IN p_BookingID INT, IN p_CustomerID VARCHAR(20),
                            IN p_BookingDate DATE, IN p_TableNumber INT)
BEGIN
    INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNumber)
    VALUES (p_BookingID, p_CustomerID, p_BookingDate, p_TableNumber);
    SELECT CONCAT('New booking added. Booking ID: ', p_BookingID) AS Confirmation;
END //

-- 4. UpdateBooking: updates the date of an existing booking
DROP PROCEDURE IF EXISTS UpdateBooking //
CREATE PROCEDURE UpdateBooking(IN p_BookingID INT, IN p_BookingDate DATE)
BEGIN
    UPDATE Bookings SET BookingDate = p_BookingDate WHERE BookingID = p_BookingID;
    SELECT CONCAT('Booking ', p_BookingID, ' updated to ', p_BookingDate) AS Confirmation;
END //

-- 5. CancelBooking: removes a booking
DROP PROCEDURE IF EXISTS CancelBooking //
CREATE PROCEDURE CancelBooking(IN p_BookingID INT)
BEGIN
    DELETE FROM Bookings WHERE BookingID = p_BookingID;
    SELECT CONCAT('Booking ', p_BookingID, ' cancelled') AS Confirmation;
END //

DELIMITER ;
