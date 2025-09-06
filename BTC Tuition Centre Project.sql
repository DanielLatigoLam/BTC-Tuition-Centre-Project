USE BTCProject
SELECT * INTO btcwip --This command allows you to copy all of the data from the btcdata table into another table entitled btcwip
FROM [dbo].[btcdata_ORG] --This is btc work in progress as new table name

select * from btcdata_ORG --original data
select * from btcwip --duplicated data
--1.Understanding Dataset
--Start_Date - Date which student started at tuition centre
--Start_Day - Day which student started at tuition centre
--Start_Time - start time of tuition class
--End_time - end time of tuition class
--Program - Tuition Program in which student is on
--Parent_Fname - Students Parent First Name
--Parent_Lname - Students Parent Last Name
--Fees - Tuition Fees

--2.Cleaning Data Process 
select * from btcwip
where start_day not in ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')

begin tran
UPDATE btcwip
set Start_Day =
CASE
	WHEN Start_Day Like 'Mon%' THEN 'Monday'
	WHEN Start_Day Like 'Tue%' THEN 'Tuesday'
	WHEN Start_Day Like 'Wed%' THEN 'Wednesday'
	WHEN Start_Day Like 'Thur%' THEN 'Thursday'
	WHEN Start_Day Like 'Frid%' THEN 'Friday'
	WHEN Start_Day Like 'Sa%' THEN 'Saturday'
	WHEN Start_Day Like 'Sun%' THEN 'Sunday'
END
from
btcwip

commit tran

rollback tran

select * from btcwip

--The date associated with Sunday on the dataset is a Saturday after confirmation from calendar

begin tran
update btcwip
set Start_Day = 'Saturday' where Start_Day = 'Sunday'
commit tran
rollback tran
select * from btcwip

--Start Day now cleaned in appropriate format.

--3.Cleaning data process (with Program)

select distinct(program) from btcwip

begin tran
UPDATE btcwip
set Program =
CASE
	WHEN Program Like 'Gram%' THEN '11 Plus'
	WHEN Program Like 'AQ%' THEN 'GCSE'
	WHEN Program Like 'Ed%' THEN 'GCSE' 
	ELSE Program
END
from
btcwip

commit tran

rollback tran

select * from btcwip
where Program not in ('11 Plus', 'GCSE', 'Year 6', 'Year 7', 'Year 8', 'Year 9')

--Change the start_time and end_time format to remove milliseconds

ALTER TABLE btcwip
ALTER COLUMN start_time TIME(0)

ALTER TABLE btcwip
ALTER COLUMN end_time TIME(0)

----------------Check for duplicated records----------------
select count(student_name), student_name
from btcwip
group by student_name
having count(student_name) > 1

select * from btcwip
order by Student_Name

WITH cte AS (
select *,
ROW_NUMBER() OVER(
PARTITION BY Student_Name
ORDER BY Student_Name
) AS RN
FROM btcwip
)
select * from cte
where RN > 1;

-------To delete the duplicated records
WITH CTE AS (
select *,
ROW_NUMBER() OVER (
PARTITION BY Student_Name
ORDER BY Student_Name, (SELECT NULL)
) AS RN
FROM btcwip
)
DELETE FROM CTE
WHERE RN>1;

select * from btcwip

--begin tran
--ALTER TABLE btcwip
--Drop Column ParentID

--commit tran
--rollback tran

--1. Create a new table with stid as Identity(1000,1)
--Creating a main register with full cleaned system where students details and parents details would be.

CREATE TABLE main_register (
stid INT IDENTITY(1000,1) PRIMARY KEY,
Student_Name NVARCHAR(100),
Start_Date Date,
Start_Day NVARCHAR(20),
Start_Time TIME(0),
End_Time TIME(0),
Program NVARCHAR(50),
[Parent_Fname] NVARCHAR(100),
[Parent_Lname] NVARCHAR(100),
[Fees] decimal
)

