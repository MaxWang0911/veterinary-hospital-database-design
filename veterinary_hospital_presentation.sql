
--31061 Database PrinciplesDatabas, Assignment 5
--Zheng Wang  zheng.wang-15@student.uts.edu.au
--script name: DBanimalservice.SQL */
--purpose: Builds PostgreSQL tables for University Veterinary Teaching Hospital Sydney
--date: 29/09/2024
--The URL for the website related to this database is https://www.sydney.edu.au/vet-hospital/

--==================================================================================================================================================
--This database models the operations of a veterinary hospital, capturing all details about customers, 
--their pets, medical staff, clinical cases, bills, and prescriptions for medicines. It aims to provide a comprehensive overview of the interactions 
--and processes occurring within a veterinary hospital setting.
--===================================================================================================================================================

--The database supports a range of use cases within the veterinary hospital:

--Track customer information and manage their pets' medical history.
--Assign and manage staff roles for various clinical cases, ensuring appropriate care.
--Document medical treatments, prescriptions, and associated billing in an organized manner.
--Analyze trends in treatments, medicine usage, and pet demographics for better healthcare delivery.



DROP TABLE IF EXISTS Prescription CASCADE;
DROP TABLE IF EXISTS Clinical_case CASCADE;
DROP TABLE IF EXISTS Bill CASCADE;
DROP TABLE IF EXISTS Nurse CASCADE;
DROP TABLE IF EXISTS Doctor CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Customer_pet CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Medicine CASCADE;
DROP TABLE IF EXISTS Insurance_provider CASCADE;


--=================================================================================================

-- Create Customer Table
CREATE TABLE Customer (
    Cust_ID      NUMERIC(5)    NOT NULL,
    Cust_Email   VARCHAR(30),
    Cust_Fname   VARCHAR(15),
    Cust_Lname   VARCHAR(20),
    Cust_Pho     VARCHAR(10),
    Cust_Street  VARCHAR(30),
    Cust_Sub     VARCHAR(20),
    Cust_City    VARCHAR(20) DEFAULT 'Sydney',
    Cust_State   VARCHAR(4)  DEFAULT 'NSW', 
    Cust_Pocode  NUMERIC(4),
    Cust_DivLN   VARCHAR(8),
    CONSTRAINT Customer_PK PRIMARY KEY (Cust_ID),
    CHECK(LENGTH(Cust_Pho) = 10),
    CHECK(Cust_State IN ('NSW', 'VIC', 'QLD', 'SA', 'WA', 'TAS', 'NT', 'ACT')),
    CHECK(Cust_Pocode BETWEEN 200 AND 9999),
    CHECK(LENGTH(Cust_DivLN) = 8)
);

-- Create Customer_pet Table
CREATE TABLE Customer_pet (
    Cust_PetID       NUMERIC(5)    NOT NULL,
    Cust_PetName     VARCHAR(20),
    Cust_PetSpecie   VARCHAR(20),
    Cust_PetDesexed  VARCHAR(3), CHECK (Cust_PetDesexed IN ('Yes', 'No')),
    Cust_PetVacc     VARCHAR(3), CHECK (Cust_PetVacc IN ('Yes', 'No')),
    Cust_PetFWT      VARCHAR(3), CHECK (Cust_PetFWT IN ('Yes', 'No')),
    Cust_ID          NUMERIC(5),
    CONSTRAINT Cust_PetID_PK PRIMARY KEY (Cust_PetID),
    CONSTRAINT Cust_PetID_FK FOREIGN KEY (Cust_ID) REFERENCES Customer (Cust_ID) ON DELETE CASCADE
);

-- Create Staff Table
CREATE TABLE Staff (
    Staff_code      VARCHAR(5)      NOT NULL,
    Staff_Fname     VARCHAR(15),
    Staff_Lname     VARCHAR(30),
    Staff_Email     VARCHAR(40),
    Staff_Mob       VARCHAR(10),
    ManagerID       VARCHAR(5),
    CONSTRAINT Staff_PK PRIMARY KEY (Staff_code),
    CONSTRAINT Staff_FK2 FOREIGN KEY (ManagerID) REFERENCES Staff (Staff_code) ON DELETE RESTRICT
);

