# University Veterinary Teaching Hospital Sydney – Database Project

This project was developed for practice. It models the operations of a real-world veterinary hospital — specifically inspired by a personal emergency experience at the University of Sydney Veterinary Hospital.

## 📌 Project Overview

The database system is designed to manage and track:
- Customer and pet information
- Clinical cases and medical staff assignments
- Medicine prescriptions and billing
- Pet insurance details

The project implements:
- Entity and relationship design with integrity constraints
- Proper use of `ON DELETE CASCADE` and `ON DELETE RESTRICT`
- Views for simplified reporting and data access
- A variety of SQL queries demonstrating practical use cases

## 🏥 Real-World Inspiration

> In December, my dog was bitten by another dog. It was a Sunday, and the **University of Sydney Veterinary Hospital** was the only provider offering emergency services. This experience inspired me to build a realistic and practical database to model the operations of such a facility.

### ERD (Entity-Relationship Diagram)
The ERD includes 11 entities:
- `Customer`, `Customer_pet`, `Insurance_provider`
- `Staff`, `Doctor`, `Nurse`
- `Clinical_case`, `Bill`
- `Medicine`, `Prescription`

### Relationships
- One-to-many: Customers → Pets
- Many-to-many: Clinical cases ↔ Medicines (via Prescription)
- One-to-many: Staff → Doctors and Nurses
- Self-join on Staff to identify team hierarchy

### SQL Features Used
- Composite primary keys
- Foreign keys with cascading behaviours
- CHECK constraints (e.g., state validation, pet vaccination status)
- Views (`PrescriptionDetails`)
- Subqueries, joins, groupings, and self-joins

## 📊 Sample Queries

- List all customers and emails
- Join pets with prescribed medicines
- Count how many cases each doctor handled
- Self-join to find staff with the same manager
- Subquery to find pets prescribed a specific medicine