--2. Insert rows into the new table, ordered by Start_Date (This allows me to insert specific columns into main register and selecting those columns from btcwip)
INSERT INTO main_register (Student_Name, 
Start_Date, Start_Day, Start_Time, 
End_Time, Program, [Parent_Fname], [Parent_Lname], 
[Fees])
SELECT Student_Name, Start_Date, Start_Day, Start_Time, End_Time, Program, [Parent_Fname], [Parent_Lname], [Fees]
from btcwip
ORDER BY Start_Date

select * from main_register

---------Create stdattend from Main_register-------
--This is creating a fact table highlighting attendance of students each day. The main register only highlights the start day they attend. The tuition centre want you to create an attendance register. The students have one day they are designated to attend.
select [stid], [Student_Name], [Start_Date], [Start_Day], [Start_Time], [End_Time], [Program] into stdattend
from main_register

select * from stdattend
where Start_Date <= '2024-09-09' and Start_Day = 'Monday'
order by stid, Student_Name, Start_Date

--Based on records viewed, Insert record for first update
Begin tran
Insert into stdattend values
('Claire Gute', '2024-09-09', 'Monday', '17:00:00', '18:00:00', '11 Plus'),
('Emily Burns', '2024-09-09', 'Monday', '19:00:00', '20:00:00', 'Year 9')

select * from stdattend
where Start_Date <= '2024-09-09' and Start_Day = 'Monday'
order by stid, Student_Name, Start_Date
commit tran
rollback tran

--Removing increment of student id--

--Create a new column stdid2
alter table stdattend
add stdid2 int default 1

--Transfer the value in stdid to stdid2
update stdattend
set stdid2 = stid

--Drop the Primary Key Feature and Column stdid
alter table stdattend
drop column stid

--Rename stdid2 to stdid
EXEC sp_rename 'stdattend.stdid2', 'stid', 'COLUMN'

select * from stdattend

--Finally, now update stdrecord for '2024-09-09'

--Insert record for first update
Begin tran
Insert into stdattend values
('Claire Gute', '2024-09-09', 'Monday', '17:00:00', '18:00:00', '11 Plus', 1000),
('Emily Burns', '2024-09-09', 'Monday', '19:00:00', '20:00:00', 'Year 9', 1001)

select * from stdattend
where Start_Date <= '2024-09-09' and Start_Day = 'Monday'
order by stid, Student_Name, Start_Date

commit tran
rollback tran

--Rename start_day to attendance_day
EXEC sp_rename 'stdattend.Attendance_Day', 'Attendance_Date', 'COLUMN'

--Rename start_day to attendance_day
EXEC sp_rename 'stdattend.Start_Day', 'Attendance_Day', 'COLUMN'

select * from stdattend

--Now begin to create Stored Procedure for each weekday, Monday to Saturday.

--For Monday from 2nd September 2024
create or alter procedure monreg @attdate date
AS
insert into stdattend values
('Claire Gute', @attdate, 'Monday', '17:00:00', '18:00:00', '11 Plus', 1000),
('Emily Burns', @attdate, 'Monday', '19:00:00', '20:00:00', 'Year 9', 1001)

DECLARE @attdate Date = '2024-09-30';

BEGIN TRAN;
EXEC monreg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Monday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend

---For Monday continued from 9th September 2024

create or alter procedure monreg @attdate date
AS
insert into stdattend values
('Linda Cazamias', @attdate, 'Monday', '17:00:00', '18:00:00', 'Year 7', 1018),
('Darren Powers', @attdate, 'Monday', '18:00:00', '19:00:00', 'Year 6', 1019)

DECLARE @attdate Date = '2024-09-30';

BEGIN TRAN;
EXEC monreg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Monday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend
order by Attendance_Date

--For Monday continued from 16th September

create or alter procedure monreg @attdate date
AS
insert into stdattend values
('Elpida Rittenbach', @attdate, 'Monday', '16:00:00', '18:00:00', '11 Plus', 1045)

DECLARE @attdate Date = '2024-09-30';

BEGIN TRAN;
EXEC monreg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Monday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend
order by Attendance_Date

----For Tuesday

