USE [HEALTH CARE WORKFORCE]

--Tocheck and validate all tables in the database
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY
    TABLE_SCHEMA,
    TABLE_NAME,
    ORDINAL_POSITION;

--TO check for duplicates
SELECT
employee_key,
COUNT(*) AS workforce_rows
FROM fact_workforce
GROUP BY employee_key
HAVING COUNT(*) > 1
ORDER BY workforce_rows DESC;

--TO check for Missing Values and Unique rows
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT employee_key) AS unique_employees,
    SUM(CASE WHEN employee_key IS NULL
        THEN 1 ELSE 0 END) AS missing_employee_key,
    SUM(CASE WHEN date_of_birth IS NULL
        THEN 1 ELSE 0 END) AS missing_dob,
    SUM(CASE WHEN gender IS NULL
        THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN ethnic_category IS NULL
        THEN 1 ELSE 0 END) AS missing_ethnicity
FROM dim_employee;

--To validate if there are missing values in employee table anf fact_workforce table
WITH MissingValues AS (
SELECT
        'dim_employee' AS table_name,
        COUNT(*) AS total_records,
        SUM(CASE WHEN employee_key IS NULL
            THEN 1 ELSE 0 END) AS missing_employee_key,
        SUM(CASE WHEN date_of_birth IS NULL
            THEN 1 ELSE 0 END) AS missing_dob,
        SUM(CASE WHEN gender IS NULL
            THEN 1 ELSE 0 END) AS missing_gender,
        SUM(CASE WHEN ethnic_category IS NULL
            THEN 1 ELSE 0 END) AS missing_ethnicity
FROM dim_employee
UNION ALL
SELECT
        'fact_workforce' AS table_name,
        COUNT(*) AS total_records,
        SUM(CASE WHEN employee_key IS NULL
            THEN 1 ELSE 0 END),
        SUM(CASE WHEN department_key IS NULL
            THEN 1 ELSE 0 END),
        SUM(CASE WHEN org_key IS NULL
            THEN 1 ELSE 0 END),
        SUM(CASE WHEN employment_status IS NULL
            THEN 1 ELSE 0 END)
FROM fact_workforce
)
SELECT *
FROM MissingValues;

--No of Absence Event and Total Days Lost by Department (Identify departments with the highest number of lost working days and Absece event)
SELECT
d.department,
COUNT(a.department_key) AS Nr_Of_Absecnce,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_department d
ON a.department_key = d.department_key
GROUP BY d.department
ORDER BY  Nr_Of_Absecnce Desc

--No of Absence Event and Total Days Lost by Staff Group (Find whether nurses, doctors, admin staff, etc. have different absence patterns.)
SELECT
jr.staff_group,
COUNT(*) AS Nr_Of_Absecnce,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_job_role jr
ON a.job_role_key = jr.job_role_key
GROUP BY jr.staff_group
ORDER BY  Nr_Of_Absecnce Desc

