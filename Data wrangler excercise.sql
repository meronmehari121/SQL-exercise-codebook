/**
Create sample tables to work with **/

/** Baseline **/

create table Baseline
(pt_id int, 
fname varchar(50),
sname varchar (50),
sex int,
dob date ,
rec_date date,
wd_stat int,
wd_date date
)
----------------------------------------------------------------------------------------
/** inpatient_main **/

create table inpatient_main
(pt_id int, 
record_id int,
admidate date,
disdate date,
batch int
)
----------------------------------------------------------------------------------------
/**inpatient_diag **/

create table inpatient_diag
(record_id int,
arr_index int,
"level" int,
diag_icd10 varchar(50)
)
----------------------------------------------------------------------------------------
/** Insert sample values into 
Baseline table **/

Insert into Baseline (pt_id, fname, sname, sex, dob, rec_date, wd_stat, wd_date)
values
    (113573147, 'Joe', 'Bloggs', 1, '1955-11-12', '2007-07-11', 0, NULL),
    (168994422, 'Sue', 'Doe', 0, '1961-01-03', '2006-05-31', 1, '2014-12-12'),
    (181222333, 'Miriam', 'Moore', 0, '1939-04-02', '2010-08-01', 0, NULL);
----------------------------------------------------------------------------------------
/** Insert sample values into 
inpatient_main table **/

Insert into inpatient_main (pt_id , record_id , admidate, disdate, batch)
values
(113573147, 5345723,'1999-02-13' ,'1999-02-19' , 100234),
(113573147, 5482241, '2013-04-22' ,'2013-04-22' , 100457),
(181222333, 3526322, '2019-01-18' ,'2019-02-11' , 100666);
----------------------------------------------------------------------------------------
/** Insert sample values into 
inpatient_diag table **/

Insert into inpatient_diag (record_id , arr_index , level, diag_icd10)
values
(5345723, 0,1 , 'I615'),
(5345723, 1,2 , 'K712'),
(5482241, 0,1 , 'B509'),
(3526322, 0,1 , 'K41'),
(3526322, 1,2 , 'D751'),
(3526322, 2,2 , 'K41.3');
----------------------------------------------------------------------------------------
/** Questions and answers to the Excercise **/
----------------------------------------------------------------------------------------
/** Question # (1)
(a) List the pt_id & surname of all participants, in alphabetical order by surname.
(b) As (a) but only for participants who have not withdrawn from the study. **/-- Solution for  a) select pt_id, snamefrom Baselineorder by sname-- Solution for b)select pt_id, sname,wd_statfrom Baselinewhere wd_stat = 0order by sname;----------------------------------------------------------------------------------------/** Question # (2)
(a) Find the date of birth of the oldest participant(s).
(b) Find the numbers of unwithdrawn male and female participants in the baseline table. **/-- Solution for  a) select MIN(dob) as oldest_dob
from Baseline;-- Solution for b)select  case
        when sex = 0 then 'Female'
        when sex = 1 then 'Male'
    end as Sex
	, COUNT(*) as CountofUnwithdrawnParticipants
from Baseline 
where wd_stat = 0
group by sex;

----------------------------------------------------------------------------------------/** Question # (3)
(a) Find how many unwithdrawn participants do not have any inpatient admissions.
(b) Find how many unwithdrawn participants have not had any inpatient admissions since the start of 2018.**/-- Solution for  a) -- step 1: join Baseline and Inpatient tables select *
from Baseline
LEFT JOIN inpatient_main
on Baseline.pt_id = inpatient_main.pt_id;-- step 2: count wd_stat values by non null values of pt_idselect count(*) as  EmptyInpatientDatafrom Baselineleft join inpatient_mainon Baseline.pt_id = inpatient_main.pt_id where Baseline.wd_stat = 0 and wd_date is not null;-- Solution for  b)-- step 1: join Baseline and Inpatient tables since 2018select *from Baselineleft join (
    select *
    from inpatient_main
    where admidate >= '2018-01-01'
) as inpatient_since_2018on Baseline.pt_id = inpatient_since_2018.pt_id ;-- step 2: count wd_stat values by non null values of pt_idselect count(*) as  EmptyInpatientDataSince2018from Baselineleft join (
    select *
    from inpatient_main
    where admidate >= '2018-01-01'
) as inpatient_since_2018on Baseline.pt_id = inpatient_since_2018.pt_id where Baseline.wd_stat = 0 and inpatient_since_2018.pt_id is  null;----------------------------------------------------------------------------------------/** Question # (4)
(a) Find the earliest and latest admission dates for all records contained in 
any of the batches 100234,  100457,    100666 in the inpatient_main table.

(b) Find the number of distinct participants with an inpatient record with ICD-10 code K41.3 as the primary diagnosis.

(c) For each of the individual ICD-10 codes that start K41, find the number of distinct participants having an inpatient record containing that diagnosis code as either a primary or secondary diagnosis.**/-- Solution for  a) select *from inpatient_main ;select 
    min(admidate) as EarliestAdmissionDate,
    max(admidate) as LatestAdmissionDate
from inpatient_main
where batch IN (100234, 100457, 100666);-- Solution for  b)select *from inpatient_diag ;select 
count(distinct record_id) as CountOfDistinctParticipants
from inpatient_diag
where diag_icd10 = 'K41.3';
-- Solution for c)select
    count(distinct record_id) as CountOfDistinctParticipants
from inpatient_diag
where diag_icd10 LIKE 'K41%'
group by level;----------------------------------------------------------------------------------------/** Question # (5)
The participant with pt_id = 113573147 has withdrawn from the study on  02/04/2021.
(a) Update the baseline table accordingly.
(b) Remove all records from the inpatient_main and inpatient_diag tables that pertain to this participant.
**/-- Solution for  a) update Baseline
set wd_stat = 1, wd_date = '2021-02-04'
where pt_id = 113573147;

-- Solution for  b)
delete from inpatient_main
where pt_id = 113573147;


delete from inpatient_diag
where record_id IN (select record_id from inpatient_main where pt_id = 113573147);

----------------------------------------------------------------------------------------/** Question # (6)
Insert rows into the inpatient_main & inpatient_diag tables that record the following hospital admission:
pt_id = 122334455
record_id = 6714354
admission_date = 23/01/2021
discharge_date = 25/01/2021
record_batch = 100731
Primary diagnosis code: D61.3
Secondary diagnoses codes: D59.5, F32.2 (in that order)**/-- Solution select *from inpatient_main ;insert into inpatient_main (pt_id, record_id, admidate, disdate, batch)
values (122334455, 6714354, '2021-01-23', '2021-01-25', 100731);


select *from inpatient_diag ;
insert into inpatient_diag (record_id, arr_index, level, diag_icd10)
values (6714354, 0, 1, 'D61.3');


insert into inpatient_diag (record_id, arr_index, level, diag_icd10)
values (6714354, 2, 2, 'D59.5'),
       (6714354, 2, 2, 'F32.2');

----------------------------------------------------------------------------------------
                                     -- END --
----------------------------------------------------------------------------------------