create or alter procedure tuesreg @attdate date
AS
insert into stdattend values
('Eric Hoffmann', @attdate, 'Tuesday', '19:00:00', '20:00:00', 'Year 9', 1002), --3rd
('Darrin Van Huff', @attdate, 'Tuesday', '17:00:00', '18:00:00', '11 Plus', 1003), --3rd
('Pete Kriz', @attdate, 'Tuesday', '18:00:00', '19:00:00', 'GCSE', 1004), --3rd
('Janet	Molinari', @attdate, 'Tuesday', '18:00:00', '19:00:00', 'Year 6', 1020), --10th
('Ruben Ausman', @attdate, 'Tuesday', '17:00:00', '18:00:00', 'Year 7', 1021), --10th
('Rick Bensley', @attdate, 'Tuesday', '16:00:00', '18:00:00', 'GCSE', 1046) --17th

DECLARE @attdate Date = '2024-09-10'; --Do each declare a step at a time similar to what was done for Monday
DECLARE @attdate Date = '2024-09-17';
DECLARE @attdate Date = '2024-09-24';

BEGIN TRAN;
EXEC tuesreg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Tuesday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend
order by Attendance_Date

---For Wednesday

create or alter procedure wedsreg @attdate date
AS
insert into stdattend values
('Alejandro Grove', @attdate, 'Wednesday', '18:00:00', '19:00:00', 'GCSE', 1005), --4th
('Sean O''Donnell', @attdate, 'Wednesday', '17:00:00', '18:00:00', '11 Plus', 1006), --4th
('Tracy Blumstein', @attdate, 'Wednesday', '19:00:00', '20:00:00', 'Year 9', 1007), --4th
('Erin Smith', @attdate, 'Wednesday', '17:00:00', '18:00:00', 'Year 7', 1022), --11th
('Ted Butterfield', @attdate, 'Wednesday', '18:00:00', '19:00:00', 'Year 6', 1023), --11th
('Gary Zandusky', @attdate, 'Wednesday', '16:00:00', '18:00:00', 'GCSE', 1047) --18th

DECLARE @attdate Date = '2024-09-11'; --Do each declare a step at a time similar to what was done for Monday
DECLARE @attdate Date = '2024-09-18';
DECLARE @attdate Date = '2024-09-25';

BEGIN TRAN;
EXEC wedsreg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Wednesday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend
where Attendance_Day = 'Wednesday'
order by Attendance_Date

--For Thursday

create or alter procedure thursreg @attdate date
AS
insert into stdattend values
('Matt Abelman', @attdate, 'Thursday', '19:00:00', '20:00:00', 'Year 8', 1008), --5th
('Brosina Hoffman', @attdate, 'Thursday', '17:00:00', '18:00:00', '11 Plus', 1009), --5th
('Zuschuss Donatelli', @attdate, 'Thursday', '18:00:00', '19:00:00', 'GCSE', 1010), --5th
('Kunst Miller', @attdate, 'Thursday', '17:00:00', '18:00:00', 'Year 6', 1024), --12th
('Odella Nelson', @attdate, 'Thursday', '18:00:00', '19:00:00', 'Year 7', 1025), --12th
('Lena Cacioppo', @attdate, 'Thursday', '16:00:00', '18:00:00', 'GCSE', 1048) --19th

DECLARE @attdate Date = '2024-09-12'; --Do each declare a step at a time similar to what was done for Monday
DECLARE @attdate Date = '2024-09-19';
DECLARE @attdate Date = '2024-09-26';

BEGIN TRAN;
EXEC thursreg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Thursday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend
where Attendance_Day = 'Thursday'
order by Attendance_Date

--For Friday

create or alter procedure frireg @attdate date
AS
insert into stdattend values
('Ken Black', @attdate, 'Friday', '18:00:00', '19:00:00', 'GCSE', 1011), --6th
('Andrew Allen', @attdate, 'Friday', '17:00:00', '18:00:00', '11 Plus', 1012), --6th
('Gene Hale', @attdate, 'Friday', '19:00:00', '20:00:00', 'Year 8', 1013), --6th
('Patrick O''Donnell', @attdate, 'Friday', '17:00:00', '18:00:00', 'Year 7', 1026), --13th
('Paul Stevenson', @attdate, 'Friday', '18:00:00', '19:00:00', 'Year 6', 1027), --13th
('Janet Martin', @attdate, 'Friday', '16:00:00', '18:00:00', 'GCSE', 1049) --20th