-- --No of Absence Event and Total Days Lost by Organisation (To find the Location/ Trust that has the highest numberod 
SELECT
o.organisation_name,
COUNT(*) AS Nr_Of_Absecnce,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_organisation o
ON a.org_key = o.org_key
GROUP BY o.organisation_name
ORDER BY  Nr_Of_Absecnce Desc

--Top Absence Reasons (Identify the largest causes of absence.)
SELECT 
r.absence_category,
COUNT(*) AS Nr_Of_Absecnce,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_absence_reason r
ON a.absence_reason_key = r.absence_reason_key
WHERE a.financial_year = '2024/25'
GROUP BY r.absence_category
ORDER BY  Nr_Of_Absecnce Desc

-- Diversity Analysis (Workforce diversity and representation.)
--By Gender
SELECT
e.gender,
COUNT(*) AS Nr_employees
FROM dim_employee e
GROUP BY e.gender

--Employee Headcount by Trust
SELECT
Jr.staff_group,
e.gender,
COUNT(*) AS Nr_of_employees
FROM fact_workforce w
JOIN dim_employee e
ON w.employee_key = e.employee_key
JOIN dim_job_role jr
ON w.job_role_key =jr.job_role_key
GROUP BY Jr.staff_group, e.gender
ORDER BY Jr.staff_group,Nr_of_employees DESC

-- BY Nationality
SELECT
ethnic_category,
COUNT(*) AS Nr_Of_Employees
FROM dim_employee
GROUP BY ethnic_category
ORDER BY Nr_Of_Employees DESC

-- BY Ethnicity and Trust
SELECT
e.ethnic_category,
j.Staff_group,
COUNT(*) AS Nr_Of_Employees
FROM dim_employee e
LEFT JOIN fact_workforce w
ON e.employee_key = w.employee_key
LEFT JOIN dim_job_role j
ON j.job_role_key = w.job_role_key
GROUP BY e.ethnic_category,j.Staff_group
ORDER BY e.ethnic_category, Nr_Of_Employees DESC


--Retirement Planning Analysis/Age Distribution
WITH employee_ages AS (
SELECT
employee_key,
DATEDIFF(YEAR,date_of_birth,GETDATE()) AS age 
FROM dim_employee),
Age_group AS (
SELECT 
		CASE
			WHEN age < 35 THEN 'Under 35'
            WHEN age < 45 THEN '35-44'
            WHEN age < 55 THEN '45-54'
            WHEN age < 60 THEN '55-59'
            ELSE '60+'
			END AS age_band
		FROM employee_ages)
SELECT
age_band,
COUNT(*) AS employees
FROM age_group
GROUP BY age_band
ORDER BY
    CASE age_band
        WHEN 'Under 35' THEN 1
        WHEN '35-44' THEN 2
        WHEN '45-54' THEN 3
        WHEN '55-59' THEN 4
        ELSE 5
    END;

--Retirement Planning Analysis/Age Distribution BY ORGANISATION
WITH employee_ages AS (
SELECT
e.employee_key,
o.organisation_name,
DATEDIFF(YEAR,date_of_birth,GETDATE()) AS age 
FROM dim_employee e
JOIN fact_workforce w
ON e.employee_key = w.employee_key
JOIN dim_organisation o
ON w.org_key = o.org_key),
Age_group AS (
SELECT 
organisation_name,
		CASE
			WHEN age < 35 THEN 'Under 35'
            WHEN age < 45 THEN '35-44'
            WHEN age < 55 THEN '45-54'
            WHEN age < 60 THEN '55-59'
            ELSE '60+'
			END AS age_band
		FROM employee_ages)
SELECT
organisation_name,
age_band,
COUNT(*) AS employees
FROM age_group
GROUP BY organisation_name,age_band
ORDER BY organisation_name,
    CASE age_band
        WHEN 'Under 35' THEN 1
        WHEN '35-44' THEN 2
        WHEN '45-54' THEN 3
        WHEN '55-59' THEN 4
        ELSE 5
    END;

--Identify Chronic Absentees
SELECT 
TOP 10
e.employee_id,
CONCAT(e.first_name,' ', e.last_name) AS Full_Name,
COUNT(DISTINCT a.absence_id) AS number_of_absences,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
JOIN dim_employee e
ON a.employee_key = e.employee_key
JOIN dim_absence_reason r
ON a.absence_reason_key = r.absence_reason_key
WHERE a.financial_year = '2024/25'
    AND r.absence_category = 'Sickness'
GROUP BY e.employee_id,e.first_name,e.last_name
ORDER BY total_days_lost DESC;

--Attrition Rate
WITH Headcount AS (
SELECT
snapshot_date,
COUNT(DISTINCT employee_key) AS total_employees
FROM fact_workforce_history
WHERE snapshot_date IN ('2024-03-31', '2025-03-31')
      AND active_flag = 1
GROUP BY snapshot_date),

AverageHeadcount AS (
SELECT
AVG(total_employees) AS avg_headcount
FROM Headcount)

SELECT
COUNT(DISTINCT e.employee_key) AS total_leavers,
ROUND(MAX(h.avg_headcount), 2) AS average_headcount,
ROUND(COUNT(DISTINCT e.employee_key) * 100.0 /NULLIF(MAX(h.avg_headcount), 0),2) AS attrition_rate_pct
FROM dim_employee e
JOIN AverageHeadcount h
    ON 1 = 1
WHERE e.resignation_date >= '2024-04-01'
AND e.resignation_date < '2025-04-01';

--Attrition Rate by Organisation
WITH Attrition AS (
SELECT
o.organisation_name,
o.organisation_code,
COUNT(DISTINCT CASE
				WHEN w.snapshot_date = '2024-03-31'
                 AND w.active_flag = 1
				THEN w.employee_key
				END) AS opening_headcount,
COUNT(DISTINCT CASE
				WHEN w.snapshot_date = '2025-03-31'
                 AND w.active_flag = 1
				THEN w.employee_key
				END) AS closing_headcount,
COUNT(DISTINCT CASE
				WHEN w.snapshot_date = '2025-03-31'
                 AND e.resignation_date >= '2024-04-01'
                 AND e.resignation_date < '2025-04-01'
				THEN w.employee_key
				END) AS total_leavers
FROM fact_workforce_history w
JOIN dim_employee e
ON w.employee_key = e.employee_key
JOIN dim_organisation o
ON w.org_key = o.org_key
WHERE w.snapshot_date IN ('2024-03-31', '2025-03-31')
GROUP BY o.organisation_code,o.organisation_name)

SELECT
organisation_name,
total_leavers,
(opening_headcount + closing_headcount) / 2 AS average_headcount,
ROUND(total_leavers*100/NULLIF((opening_headcount + closing_headcount)/2.0,0), 2) AS attrition_rate_pct
FROM Attrition
ORDER BY attrition_rate_pct DESC;

--Monthly Sickness Trend Analysis and Associated Days lost
SELECT
    YEAR(a.start_date) AS year,
    MONTH(a.start_date) AS month_number,
    DATENAME(MONTH, a.start_date) AS month_name,
    COUNT(DISTINCT a.absence_id) AS total_absences,
    SUM(a.working_days_lost) AS total_days_lost,
    ROUND(SUM(a.wte_days_lost), 2) AS total_wte_days_lost
FROM fact_absence a
JOIN dim_absence_reason r
ON a.absence_reason_key = r.absence_reason_key
WHERE a.start_date >= '2024-04-01'
  AND a.start_date < '2025-04-01'
  AND r.absence_category = 'sickness'
GROUP BY
    YEAR(start_date),
    MONTH(start_date),
    DATENAME(MONTH, start_date)
ORDER BY year, month_number;

--Absence Rate By Organisation
WITH Absence AS (
SELECT
org_key,
SUM(wte_days_lost) AS total_days_lost
FROM fact_absence
WHERE financial_year = '2024/25'
GROUP BY org_key),
Workforce AS (
SELECT
org_key,
SUM(fte) AS total_fte
FROM fact_workforce_history
WHERE snapshot_date = '2025-03-31'
GROUP BY org_key)
SELECT
o.organisation_name,
SUM(a.total_days_lost) AS total_days_lost,
SUM(w.total_fte) AS total_fte,
ROUND(SUM(a.total_days_lost) * 100.0 /NULLIF(SUM(w.total_fte) * 260, 0),2) AS absence_rate_pct
FROM dim_organisation o
JOIN Absence a
ON o.org_key = a.org_key
JOIN Workforce w
ON o.org_key = w.org_key
GROUP BY o.organisation_name
ORDER BY absence_rate_pct DESC;


--Overtime Rate By Organisation
SELECT
o.organisation_name,
ROUND(SUM(w.overtime_hours_month), 2) AS total_overtime_hours,
ROUND(SUM(w.contracted_hours_month), 2) AS total_contracted_hours,
ROUND(SUM(w.overtime_hours_month) * 100.0 /NULLIF(SUM(w.contracted_hours_month), 0),2) AS overtime_rate
FROM fact_workforce w
JOIN dim_organisation o
ON w.org_key = o.org_key
WHERE w.employment_status = 'Active'
GROUP BY o.organisation_code,o.organisation_name
ORDER BY overtime_rate DESC;

--TOP 10 Overtime Rate By Department
SELECT
TOP 10
d.department,
ROUND(SUM(w.overtime_hours_month), 2) AS total_overtime_hours,
ROUND(SUM(w.contracted_hours_month), 2) AS total_contracted_hours,
ROUND(SUM(w.overtime_hours_month) * 100.0 /NULLIF(SUM(w.contracted_hours_month), 0),2) AS overtime_rate
FROM fact_workforce w
JOIN dim_department d
ON w.department_key = d.department_key
WHERE w.employment_status = 'Active'
GROUP BY d.department
ORDER BY overtime_rate DESC;

--Ranking Departments by Overime Rtae within Each Organisation/Trust
WITH DepartmentOvertime AS (
SELECT
o.organisation_name,
o.organisation_code,
d.department,
SUM(w.overtime_hours_month) AS overtime_hours,
SUM(w.contracted_hours_month) AS contracted_hours,
ROUND(SUM(w.overtime_hours_month) * 100.0 /NULLIF(SUM(w.contracted_hours_month), 0),2) AS overtime_rate_pct
FROM fact_workforce w
JOIN dim_organisation o
ON w.org_key = o.org_key
JOIN dim_department d
ON w.department_key = d.department_key
WHERE w.employment_status = 'Active'
GROUP BY o.organisation_code, o.organisation_name,d.department)

SELECT
organisation_name,
department,
overtime_hours,
contracted_hours,
overtime_rate_pct,
RANK() OVER (PARTITION BY organisation_code ORDER BY overtime_rate_pct DESC) AS overtime_rank
FROM DepartmentOvertime
ORDER BY organisation_name, overtime_rank;




	
