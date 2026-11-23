CREATE TABLE healthcare_staging (
    patient_id TEXT,
    age TEXT,
    gender TEXT,
    admission_type TEXT,
    admission_date TEXT,
    length_of_stay TEXT,
    outcome TEXT,
    diabetes TEXT,
    hypertension TEXT,
    heart_failure TEXT,
    ckd TEXT,
    glucose TEXT,
    creatinine TEXT,
    systolic_bp TEXT,
    zip_code TEXT
);

--Data cleaning project

SELECT COUNT(*)
FROM healthcare_staging

--Find duplicate Patient IDs
SELECT patient_id, COUNT(*)
FROM healthcare_staging
GROUP BY patient_id
HAVING COUNT(*) >1;

-- See full records of the duplicate patient ids
SELECT *
FROM healthcare_staging
WHERE patient_id IN(
SELECT patient_id
FROM healthcare_staging
GROUP BY patient_id
HAVING COUNT(*) >1
)

SELECT DISTINCT gender
FROM healthcare_staging
ORDER BY gender;

-- make every gender value as uppercase with no spaces
SELECT DISTINCT
gender,
UPPER(TRIM(gender)) AS cleaned_gender
FROM healthcare_staging
ORDER BY gender;

-- make every gender value display as "Male" or "Female"
SELECT DISTINCT
CASE
WHEN UPPER(TRIM(gender)) = 'M'
OR UPPER(TRIM(gender)) = 'MALE'
THEN 'Male'
WHEN UPPER(TRIM(gender)) = 'F'
OR UPPER (TRIM(gender)) = 'FEMALE'
THEN 'Female'
ELSE NULL
END AS cleaned_gender
FROM healthcare_staging
ORDER BY cleaned_gender;

-- create backup table with original values
CREATE TABLE healthcare_staging_backup AS
SELECT *
FROM healthcare_staging;

SELECT *
FROM healthcare_staging_backup

-- view current admission types
SELECT DISTINCT admission_type
FROM healthcare_staging
ORDER BY admission_type;

-- view the count of each admission type value
SELECT
admission_type,
COUNT(*)AS record_count
FROM healthcare_staging
GROUP BY admission_type
ORDER BY admission_type;

-- show extra spaces, count character including spaces and show exact record count with each value
SELECT
'[' || admission_type || ']' AS visible_value,
LENGTH(admission_type) AS character_count,
COUNT(*) AS record_count
FROM healthcare_staging
GROUP BY admission_type
ORDER BY admission_type;

-- Make all emergency values as "Emergency" and OPD values as OPD with no spaces
SELECT
admission_type AS original_type,
CASE
WHEN UPPER(TRIM(admission_type)) IN ('ER', 'EMERGENCY')
THEN 'Emergency'
WHEN UPPER(TRIM(admission_type)) = 'OPD'
THEN 'OPD'
ELSE NULL
END AS cleaned_type
FROM healthcare_staging;

-- view all outcomes and count number of instances
SELECT
outcome,
COUNT(*) AS record_count
FROM healthcare_staging
GROUP BY outcome
ORDER BY outcome;

-- MAKE all Dama text as DAMA, all discharged text as Discharged and all expired text as Expired 
SELECT
outcome AS original_outcome,
CASE
WHEN UPPER(TRIM(outcome)) = 'DAMA'
THEN 'DAMA'
WHEN UPPER(TRIM(outcome)) = 'DISCHARGED'
THEN 'Discharged'
WHEN UPPER(TRIM(outcome)) = 'EXPIRED'
THEN 'Expired'
ELSE NULL
END AS cleaned_outcome
FROM healthcare_staging;

-- count the exact number of each "outcome" value
SELECT
CASE
WHEN UPPER(TRIM(outcome)) = 'DAMA'
THEN 'DAMA'
WHEN UPPER(TRIM(outcome)) = 'DISCHARGED'
THEN 'Discharged'
WHEN UPPER(TRIM(outcome)) = 'EXPIRED'
THEN 'Expired'
ELSE NULL
END AS cleaned_outcome,
COUNT(*) AS record_count
FROM healthcare_staging
GROUP BY cleaned_outcome
ORDER BY cleaned_outcome;

