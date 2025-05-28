-- =========================================================
-- DROP EXISTING OBJECTS
-- =========================================================

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PrescriptionDetails CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Prescription CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE PatientDoctor CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Sells CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Drug CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Contract CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Pharmacy CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE PharmaceuticalCompany CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Patient CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE Doctor CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE pharmacy_seq';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER pharmacy_bi';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- =========================================================
-- CREATE TABLES + CONSTRAINTS
-- =========================================================

CREATE TABLE Patient (
    AadharID CHAR(12) PRIMARY KEY,
    Name VARCHAR2(100),
    Address VARCHAR2(200),
    Age NUMBER
);

CREATE TABLE Doctor (
    AadharID CHAR(12) PRIMARY KEY,
    Name VARCHAR2(100),
    Specialty VARCHAR2(100),
    Experience NUMBER
);

CREATE TABLE Pharmacy (
    PharmacyID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Address VARCHAR2(200),
    Phone VARCHAR2(15)
);

CREATE SEQUENCE pharmacy_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER pharmacy_bi
BEFORE INSERT ON Pharmacy
FOR EACH ROW
BEGIN
    :NEW.PharmacyID := pharmacy_seq.NEXTVAL;
END;
/

CREATE TABLE PharmaceuticalCompany (
    Name VARCHAR2(100) PRIMARY KEY,
    Phone VARCHAR2(15)
);

CREATE TABLE Drug (
    TradeName VARCHAR2(100),
    Formula VARCHAR2(200),
    CompanyName VARCHAR2(100),
    PRIMARY KEY (TradeName, CompanyName),
    FOREIGN KEY (CompanyName) REFERENCES PharmaceuticalCompany(Name) ON DELETE CASCADE
);

CREATE TABLE Sells (
    PharmacyID NUMBER,
    TradeName VARCHAR2(100),
    CompanyName VARCHAR2(100),
    Price NUMBER(10,2),
    PRIMARY KEY (PharmacyID, TradeName, CompanyName),
    FOREIGN KEY (PharmacyID) REFERENCES Pharmacy(PharmacyID),
    FOREIGN KEY (TradeName, CompanyName) REFERENCES Drug(TradeName, CompanyName)
);

CREATE TABLE Prescription (
    DoctorID CHAR(12),
    PatientID CHAR(12),
    PrescDate DATE,
    PRIMARY KEY (DoctorID, PatientID, PrescDate),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(AadharID),
    FOREIGN KEY (PatientID) REFERENCES Patient(AadharID)
);

CREATE TABLE PrescriptionDetails (
    DoctorID CHAR(12),
    PatientID CHAR(12),
    PrescDate DATE,
    TradeName VARCHAR2(100),
    CompanyName VARCHAR2(100),
    Quantity NUMBER,
    PRIMARY KEY (DoctorID, PatientID, PrescDate, TradeName, CompanyName),
    FOREIGN KEY (DoctorID, PatientID, PrescDate) REFERENCES Prescription(DoctorID, PatientID, PrescDate),
    FOREIGN KEY (TradeName, CompanyName) REFERENCES Drug(TradeName, CompanyName)
);

CREATE TABLE Contract (
    PharmacyID NUMBER,
    CompanyName VARCHAR2(100),
    StartDate DATE,
    EndDate DATE,
    Content CLOB,
    Supervisor VARCHAR2(100),
    PRIMARY KEY (PharmacyID, CompanyName, StartDate),
    FOREIGN KEY (PharmacyID) REFERENCES Pharmacy(PharmacyID),
    FOREIGN KEY (CompanyName) REFERENCES PharmaceuticalCompany(Name)
);

