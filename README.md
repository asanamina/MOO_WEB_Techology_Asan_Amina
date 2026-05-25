# Final Project — Hotel Booking Database System

## Student Information
- Student: Amina Asan
- Course: PostgreSQL Database Systems
- Project Title: Hotel Booking Database System

---

# Project Description

This project is a complete relational database system for managing hotel bookings using PostgreSQL.

The database was designed to support the daily operations of a hotel booking platform. The system stores information about guests, hotels, rooms, bookings, employees, services, payments, and departments.

The project demonstrates the use of:
- conceptual and logical database modeling
- normalization (3NF)
- CREATE TABLE statements
- ALTER TABLE operations
- constraints
- INSERT statements with foreign key subqueries
- UPDATE and DELETE operations
- transactions
- role management using GRANT and REVOKE

The database is fully re-runnable and designed according to PostgreSQL best practices.

---

# Database Information

## Database Name
hotel_booking_db

## Schema Name
hotel_booking

---

# Domain Overview

The hotel booking system allows:
- guests to make bookings
- hotels to manage rooms
- services to be attached to bookings
- payments to be recorded
- departments and employees to be managed

The system also supports many-to-many relationships between:
- bookings and rooms
- bookings and services

These relationships are implemented using bridge tables.

---

# Project Files

| File Name | Description |
|---|---|
| 01_model.pdf | Conceptual ERD, Logical Model, Final Schema |
| 02_final.sql | Complete PostgreSQL script |
| README.md | Project documentation |

---

# Database Tables

The project contains 11 tables.

## Main Tables

1. guests
2. departments
3. employees
4. hotels
5. room_types
6. rooms
7. bookings
8. services
9. payments

## Bridge Tables

10. booking_rooms
11. booking_services

---

# Many-to-Many Relationships

## bookings ↔ rooms

A booking may contain multiple rooms, and one room may appear in multiple bookings over time.

This many-to-many relationship is implemented through the bridge table:

booking_rooms

---

## bookings ↔ services

A booking may contain multiple services, and one service may belong to multiple bookings.

This many-to-many relationship is implemented through the bridge table:

booking_services

---

# Third Normal Form (3NF)

The database was designed according to Third Normal Form principles.

## First Normal Form (1NF)
- All values are atomic
- No repeating groups
- No multi-value columns

## Second Normal Form (2NF)
- Non-key attributes depend on the whole primary key

## Third Normal Form (3NF)
- No transitive dependencies
- Reference data separated into independent tables

Examples:
- room types stored separately in room_types
- departments stored separately in departments

This design reduces redundancy and improves data consistency.

---

# Constraints Used

The project includes multiple database constraints to maintain data integrity.

## PRIMARY KEY
Every table contains a primary key.

Example:
```sql
guest_id SERIAL PRIMARY KEY