-- count missing or null values for each column
SELECT
COUNT(*) FILTER (WHERE age IS NULL OR TRIM(age) = '') AS missing_age,
COUNT(*) FILTER (WHERE gender IS NULL OR TRIM(gender) = '') AS missing_gender,
COUNT(*) FILTER (WHERE admission_type IS NULL OR TRIM(admission_type) = '') AS missing_admission_type,
COUNT(*) FILTER (WHERE outcome IS NULL OR TRIM(outcome) = '') AS missing_outcome
FROM healthcare_staging;

-- display each age and the number of times it appears in our dataset
SELECT
age,
COUNT(*) AS record_count
FROM healthcare_staging
GROUP BY age
ORDER BY age;

-- display the count for Null, Unknown, Empty and N/A values
SELECT
UPPER(TRIM(age)) AS age_value,
COUNT(*) AS record_count
FROM healthcare_staging
WHERE age IS NULL
OR TRIM(age) = ''
OR UPPER(TRIM(age)) IN ('EMPTY', 'N/A', 'UNKNOWN')
GROUP BY UPPER(TRIM(age))
ORDER BY age_value;

-- Have all missing age values display as null
SELECT
age AS original_age,
CASE
WHEN age IS NULL THEN NULL
WHEN TRIM(age) = '' THEN NULL
WHEN UPPER(TRIM(age)) IN ('EMPTY', 'N/A', 'UNKNOWN')
THEN NULL
ELSE TRIM(age)
END AS cleaned_age
FROM healthcare_staging;

-- Noticed there is a patient with an age of 200 years old, check the patients records and see if there is another patient entered with an age of 100 years or older
SELECT *
FROM healthcare_staging
WHERE 
CASE
WHEN TRIM(age) ~ '^[0-9]+$'
THEN TRIM(age)::INTEGER > 100
ELSE FALSE
END
ORDER BY age;

SELECT
age,
*
FROM healthcare_staging
WHERE TRIM(age) = '200';

-- change the age from 200 to null
SELECT
age AS original_age,
CASE
WHEN TRIM(age) = '200' THEN NULL
ELSE age
END AS cleaned_age
FROM healthcare_staging
WHERE TRIM(age) = '200';

-- make all unknowns, n/a, empty and age 200 all into one value as null while keeping other age values the same
SELECT
age AS original_age,
CASE
WHEN age is NULL THEN NULL
WHEN TRIM(age) = '' THEN NULL
WHEN UPPER(TRIM(age)) IN ('EMPTY', 'N/A', 'UNKNOWN') THEN NULL
WHEN TRIM(age)= '200' THEN NULL
ELSE TRIM(age)
END AS cleaned_age
FROM healthcare_staging;

-- Count the total number of records, number of null values and number of values with an age 
SELECT
COUNT(*) AS total_records,
COUNT(*) FILTER (
WHERE cleaned_age IS NULL
) AS missing_ages,

COUNT(*) FILTER (
WHERE cleaned_age ~ '^[0-9]+$'
) AS valid_numeric_ages
FROM (
SELECT
CASE
WHEN age IS NULL THEN NULL
WHEN TRIM(age) = '' THEN NULL
WHEN UPPER(TRIM(age)) IN ('EMPTY', 'N/A', 'UNKNOWN') THEN NULL
WHEN TRIM(age) = '200' THEN NULL
ELSE TRIM(age)
END AS cleaned_age
FROM healthcare_staging
) AS cleaned;

-- see all columns in our table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'healthcare_staging'
ORDER BY ordinal_position;

-- view all the admission dates in our table
SELECT
admission_date,
COUNT(*) AS record_count
FROM healthcare_staging
GROUP BY admission_date
ORDER BY admission_date;

-- view the data related to the "bad_date" value
SELECT*
FROM healthcare_staging
WHERE LOWER(TRIM(admission_date)) = 'bad_date';

-- change date value from bad date to null
SELECT
admission_date AS original_date,
CASE
WHEN LOWER(TRIM(admission_date)) = 'bad_date'
THEN NULL
ELSE TRIM(admission_date)
END AS cleaned_date
FROM healthcare_staging
WHERE LOWER(TRIM(admission_date)) = 'bad_date';

-- view and count the different dates in our table
SELECT
admission_date,
COUNT(*) AS record_count
FROM healthcare_staging
WHERE admission_date LIKE '%/%'
OR admission_date LIKE '%-%'
GROUP BY admission_date
ORDER BY admission_date;