-- Create Doctor Table
CREATE TABLE Doctor (
    Staff_code          VARCHAR(5),
    Docspecialty        VARCHAR(20),
    Doclicense          VARCHAR(20),
    CONSTRAINT Doctor_PK PRIMARY KEY (Staff_code),
    CONSTRAINT Doctor_FK FOREIGN KEY (Staff_code) REFERENCES Staff (Staff_code) ON DELETE CASCADE,
    CHECK (Docspecialty IN ('General practice', 'Specialty services'))
);

-- Create Nurse Table
CREATE TABLE Nurse (
    Staff_code     VARCHAR(5),
    Nurtype        VARCHAR(20),
    CONSTRAINT Nurse_PK PRIMARY KEY (Staff_code),
    CONSTRAINT Nurse_FK FOREIGN KEY (Staff_code) REFERENCES Staff (Staff_code) ON DELETE CASCADE,
    CHECK (Nurtype IN ('Surgery', 'Emergency', 'Care'))
);

-- Create Clinical_case Table
CREATE TABLE Clinical_case (
    CaseID                          NUMERIC(10) NOT NULL,
    Cust_PetID                      NUMERIC(5),
    Casedate                        DATE,  
    Casesymp                        VARCHAR(500),
    Casediag                        VARCHAR(500),
    DoctorCode                      VARCHAR(5),
    NurseCode                       VARCHAR(5),
    CONSTRAINT Clinical_case_PK PRIMARY KEY (CaseID, Cust_PetID),
    CONSTRAINT Clinical_case_FK1 FOREIGN KEY (Cust_PetID) REFERENCES Customer_pet (Cust_PetID) ON DELETE CASCADE,
    CONSTRAINT Clinical_case_FK2 FOREIGN KEY (DoctorCode) REFERENCES Doctor (Staff_code) ON DELETE RESTRICT,
    CONSTRAINT Clinical_case_FK3 FOREIGN KEY (NurseCode)  REFERENCES Nurse (Staff_code) ON DELETE RESTRICT
);

-- Create Bill Table
CREATE TABLE Bill (
    Bill_No                         NUMERIC(8)      NOT NULL,
    CaseID                          NUMERIC(10),
    Cust_PetID                      NUMERIC(5),
    Bill_Date                       DATE,  
    CONSTRAINT Bill_PK PRIMARY KEY (Bill_No),
    CONSTRAINT Bill_FK1 FOREIGN KEY (Cust_PetID, CaseID) REFERENCES Clinical_case (Cust_PetID, CaseID) ON DELETE CASCADE
);

-- Create Medicine Table
CREATE TABLE Medicine (
    Medicine_ID      NUMERIC(5)    NOT NULL,
    Medicinename     VARCHAR(50),
    Medicinedosg     VARCHAR(20),
    Medicinemethod   VARCHAR(50),
    Medicineprice    DECIMAL(10, 2),
    Medicinedesc     VARCHAR(500),
    CONSTRAINT Medicine_PK PRIMARY KEY (Medicine_ID)
);

-- Create Prescription Table
CREATE TABLE Prescription (
    Startdate        DATE,
    Enddate          DATE,
    Drugamount       VARCHAR(20),
    CaseID           NUMERIC(10),
    Cust_PetID       NUMERIC(5),
    Medicine_ID      NUMERIC(5),
    CONSTRAINT Prescription_FK1 FOREIGN KEY (CaseID, Cust_PetID) REFERENCES Clinical_case (CaseID, Cust_PetID) ON DELETE CASCADE,
    CONSTRAINT Prescription_FK2 FOREIGN KEY (Medicine_ID) REFERENCES Medicine (Medicine_ID) ON DELETE RESTRICT
);


-- Create Insurance_provider Table
CREATE TABLE Insurance_provider (
    ProviderID      VARCHAR(5)    NOT NULL,
    Providername    VARCHAR(50),
    Provideraddress VARCHAR(100),
    Providerphone   VARCHAR(15),
    CONSTRAINT Insurance_provider_PK PRIMARY KEY (ProviderID)
);

