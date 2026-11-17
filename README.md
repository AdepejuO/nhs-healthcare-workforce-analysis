# Healthcare Workforce Intelligence & Performance Analysis

**SQL and Power BI** | Workforce planning and performance reporting using the **NHS Data Model and Dictionary** and **NWD (National Workforce Data Set)**.

---

## 1. Business Context & Analytical Objective

A workforce analytics project bringing together workforce records, sickness absence, overtime, and demographic information to support clear, consistent management reporting. The analysis uses the **NHS Data Model and Dictionary** and **National Workforce Data Set (NWD)** as reference points for interpreting staff groups, reporting periods, and workforce measures.

---

## 2. Project at a Glance

| Area | Project Overview |
| :--- | :--- |
| **Business Focus** | Workforce capacity, absence, retention, overtime, and equality monitoring |
| **Tools** | SQL Server (T-SQL), Power BI, DAX measures, and report filters |
| **Data Structure** | Workforce and workforce-history facts; absence events; employee, organisation, department, job role, reason, and date dimensions |
| **Reporting Scope** | Financial-year and year-end comparisons, with focused analysis of **2024/25** |
| **Output** | Three-page interactive Power BI report (*Overview*, *Absence*, and *Diversity*); supporting SQL analysis |

---

## 3. Business Questions

The work was organised around practical questions used in workforce planning and operational performance discussions:

1. How many employees are active, and how is workforce capacity distributed across trusts, departments, and staff groups?
2. How has active headcount changed between reporting periods, and what do resignation and attrition indicators show?
3. Where are absence events and working days lost concentrated, and how do patterns change by month or absence category?
4. Which organisations and departments record the highest overtime hours and overtime relative to contracted hours?
5. What does workforce composition look like by gender, ethnicity, age group, disability status, and qualification?
6. How do salary and age profiles differ across trusts, and where might further workforce-planning questions arise?

---

## 4. Metrics and KPIs

| Metric | Calculation / Use |
| :--- | :--- |
| **Active headcount** | Distinct active employees at a defined reporting date; used for workforce size and breakdowns. |
| **Year-end headcount change** | Difference between comparable year-end headcounts, with period and population held consistent. |
| **Absence events** | Count of distinct recorded absence events; measures occurrence, not sickness absence rate. |
| **Working days / WTE days lost** | Sum of recorded time lost; viewed by organisation, department, reason, and month. |
| **Estimated absence percentage** | `WTE days lost ÷ (closing FTE × 260)`; a planning estimate, not the NHS published sickness-absence rate. |
| **Resignation attrition percentage** | Distinct resignations during 2024/25 divided by average opening and closing active headcount; interpretation depends on complete departure records. |
| **Overtime rate** | `(Total monthly overtime hours ÷ total monthly contracted hours) × 100`; compared across trusts and departments. |
| **Workforce representation** | Employee count or proportion by gender, ethnicity, age group, disability, and qualification. |
| **Average annual salary** | Mean annual salary within the selected group or trust; workforce mix needs consideration when comparing. |

> **Note:** These measures answer different questions—a high absence-event count indicates **frequency**, while days lost reflects **duration or volume**.

---

## 5. NHS Data Definitions & National Information Context

The project uses the **NHS Data Model and Dictionary** and **National Workforce Data Set (NWD)** as reference points when interpreting workforce fields. The NWD provides standard classifications and definitions for NHS workforce information, including job roles and occupation codes, supporting consistency between operational systems (such as the Electronic Staff Record, ESR) and national collections.

| NHS Information Concept | Use Within This Analysis |
| :--- | :--- |
| **Organisations & organisational codes** | Group workforce and absence measures at trust/organisation level; retain codes where available for reliable grouping. |
| **Staff groups & roles** | Compare headcount and absence across consistent workforce categories rather than free-text job labels. |
| **Headcount & Full-Time Equivalent (FTE)** | Distinguish numbers of people from capacity equivalents; document the reporting-date basis. |
| **Absence events & reasons** | Separate absence types, event frequency, working days, and WTE days lost before defining indicators. |
| **Reporting periods** | Use 2024/25 financial-year boundaries and named year-end snapshots for comparable reporting. |
| **Equality & workforce characteristics** | Present demographic distributions consistently while protecting employee privacy. |

---

## 6. Data Preparation & SQL Analysis

The SQL script is organised around a star-schema structure:
* **Fact tables:** `fact_absence` (absence observations), `fact_workforce` (current workforce information), and `fact_workforce_history` (reporting-date comparisons).
* **Dimension tables:** `dim_employee`, `dim_department`, `dim_organisation`, `dim_job_role`, `dim_absence_reason`, and `dim_date`.

