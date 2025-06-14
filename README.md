# NOVA-Database

This repository contains the SQL schema and scripts for the **NOVA-Database** project. The project demonstrates database design and implementation using SQL, focusing on structured data storage, relationships, and queries.

---

## Project Description

“NOVA” is a chain of pharmacies that sells drugs produced by different Pharmaceutical Companies. This project designs and implements a relational database for NOVA to capture the following information:

1. **Patients:**  
   - For each patient, store: AadharID (unique), name, address, and age.

2. **Doctors:**  
   - For each doctor, store: AadharID (unique), name, specialty, and years of experience.

3. **Pharmaceutical Companies:**  
   - Each company is identified by name and has a phone number.

4. **Drugs:**  
   - For each drug, store the trade name and formula.
   - Each drug is sold by a given pharmaceutical company.
   - The trade name uniquely identifies the drug among those produced by that company.
   - If a pharmaceutical company is deleted, its drugs are also removed.

5. **Pharmacies:**  
   - Each pharmacy has a name, address, and phone number.

6. **Patient-Doctor Relationship:**  
   - Each patient has a primary physician.
   - Every doctor has at least one patient.

7. **Pharmacy Drug Sales:**  
   - Each pharmacy sells several drugs (at least 10) and has a price for each drug.
   - A drug can be sold at several pharmacies, and the price may vary between pharmacies.

8. **Prescriptions:**  
   - Doctors prescribe drugs for patients.
   - A doctor can prescribe one or more drugs for several patients.
   - A patient can get prescriptions from several doctors.
   - Each prescription has a date and quantity for each drug prescribed.
   - If a doctor gives more than one prescription to a single patient, only the latest one is stored.
   - Doctors give at most one prescription to a given patient on a given date.

9. **Contracts:**  
   - Pharmaceutical companies have contracts with pharmacies.
   - Store contract start date, end date, and contract content.
   - Each pharmacy assigns a supervisor for each contract, and the supervisor can be changed.

This database schema is designed to capture all relevant information for the NOVA pharmacy chain, supporting efficient data management and queries for patients, doctors, drugs, pharmacies, pharmaceutical companies, prescriptions, and contracts.

---

## 📁 Contents

- `NOVA.sql` — Main SQL script containing table definitions, relationships, and sample data.

---

## 🚀 Features

- Well-structured relational database schema
- Table creation with primary and foreign keys
- Example data for testing and demonstration
- Suitable for academic, learning, or demo purposes

---

## 🗂️ How to Use

1. **Clone the repository:**

  git clone https://github.com/AyushChauhan910/NOVA-Database.git
  cd NOVA-Database


2. **Open `NOVA.sql`** in your preferred SQL client or editor.

3. **Run the script** in your SQL environment (such as MySQL, PostgreSQL, Oracle, or any compatible RDBMS).

- The script will create all tables and insert sample data if provided.

---

## 📚 Project Structure

- **Tables:**  
The schema defines multiple tables with appropriate keys and relationships.
- **Relationships:**  
Foreign keys are used to maintain referential integrity between tables.
- **Sample Data:**  
Example entries are included for demonstration and testing.

---

## 📝 Customization

- Modify or extend the schema to fit your own project requirements.
- Add new tables, fields, or constraints as needed.
- Populate with your own data for further experiments.

---

## 🤝 Contributing

Contributions, suggestions, and improvements are welcome!  
Feel free to open issues or submit pull requests.

---

## 📄 License

This project is **not currently licensed**.  
If you wish to make it open-source, please add a LICENSE file (e.g., MIT License) to this repository.

---

*Created by Ayush Chauhan*
