# BTC-Tuition-Centre-Project

# BTC Tuition Centre - Data Migration and Improvement Plan  

## 📌 Project Overview  
⚠️ **Note:** This is a **fictitious case study project** created to demonstrate SQL Server database design, data migration, and data cleansing skills. The scenario is based on a tuition centre, with challenges and datasets crafted for learning and portfolio purposes.  

BTC Tuition Centre is a UK-based tuition provider for Primary and Secondary school students. Since its launch in 2020, it relied on **Excel spreadsheets** for managing student records, payments, and attendance. As the business grew, Excel created several problems:  

- ❌ **Duplicated names and IDs** leading to confusion and errors.  
- ❌ **Inefficient data management** with no validation or integrity checks.  
- ❌ **No structured attendance tracking system**.  
- ❌ **Limited ability to analyse data** for decision-making.  

This project demonstrates the process of migrating BTC’s data to **SQL Server**, cleansing and structuring it, and preparing for **Power BI integration** to enable future insights.  

---

## 🎯 Key Problems to Address  
- **Duplicated Names** – Multiple students with identical names caused confusion in reporting.  
- **Duplicated Student IDs** – Duplicate IDs created data integrity issues.  
- **Attendance Tracking** – No centralised way to record which students attended on which days.  

---

## 🛠️ Project Objectives  
1. **Data Cleansing** – Standardize student records, resolve duplicate IDs, and remove unnecessary duplicates.  
2. **Database Migration** – Design and implement a **normalized SQL Server database**.  
3. **Attendance System** – Build an SQL-based attendance register linked to students and classes.  
4. **Future BI Readiness** – Structure the database for seamless **Power BI integration**.  

---

## 📂 Deliverables  
- ✅ **Database & Tables** – Normalized database structure for Students and Attendance.  
- ✅ **Data Migration Scripts** – Import data from Excel into SQL Server with cleaning/transformation steps.  
- ✅ **Attendance Register** – SQL solution to log and query daily attendance.    

---

## 🛠️ Tools & Technologies  
- **SQL Server** – Database design & migration.  
- **Excel** – Initial raw dataset (simulated).  
- **SQL (DDL & DML)** – Schema creation, cleansing, queries.  
- **Power BI** *(planned)* – Future data visualisation.  

---

## 🚀 Recommendations (Case Study)  
1. **Data Cleansing** – Standardize and enforce unique student IDs.  
2. **SQL Server Migration** – Replace Excel with a robust, normalized database.  
3. **Attendance Register** – Implement an SQL-driven daily attendance system.   

---

## 📖 Lessons Learned  
- The importance of **data cleansing before migration**.  
- How **normalization reduces redundancy** and enforces integrity.  
- The benefits of **designing databases with BI in mind** for scalability.  

---

✅ This project demonstrates how a real business could benefit from migrating to SQL Server, cleaning data, and preparing for future analytics. 