### Quality Checks & Preparation
A duplicate-assignment check groups workforce records by `employee_key` and flags employees with more than one workforce row, preventing multiple assignments from inflating headcount. The script also uses `DISTINCT` for absence and employee IDs, explicit financial-year filters, and `NULLIF` to prevent division-by-zero errors.

```sql
SELECT 
    employee_key, 
    COUNT(*) AS workforce_rows
FROM fact_workforce
GROUP BY employee_key
HAVING COUNT(*) > 1;
```

### **Absence and workforce comparisons** 

LEFT JOIN links absence records to department, role, organisation and absence-reason dimensions. COUNT and SUM then show both the number of events and the associated days lost, while GROUP BY and ORDER BY make differences across groups easy to examine. The script also filters sickness absence to 2024/25 and groups events by month to reveal changes over time. 

```sql
SELECT 
    YEAR(a.start_date) AS year, 
    MONTH(a.start_date) AS month_number,
    COUNT(DISTINCT a.absence_id) AS total_absences,
    SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
JOIN dim_absence_reason r 
    ON a.absence_reason_key = r.absence_reason_key
WHERE a.start_date >= '2024-04-01' 
  AND a.start_date < '2025-04-01'
  AND r.absence_category = 'sickness'
GROUP BY YEAR(a.start_date), MONTH(a.start_date);
```

### **Age profile, attrition and overtime** 

Common table expressions (CTEs) organise the age-band and attrition calculations into readable steps. CASE groups ages into Under 35, 35–44, 45–54, 55–59 and 60+. The attrition calculation uses distinct employees and opening/closing workforce snapshots. Overtime analysis uses SUM, NULLIF and RANK() OVER (PARTITION BY organisation_code) to compare and rank departments within trusts. 

```sql
ROUND(
    SUM(w.overtime_hours_month) * 100.0 / 
    NULLIF(SUM(w.contracted_hours_month), 0), 
    2
) AS overtime_rate
```

## **7 | Power BI dashboard and reporting design** 

The report uses three linked pages, with navigation and slicers to move from the overall workforce picture to absence and demographic analysis. DAX measures shown in the report definition include active headcount, overtime hours, overtime percentage, year-end headcount comparisons, sickness days lost, absence events, and demographic proportions. 

|**Page / visual**|**What it shows and why this format was chosen**|
|---|---|
|**Overview — KPI cards**|Active headcount, year-end comparison, overtime measures and related summary<br>figures provide an immediate view of workforce scale and movement.|
|**Overview — line chart**|Active headcount over financial years makes the direction of workforce change easier to<br>see than individual annual totals.|
|**Overview — bar charts**|Employees and overtime hours by department use ranked categorical comparisons;<br>longer labels are easier to read on horizontal bars.|
|**Absence — KPI cards**|Absence events, days lost and the project’s estimated absence percentage separate<br>volume, duration and relative impact.|
|**Absence — monthly line charts**|Absence events and WTE days lost over time highlight peaks, falls and possible seasonal<br>patterns.|
|**Absence — column and bar charts**|Events by financial year, days lost by absence category and department expose<br>differences between groups.|
|**Absence — 100% stacked bars**|Return-to-work interview status by department shows the proportion in each status<br>within each department, not just totals.|
|**Diversity — KPI cards and 100% stacked bars**|Employee shares by gender allow composition to be understood at a glance.|
|**Diversity — column/bar charts**|Age group by trust, disability status, ethnicity, qualifications and average salary by trust<br>support side-by-side comparisons.|
|**Slicers and navigation**|Organisation, financial year, staff group, department, absence type, contract type,<br>gender, pay band and age group make the reports explorable.|



#### **Dashboard Design Overview:** 

1. KPI cards answer “how much?” 

2. Trend lines answer “how has it changed?” 

3. Bar charts answer “which group differs?” 

4. 100% stacked bars answer “what proportion?” 

5. Pages keep related questions together to avoid overcrowding a single view. 

## **8 | How the analysis answered business questions and supports decisions** 

|**Businessquestion**|**What the analysis established**<br>f|**Decision the analysis supports**|
|---|---|---|
|**Where is workforce capacity**<br>**concentrated, and how is it**<br>**changing?**|Active headcount, staff-group and department breakdowns<br>show how the workforce is distributed across<br>organisations. Year-end headcount comparisons provide a<br>view of workforce movement between reporting periods.|Identify areas for workforce-capacity<br>review, investigate headcount changes<br>and inform recruitment or resource-<br>planning discussions.|
|**Which organisations or teams**|Absence events and workingdays lost were analysed by|Focus absence investigations on the|



Healthcare workforce intelligence | Project portfolio 