CREATE TABLE PatientDoctor (
    PatientID CHAR(12),
    DoctorID CHAR(12),
    PRIMARY KEY (PatientID, DoctorID),
    FOREIGN KEY (PatientID) REFERENCES Patient(AadharID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(AadharID)
);

-- =========================================================
-- DUMMY DATA INSERTS
-- =========================================================

INSERT INTO Patient VALUES ('123456789012', 'Ravi Kumar', 'Hyderabad', 34);
INSERT INTO Doctor VALUES ('987654321098', 'Dr. Sharma', 'Cardiology', 15);
INSERT INTO PharmaceuticalCompany VALUES ('MedLife', '08012345678');
INSERT INTO Pharmacy (Name, Address, Phone) VALUES ('Nova Banjara', 'Banjara Hills', '04012345678');
INSERT INTO Drug VALUES ('Paracetamol', 'C8H9NO2', 'MedLife');
INSERT INTO Sells VALUES (1, 'Paracetamol', 'MedLife', 20.50);
INSERT INTO Prescription VALUES ('987654321098', '123456789012', DATE '2025-04-20');
INSERT INTO PrescriptionDetails VALUES ('987654321098', '123456789012', DATE '2025-04-20', 'Paracetamol', 'MedLife', 2);
INSERT INTO Contract VALUES (1, 'MedLife', DATE '2024-01-01', DATE '2025-01-01', 'Annual supply of all OTCs', 'Supervisor A');
INSERT INTO PatientDoctor VALUES ('123456789012', '987654321098');

-- =========================================================
-- STORED PROCEDURES & FUNCTION
-- =========================================================

-- 1. Add or Update Prescription (latest only)
CREATE OR REPLACE PROCEDURE AddPrescription (
    d_id IN CHAR,
    p_id IN CHAR,
    p_date IN DATE,
    drug_name IN VARCHAR2,
    comp_name IN VARCHAR2,
    qty IN NUMBER
) IS
BEGIN
    DELETE FROM PrescriptionDetails WHERE DoctorID = d_id AND PatientID = p_id;
    DELETE FROM Prescription WHERE DoctorID = d_id AND PatientID = p_id;

    INSERT INTO Prescription (DoctorID, PatientID, PrescDate)
    VALUES (d_id, p_id, p_date);

    INSERT INTO PrescriptionDetails (DoctorID, PatientID, PrescDate, TradeName, CompanyName, Quantity)
    VALUES (d_id, p_id, p_date, drug_name, comp_name, qty);
END;
/

-- 2. Report on Patient's Prescriptions in a Period
CREATE OR REPLACE PROCEDURE ReportPatientPrescriptions (
    p_id IN CHAR,
    start_date IN DATE,
    end_date IN DATE
) IS
BEGIN
    FOR rec IN (
        SELECT * FROM Prescription
        WHERE PatientID = p_id AND PrescDate BETWEEN start_date AND end_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Doctor: ' || rec.DoctorID || ', Date: ' || rec.PrescDate);
    END LOOP;
END;
/

-- 3. Print Prescription Details for a Date
CREATE OR REPLACE PROCEDURE GetPrescriptionDetails (
    p_id IN CHAR,
    p_date IN DATE
) IS
BEGIN
    FOR rec IN (
        SELECT * FROM PrescriptionDetails
        WHERE PatientID = p_id AND PrescDate = p_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Drug: ' || rec.TradeName || ', Company: ' || rec.CompanyName || ', Qty: ' || rec.Quantity);
    END LOOP;
END;
/

-- 4. Get Drugs by Pharma Company
CREATE OR REPLACE FUNCTION GetDrugsByCompany (
    comp_name IN VARCHAR2
) RETURN SYS_REFCURSOR IS
    result SYS_REFCURSOR;
BEGIN
    OPEN result FOR
    SELECT TradeName, Formula FROM Drug WHERE CompanyName = comp_name;
    RETURN result;
END;
/

-- 5. Stock of a Pharmacy
CREATE OR REPLACE PROCEDURE GetStockPosition (
    pharm_id IN NUMBER
) IS
BEGIN
    FOR rec IN (
        SELECT TradeName, CompanyName, Price FROM Sells WHERE PharmacyID = pharm_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Drug: ' || rec.TradeName || ', Company: ' || rec.CompanyName || ', Price: ' || rec.Price);
    END LOOP;
END;
/

-- 6. Pharmacy-Company Contact Info
CREATE OR REPLACE PROCEDURE GetPharmacyCompanyContacts IS
BEGIN
    FOR rec IN (
        SELECT p.Name AS Pharmacy, pc.Phone AS CompanyPhone, c.Supervisor
        FROM Contract c
        JOIN Pharmacy p ON c.PharmacyID = p.PharmacyID
        JOIN PharmaceuticalCompany pc ON c.CompanyName = pc.Name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Pharmacy: ' || rec.Pharmacy || ', Phone: ' || rec.CompanyPhone || ', Supervisor: ' || rec.Supervisor);
    END LOOP;
END;
/

-- 7. List Patients of a Doctor
CREATE OR REPLACE PROCEDURE GetDoctorPatients (
    doc_id IN CHAR
) IS
BEGIN
    FOR rec IN (
        SELECT PatientID FROM PatientDoctor WHERE DoctorID = doc_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Patient ID: ' || rec.PatientID);
    END LOOP;
END;
/

-- =========================================================
-- INSERT PROCEDURES
-- =========================================================

CREATE OR REPLACE PROCEDURE AddPatient (
    p_id IN CHAR, name IN VARCHAR2, addr IN VARCHAR2, age IN NUMBER
) IS
BEGIN
    INSERT INTO Patient VALUES (p_id, name, addr, age);
END;
/

CREATE OR REPLACE PROCEDURE AddDoctor (
    d_id IN CHAR, name IN VARCHAR2, spec IN VARCHAR2, exp IN NUMBER
) IS
BEGIN
    INSERT INTO Doctor VALUES (d_id, name, spec, exp);
END;
/

CREATE OR REPLACE PROCEDURE AddPharmacy (
    name IN VARCHAR2, addr IN VARCHAR2, phone IN VARCHAR2
) IS
BEGIN
    INSERT INTO Pharmacy(Name, Address, Phone) VALUES (name, addr, phone);
END;
/

CREATE OR REPLACE PROCEDURE AddCompany (
    comp_name IN VARCHAR2, phone IN VARCHAR2
) IS
BEGIN
    INSERT INTO PharmaceuticalCompany VALUES (comp_name, phone);
END;
/

CREATE OR REPLACE PROCEDURE AddDrug (
    trade IN VARCHAR2, formula IN VARCHAR2, comp IN VARCHAR2
) IS
BEGIN
    INSERT INTO Drug VALUES (trade, formula, comp);
END;
/

CREATE OR REPLACE PROCEDURE AddContract (
    pharm_id IN NUMBER, comp IN VARCHAR2, sdate IN DATE, edate IN DATE, content IN CLOB, supervisor IN VARCHAR2
) IS
BEGIN
    INSERT INTO Contract VALUES (pharm_id, comp, sdate, edate, content, supervisor);
END;
/

-- =========================================================
-- DELETE PROCEDURES
-- =========================================================

CREATE OR REPLACE PROCEDURE DeletePatient (p_id IN CHAR) IS
BEGIN
    DELETE FROM Patient WHERE AadharID = p_id;
END;
/

CREATE OR REPLACE PROCEDURE DeleteDoctor (d_id IN CHAR) IS
BEGIN
    DELETE FROM Doctor WHERE AadharID = d_id;
END;
/

CREATE OR REPLACE PROCEDURE DeletePharmacy (pharm_id IN NUMBER) IS
BEGIN
    DELETE FROM Pharmacy WHERE PharmacyID = pharm_id;
END;
/

CREATE OR REPLACE PROCEDURE DeleteCompany (comp_name IN VARCHAR2) IS
BEGIN
    DELETE FROM PharmaceuticalCompany WHERE Name = comp_name;
END;
/

-- =========================================================
-- UPDATE PROCEDURES
-- =========================================================

CREATE OR REPLACE PROCEDURE UpdatePatient (
    p_id IN CHAR, new_name IN VARCHAR2, new_addr IN VARCHAR2, new_age IN NUMBER
) IS
BEGIN
    UPDATE Patient SET Name = new_name, Address = new_addr, Age = new_age WHERE AadharID = p_id;
END;
/

CREATE OR REPLACE PROCEDURE UpdateDoctor (
    d_id IN CHAR, new_name IN VARCHAR2, new_spec IN VARCHAR2, new_exp IN NUMBER
) IS
BEGIN
    UPDATE Doctor SET Name = new_name, Specialty = new_spec, Experience = new_exp WHERE AadharID = d_id;
END;
/

CREATE OR REPLACE PROCEDURE UpdatePharmacy (
    pharm_id IN NUMBER, new_name IN VARCHAR2, new_addr IN VARCHAR2, new_phone IN VARCHAR2
) IS
BEGIN
    UPDATE Pharmacy SET Name = new_name, Address = new_addr, Phone = new_phone WHERE PharmacyID = pharm_id;
END;
/

CREATE OR REPLACE PROCEDURE UpdateCompany (
    comp_name IN VARCHAR2, new_phone IN VARCHAR2
) IS
BEGIN
    UPDATE PharmaceuticalCompany SET Phone = new_phone WHERE Name = comp_name;
END;
/





BEGIN
    AddPatient('111122223333', 'Amit Verma', 'Delhi', 29);
END;
/

BEGIN
    DeletePatient('111122223333');
END;
/

BEGIN
    UpdatePatient('123456789012', 'Ravi Kumar Updated', 'Mumbai', 35);
END;
/

BEGIN
    AddDrug('Ibuprofen', 'C13H18O2', 'MedLife');
END;
/


BEGIN
    AddDoctor('222233334444', 'Dr. Verma', 'Neurology', 10);
END;
/

BEGIN
    AddPharmacy('Health Plus', 'Jubilee Hills', '04098765432');
END;
/

BEGIN
    ReportPatientPrescriptions('123456789012', DATE '2025-01-01', DATE '2025-12-31');
END;
/

BEGIN
    GetPrescriptionDetails('123456789012', DATE '2025-04-20');
END;
/

DECLARE
    cur SYS_REFCURSOR;
    drug_name VARCHAR2(100);
    formula VARCHAR2(200);
BEGIN
    cur := GetDrugsByCompany('MedLife');
    LOOP
        FETCH cur INTO drug_name, formula;
        EXIT WHEN cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Drug: ' || drug_name || ', Formula: ' || formula);
    END LOOP;
    CLOSE cur;
END;
/

BEGIN
    GetStockPosition(1);
END;
/

BEGIN
    GetPharmacyCompanyContacts;
END;
/

BEGIN
    GetDoctorPatients('987654321098');
END;
/

BEGIN
    AddPrescription('987654321098', '123456789012', SYSDATE, 'Ibuprofen', 'MedLife', 1);
END;
/

SELECT * FROM Patient;
SELECT * FROM Doctor;
SELECT * FROM Prescription;
SELECT * FROM PrescriptionDetails;
SELECT * FROM Drug;
SELECT * FROM Pharmacy;
SELECT * FROM PharmaceuticalCompany;

BEGIN
    AddDoctor('3552389732', 'Dr. Ayush', 'Cardiologist', 11);
END;

DECLARE
    cur SYS_REFCURSOR;
    drug_name VARCHAR2(100);
    formula VARCHAR2(200);
BEGIN
    cur := GetDrugsByCompany('MedLife');
    LOOP
        FETCH cur INTO drug_name, formula;
        EXIT WHEN cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Drug: ' || drug_name || ', Formula: ' || formula);
    END LOOP;
    CLOSE cur;
END;
/