DECLARE @attdate Date = '2024-09-13';--Do each declare a step at a time similar to what was done for Monday
DECLARE @attdate Date = '2024-09-20';
DECLARE @attdate Date = '2024-09-27';

BEGIN TRAN;
EXEC frireg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Friday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend
where Attendance_Day = 'Friday'
order by Attendance_Date

--For Saturday

create or alter procedure satreg @attdate date
AS
insert into stdattend values
('Steve Nguyen', @attdate, 'Saturday', '19:00:00', '20:00:00', 'Year 8', 1014), --7th
('Harold Pawlan', @attdate, 'Saturday', '18:00:00', '19:00:00', 'GCSE', 1015), --7th
('Irene Maddox', @attdate, 'Saturday', '17:00:00', '18:00:00', 'GCSE', 1016), --7th
('Sandra Flanagan', @attdate, 'Saturday', '18:00:00', '19:00:00', 'Year 9', 1017), --7th
('Brendan Sweed', @attdate, 'Saturday', '18:00:00', '19:00:00', 'Year 6', 1028), --14th
('Karen Daniels', @attdate, 'Saturday', '10:00:00', '11:00:00', 'GCSE', 1029), --14th
('Henry MacAllister', @attdate,	'Saturday',	'10:00:00',	'11:00:00',	'11 Plus', 1030), --14th
('Joel Eaton', @attdate, 'Saturday', '11:00:00', '12:00:00', '11 Plus',1031),
('Ken Brennan',	@attdate, 'Saturday', '10:00:00', '12:00:00', '11 Plus', 1032),
('Stewart Carmichael', @attdate, 'Saturday', '13:00:00', '14:00:00', '11 Plus',	1033),
('Duane Noonan', @attdate, 'Saturday', '11:00:00', '12:00:00', 'GCSE', 1034),
('Julie Creighton',	@attdate, 'Saturday', '10:00:00', '12:00:00', 'GCSE', 1035),
('Christopher Schild', @attdate, 'Saturday', '13:00:00', '14:00:00', 'GCSE', 1036),
('Paul Gonzalez', @attdate, 'Saturday',	'14:00:00',	'15:00:00',	'11 Plus', 1037),
('Gary Mitchum', @attdate, 'Saturday', '14:00:00', '15:00:00', '11 Plus', 1038),
('Jim Sink',@attdate, 'Saturday', '14:00:00', '15:00:00', '11 Plus', 1039),
('Karl Braun', @attdate, 'Saturday', '14:00:00', '15:00:00', '11 Plus',	1040),
('Roger Barcio', @attdate, 'Saturday', '14:00:00', '15:00:00', '11 Plus', 1041),
('Parhena Norris', @attdate, 'Saturday', '14:00:00', '15:00:00', '11 Plus',	1042),
('Katherine Ducich', @attdate, 'Saturday', '15:00:00', '16:00:00', '11 Plus', 1043),
('Lena Hernandez',	@attdate, 'Saturday', '17:00:00', '18:00:00', 'Year 7',	1044)

DECLARE @attdate Date = '2024-09-14';--Do each declare a step at a time similar to what was done for Monday
DECLARE @attdate Date = '2024-09-21';
DECLARE @attdate Date = '2024-09-28';

BEGIN TRAN;
EXEC satreg @attdate = @attdate;

SELECT * 
FROM stdattend
WHERE Attendance_Date <= @attdate
AND Attendance_Day = 'Saturday'
ORDER BY stid, Student_Name, Attendance_Date;

Commit Tran
Rollback Tran

select * from stdattend
where Attendance_Day = 'Saturday'
order by Attendance_Date

--Checking whole register data
select * from stdattend
order by Attendance_Date