|**Businessquestion**|**What the analysis established**<br>f|**Decision the analysis supports**|
|---|---|---|
|**experience the greatest**<br>**absence pressure?**|organisation, department, staff group and reason. Monthly<br>sickness trends distinguish the frequency of absence from<br>the volume of working time lost.|teams and periods showing the greatest<br>recorded impact, and assess whether<br>further operational support is needed.|
|**Where is overtime most**<br>**concentrated?**|Overtime hours were compared with contracted hours to<br>calculate overtime percentages by organisation and<br>department. Departments were also ranked within each<br>organisation, allowing like-for-like prioritisation within each<br>trust.|Prioritise reviews of staffing cover,<br>workload and rota arrangements in<br>areas with relatively high overtime<br>reliance.|
||The analysis brings together distinct leaver counts,|Support retention reviews and longer-|
|**What do leaver and workforce**<br>**age patterns indicate?**|headcount snapshots, estimated attrition percentages and<br>age-band distributions. This provides separate views of<br>recorded staff departures and workforce age composition.<br>i  f|term succession planning, while<br>investigating underlying causes before<br>drawing conclusions.|
|**How does workforce**<br>**composition differ across**<br>**groups?**|Gender, ethnicity, disability, qualification and staff-group<br>breakdowns describe workforce representation and show<br>how the mix varies across reporting categories and<br>organisations.|Inform workforce equality monitoring<br>and identify differences that merit<br>further investigation or more detailed<br>analysis.|
|**How do pay and capacity**<br>**profiles vary between**<br>**organisations?**|Average annual salary by trust is presented alongside<br>workforce and demographic measures, enabling<br>comparisons of reported pay levels and workforce<br>composition. These figures are descriptive and do not cover<br>role orgrade mix.|Guide questions about workforce mix<br>and pay distribution, and identify where<br>including the grade mix would be useful<br>before making decisions.|



**Conclusion:** Overall, the analysis provides a consistent way to explore workforce questions using the same underlying reporting model. It supports investigation and management discussion; it does not, on its own, establish the causes of absence, overtime or staff departures. 

## **9 | Data quality assurance and validation tests** 

The SQL script contains schema inspection, completeness and duplicate-record queries. 

|**Test**|**Method and link to the SQL file**|
|---|---|
|**Schema and field metadata**|Used  INFORMATION_SCHEMA.COLUMNS for<br>table names, columns, types and nullability.|
|**Employee table completeness**|Used COUNT(*), COUNT (DISTINCT<br>employee_key) and SUM(CASE WHEN field IS<br>NULL THEN 1 ELSE 0 END) for identifiers, date<br>of birth, gender and ethnicity.|
|**Cross-table missing values**|Used CTE to combine dim_employee and<br>fact_workforce counts with UNION ALL.|
|**Workforce row duplication**|GROUP BY employee_key HAVING COUNT(*) ><br>1 in fact_workforce.|
|**Unique absence events and leavers**|Use COUNT(DISTINCT absence_id) for events<br>and COUNT(DISTINCT employee_key) for<br>leavers.|
|**Reporting period and calculation safety**|Use >= '2024-04-01' AND < '2025-04-01' and<br>NULLIF(denominator,0) for rates.|



#### **Example SQL check included in the project:** 

SELECT employee_key, COUNT(*) AS workforce_rows FROM fact_workforce GROUP BY employee_key HAVING COUNT(*) > 1; 

SELECT COUNT(*) AS total_records, COUNT(DISTINCT employee_key) AS unique_employees, SUM(CASE WHEN employee_key IS NULL THEN 1 ELSE 0 END) AS missing_employee_key, SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS missing_dob, SUM(CASE WHEN gender IS NULL 

Healthcare workforce intelligence | Project portfolio 

THEN 1 ELSE 0 END) AS missing_gender, SUM(CASE WHEN ethnic_category IS NULL THEN 1 ELSE 0 END) AS missing_ethnicity FROM dim_employee; 

## **10 | Skills demonstrated** 

**SQL:** SQL analysis and data preparation • Fact and dimension modelling • Workforce segmentation • CTEs (Common Table Expressions) and SQL window functions • Distinct headcount and event count 

**Power BI:** Power BI report design • KPI definition • Time-series analysis • Workforce segmentation • DAX-based measures •Interactive filtering • NHS workforce terminology and standards • Quality assurance and data interpretation • Insight communication 

## **Reference standards and project materials** 

**Project file** : Health WorkForce 2.0.sql; Health Care 2.1.pbix. 

**NHS National Workforce Data Set (NWD)** : https://standards.nhs.uk/published-standards/national-workforce-data-set 

**NHS sickness absence rates methodology:** <u>https://digital.nhs.uk/data-and-information/publications/statistical/nhs-sicknessabsence-rates/june-2026/methodology</u> 

**NHS Data Model and Dictionary** : https://www.datadictionary.nhs.uk/ 

Healthcare workforce intelligence | Project portfolio 

