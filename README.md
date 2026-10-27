# Little Lemon Database — Capstone Project

A MySQL data model and booking system for the Little Lemon restaurant, with a Python
client and the five required stored procedures.

## Contents
| File | Description |
|------|-------------|
| `ER_diagram.png` | Entity-relationship diagram showing the table connections |
| `LittleLemonDB.sql` | Database schema (4 tables) **+ the 5 stored procedures** |
| `load_data.py` | Loads `LittleLemon_data.xlsx` into the normalized tables |
| `LittleLemon_Client.ipynb` | Python client — connects and runs every stored procedure |
| `LittleLemon_data.xlsx` | Source data (Orders sheet, 21,000 rows) |

## Data model
Normalized into four tables (see `ER_diagram.png`):

- **Customers** — `CustomerID` (PK), name and location fields
- **Menu** — `MenuID` (PK), course / cuisine / starter / dessert / drink / sides
- **Orders** — `OrderRecordID` (PK), FKs to Customers and Menu, plus cost/sales/quantity/etc.
- **Bookings** — `BookingID` (PK), booking date, table number, FK to Customers

> `OrderRecordID` (the source **Row Number**) is the primary key of Orders because the
> business `OrderID` repeats across order lines.

## Stored procedures (in `LittleLemonDB.sql`)
| Procedure | Purpose |
|-----------|---------|
| `GetMaxQuantity()` | Returns the maximum quantity ordered in a single order |
| `ManageBooking(date, table)` | Reports whether a table is free or already booked on a date |
| `AddBooking(id, customer, date, table)` | Inserts a new booking |
| `UpdateBooking(id, date)` | Updates the date of an existing booking |
| `CancelBooking(id)` | Deletes a booking |

## How to run
1. Start MySQL. Import the schema and procedures:
   ```bash
   mysql -u root -p < LittleLemonDB.sql
   ```
2. Populate the tables from the Excel data (needs `mysql-connector-python` and `openpyxl`):
   ```bash
   py -3.12 load_data.py
   ```
3. Open `LittleLemon_Client.ipynb` in Jupyter and run the cells to exercise each procedure.
   Update the MySQL `password` in the config cell to match your server.

## Notes
- Built and tested on MySQL Server 8.4.
- The `ER_diagram.png` doubles as the data model diagram for the ER-diagram criterion.