--Link Customer_pet to Insurance_provider
ALTER TABLE Customer_pet
    ADD COLUMN ProviderID VARCHAR(5),
    ADD CONSTRAINT Cust_Pet_Insurance_FK FOREIGN KEY (ProviderID) REFERENCES Insurance_provider (ProviderID) ;



-- Create a view(a virtual table) that displays detailed information about prescriptions 
CREATE VIEW PrescriptionDetails AS
    SELECT 
    Prescription.Startdate, 
    Prescription.Enddate, 
    Customer_pet.Cust_PetName, 
    Medicine.Medicinename, 
    Medicine.Medicinedosg, 
    Medicine.Medicinemethod
    FROM 
    Prescription
    JOIN 
    Customer_pet ON Prescription.Cust_PetID = Customer_pet.Cust_PetID
    JOIN 
    Medicine ON Prescription.Medicine_ID = Medicine.Medicine_ID;


--=================================================================================================
-- Insert into Customer
INSERT INTO Customer (Cust_ID, Cust_Email, Cust_Fname, Cust_Lname, Cust_Pho, Cust_Street, Cust_Sub, Cust_City, Cust_State, Cust_Pocode, Cust_DivLN)
VALUES
(1, 'john.doe@example.com', 'John', 'Doe', '1234567890', '123 Elm St', 'Suburb A', 'Sydney', 'NSW', 2000, 12345678),
(2, 'jane.smith@example.com', 'Jane', 'Smith', '2345678901', '456 Oak St', 'Suburb B', 'Melbourne', 'VIC', 3000, 23456789),
(3, 'alice.brown@example.com', 'Alice', 'Brown', '3456789012', '789 Pine St', 'Suburb C', 'Brisbane', 'QLD', 4000, 34567890);

-- Insert into Customer_pet
INSERT INTO Customer_pet (Cust_PetID, Cust_PetName, Cust_PetSpecie, Cust_PetDesexed, Cust_PetVacc, Cust_PetFWT, Cust_ID)
VALUES
(1, 'Buddy', 'Dog', 'Yes', 'Yes', 'No', 1),
(2, 'Mittens', 'Cat', 'No', 'Yes', 'Yes', 2),
(3, 'Max', 'Rabbit', 'Yes', 'No', 'Yes', 3);

-- Insert into Staff
INSERT INTO Staff (Staff_code, Staff_Fname, Staff_Lname, Staff_Email, Staff_Mob, ManagerID)
VALUES
('S001', 'Emma', 'White', 'emma.w@example.com', '9876543210', NULL),
('S002', 'Jack', 'Black', 'jack.b@example.com', '8765432109', 'S001'),
('S003', 'Olivia', 'Green', 'olivia.g@example.com', '7654321098', 'S001'),
('S004', 'Emily', 'Brown', 'emily.b@example.com', '6543210987', NULL),
('S005', 'Liam', 'Jones', 'liam.j@example.com', '5432109876', 'S002'),
('S006', 'Sophia', 'Davis', 'sophia.d@example.com', '4321098765', 'S002');

-- Insert into Doctor
INSERT INTO Doctor (Staff_code, Docspecialty)
VALUES
('S001', 'General practice'),
('S002', 'Specialty services'),
('S003', 'General practice');

-- Insert into Nurse
INSERT INTO Nurse (Staff_code, Nurtype)
VALUES
('S004', 'Surgery'),
('S005', 'Emergency'),
('S006', 'Care');

-- Insert into Clinical_case
INSERT INTO Clinical_case (CaseID, Cust_PetID, Casedate, Casesymp, Casediag, DoctorCode, NurseCode)
VALUES
(101, 1, '2024-01-15', 'Fever', 'Infection', 'S002', 'S004'),
(102, 2, '2024-02-20', 'Limping', 'Fracture', 'S002', 'S005'),
(103, 3, '2024-03-25', 'Cough', 'Respiratory issue', 'S003', 'S006');

-- Insert into Bill

INSERT INTO Bill (Bill_No, CaseID, Cust_PetID, Bill_Date)
VALUES
(201, 101, 1, '2024-01-20'),
(202, 102, 2, '2024-02-25'),
(203, 103, 3, '2024-03-30');

