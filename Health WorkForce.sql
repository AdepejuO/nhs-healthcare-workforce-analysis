USE [HEALTH CARE WORKFORCE]

--Absence Rate by Department (Identify departments with the highest number of lost working days.
SELECT
d.department,
COUNT(a.department_key) AS Nr_Of_Absecnce,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_department d
ON a.department_key = d.department_key
GROUP BY d.department
ORDER BY  Nr_Of_Absecnce Desc

-- Absence Rate by Staff Group (Find whether nurses, doctors, admin staff, etc. have different absence patterns.)
SELECT
jr.staff_group,
COUNT(*) AS Nr_Of_Absecnce,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_job_role jr
ON a.job_role_key = jr.job_role_key
GROUP BY jr.staff_group
ORDER BY  Nr_Of_Absecnce Desc

-- Absence Rate by Organisation (To find the Location/ Trust that has the highest numberod 
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
r.absence_type,
COUNT(*) AS Nr_Of_Absecnce,
SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_absence_reason r
ON a.absence_reason_key = r.absence_reason_key
GROUP BY r.absence_type
ORDER BY  Nr_Of_Absecnce Desc

-- Diversity Analysis (Workforce diversity and representation.)
--By Gender
SELECT
	e.gender,
    COUNT(*) AS Nr_employees
FROM dim_employee e
GROUP BY e.gender

--OR
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
Nationality,
COUNT(*) AS Nr_Of_Employees
FROM dim_employee
GROUP BY Nationality
ORDER BY Nr_Of_Employees DESC

-- BY Nationality and Staff Group
SELECT
e.Nationality,
j.Staff_group,
COUNT(*) AS Nr_Of_Employees
FROM dim_employee e
LEFT JOIN fact_workforce w
ON e.employee_key = w.employee_key
LEFT JOIN dim_job_role j
ON j.job_role_key = w.job_role_key
GROUP BY Nationality,j.Staff_group
ORDER BY e.Nationality, Nr_Of_Employees DESC


--Retirement Risk Analysis
SELECT 
		age_band,
		COUNT(*) AS nr_of_employees
FROM (
		SELECT
		CASE 
				WHEN DATEDIFF(Year,date_of_birth,GETDATE()) >= '60' THEN 'About to Retire'
				ELSE 'Active'
		END AS age_band
		FROM dim_employee
		) t
GROUP BY age_band

--OR

WITH employee_age AS (
SELECT 
	CASE
		WHEN DATEDIFF(year,date_of_birth,GETDATE()) >=60 THEN 'about to retire'
		ELSE 'active'
		END AS age_band
		FROM dim_employee
		)
SELECT 
age_band,
COUNT (*) AS nr_of_employees
FROM employee_age
GROUP BY age_band

--Retirement Risk BY ORGANISATION

WITH employee_band AS (
SELECT 
o.organisation_name, 
CASE
		WHEN DATEDIFF(year,e.date_of_birth,GETDATE()) >=60 THEN 'about to retire'
		ELSE 'active'
		END AS retire_flag
FROM dim_employee e
LEFT JOIN fact_workforce w
ON e.employee_key = w.employee_key
LEFT JOIN dim_organisation o
ON w.org_key = o.org_key
)
SELECT
organisation_name,
retire_flag,
COUNT(*) AS nr_of_employees
FROM employee_band
GROUP BY organisation_name,retire_flag
ORDER BY retire_flag


WITH employee_band AS (
SELECT 
o.organisation_name, 
CASE
		WHEN DATEDIFF(year,e.date_of_birth,GETDATE()) >=60 THEN 'about to retire'
		ELSE 'active'
		END AS retire_flag
FROM dim_employee e
LEFT JOIN fact_workforce w
ON e.employee_key = w.employee_key
LEFT JOIN dim_organisation o
ON w.org_key = o.org_key
),
employee_count AS (
SELECT
organisation_name,
retire_flag,
COUNT(*) AS nr_of_employees
FROM employee_band
GROUP BY organisation_name,retire_flag
)
SELECT 
organisation_name,
retire_flag,
nr_of_employees,
SUM(nr_of_employees) OVER (PARTITION BY retire_flag ) AS Nr_Employees
FROM employee_count





Identify Chronic Absentees
Absence Seasonality Analysis
Gap Analysis Between Staffing and Demand
Attrition Risk Proxy
Cntract_type_distribution
-Build a Workforce Risk Dashboard in Pure SQL