-- Insert into Medicine
INSERT INTO Medicine (Medicine_ID, Medicinename, Medicinedosg, Medicinemethod, Medicineprice, Medicinedesc)
VALUES
(301, 'Amoxicillin', '500mg', 'Oral', 20.00, 'Antibiotic for infection'),
(302, 'Ibuprofen', '200mg', 'Oral', 10.00, 'Pain relief and anti-inflammatory'),
(303, 'Saline', '10ml', 'Injection', 5.00, 'Rehydration solution');

-- Insert into Prescription
INSERT INTO Prescription (Startdate, Enddate, Drugamount, CaseID, Cust_PetID, Medicine_ID)
VALUES
('2024-01-16', '2024-01-20', '10mg', 101, 1, 301),
('2024-02-21', '2024-02-26', '15mg', 102, 2, 302),
('2024-03-26', '2024-03-31', '5ml', 103, 3, 303);

-- Insert records into Insurance_provider Table
INSERT INTO Insurance_provider (ProviderID, Providername, Provideraddress, Providerphone)
VALUES 
('Ins01', 'HealthPlus Insurance', '1234 Health St, Sydney, NSW', '0412345678'),
('Ins02', 'PetSecure', '5678 Secure Ave, Melbourne, VIC', '0423456789'),
('Ins03', 'VetCover Australia', '9101 Vet Rd, Brisbane, QLD', '0434567890');

--=================================================================================================
--a. A Simple Query of a Single Table:List all customer names and their email addresses.
--SELECT Cust_Fname, Cust_Lname, Cust_Email FROM Customer;

--b. A Query Using "Natural Join":Find all prescriptions with the related pet name and medication name.
--SELECT Prescription.Startdate, Prescription.Enddate, Customer_pet.Cust_PetName, Medicine.Medicinename FROM Prescription NATURAL JOIN Customer_pet NATURAL JOIN Medicine;


--c. Cross Product Equivalent to the "Natural Join" Query:Find all prescriptions, including their start and end dates, the associated pet name, and the medication name, based on their IDs.
--SELECT Prescription.Startdate, Prescription.Enddate, Customer_pet.Cust_PetName, Medicine.Medicinename FROM Prescription, Customer_pet, Medicine WHERE Prescription.Cust_PetID = Customer_pet.Cust_PetID
--AND Prescription.Medicine_ID = Medicine.Medicine_ID;

--d. Query Involving "GROUP BY" (with "HAVING"):Count the number of cases treated by each doctor, only showing doctors who have treated more than one case.
--SELECT DoctorCode, COUNT(CaseID) AS NumCases FROM Clinical_case GROUP BY DoctorCode HAVING COUNT(CaseID) > 1;

--e. Query Using a Subquery:Find the pet names of pets that have been prescribed "Amoxicillin".
--SELECT Cust_PetName FROM Customer_pet WHERE Cust_PetID IN (SELECT Cust_PetID FROM Prescription WHERE Medicine_ID = (SELECT Medicine_ID FROM Medicine WHERE Medicinename = 'Amoxicillin'));

--f. Cross Product That Cannot Be Implemented with "Natural Join" (Self-Join):Find pairs of staff members who have the same manager.
--SELECT A.Staff_Fname AS Staff1, A.Staff_Lname AS LastName1, 
--B.Staff_Fname AS Staff2, B.Staff_Lname AS LastName2, A.ManagerID 
--FROM Staff A
--JOIN Staff B ON A.ManagerID = B.ManagerID
--WHERE A.Staff_code < B.Staff_code;


--===============================================================================================================================================

--CREATE VIEW PrescriptionDetails AS
--SELECT Prescription.Startdate, Prescription.Enddate, Customer_pet.Cust_PetName, Medicine.Medicinename, Medicine.Medicinedosg, Medicine.Medicinemethod
--FROM Prescription JOIN Customer_pet ON Prescription.Cust_PetID = Customer_pet.Cust_PetID JOIN Medicine ON Prescription.Medicine_ID = Medicine.Medicine_ID;

--select * from PrescriptionDetails;