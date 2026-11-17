```markdown
# Healthcare Workforce Intelligence & Performance Analysis

SQL and Power BI | Workforce planning and performance reporting using the NHS Data Model and Dictionary and NWD (National Workforce Dataset)[cite: 1]

## 1 | Business context and analytical objective

A workforce analytics project bringing together workforce records, sickness absence, overtime and demographic information to support clear, consistent management reporting[cite: 1]. The analysis uses NHS Data Model and Dictionary and National Workforce Data Set (NWD) as reference points for interpreting staff groups, reporting periods and workforce measures[cite: 1].

## 2 | Project at a glance

| Area | Project overview |
| :--- | :--- |
| **Business focus** | Workforce capacity, absence, retention, overtime and equality monitoring[cite: 1] |
| **Tools** | SQL Server (T-SQL), Power BI, DAX measures and report filters[cite: 1] |
| **Data structure** | Workforce and workforce-history facts; absence events; employee, organisation, department, job role, reason and date dimensions[cite: 1] |
| **Reporting scope** | Financial-year and year-end comparisons, with focused analysis of 2024/25[cite: 1] |
| **Output** | Three-page interactive Power BI report: Overview, Absence and Diversity; supporting SQL analysis[cite: 1] |

## 3 | Business questions

The work was organised around practical questions used in workforce planning and operational performance discussions[cite: 1]:

* How many employees are active, and how is workforce capacity distributed across trusts, departments and staff groups?[cite: 1]
* How has active headcount changed between reporting periods, and what do resignation and attrition indicators show?[cite: 1]
* Where are absence events and working days lost concentrated, and how do patterns change by month or absence category?[cite: 1]
* Which organisations and departments record the highest overtime hours and overtime relative to contracted hours?[cite: 1]
* What does workforce composition look like by gender, ethnicity, age group, disability status and qualification?[cite: 1]
* How do salary and age profiles differ across trusts, and where might further workforce-planning questions arise?[cite: 1]

## 4 | Metrics and KPIs

| Metric | Calculation / use |
| :--- | :--- |
| **Active headcount** | Distinct active employees at a defined reporting date; used for workforce size and breakdowns.[cite: 1] |
| **Year-end headcount change** | Difference between comparable year-end headcounts, with period and population held consistent.[cite: 1] |
| **Absence events** | Count of distinct recorded absence events; measures occurrence, not sickness absence rate.[cite: 1] |
| **Working days / WTE days lost** | Sum of recorded time lost; viewed by organisation, department, reason and month.[cite: 1] |
| **Estimated absence percentage** | The project SQL divides WTE days lost by closing FTE × 260; a planning estimate, not the NHS published sickness-absence rate.[cite: 1] |
| **Resignation attrition percentage** | Distinct resignations during 2024/25 divided by average opening and closing active headcount; interpretation depends on complete departure records.[cite: 1] |
| **Overtime rate** | Total monthly overtime hours ÷ total monthly contracted hours × 100; compared across trusts and departments.[cite: 1] |
| **Workforce representation** | Employee count or proportion by gender, ethnicity, age group, disability and qualification.[cite: 1] |
| **Average annual salary** | Mean annual salary within the selected group or trust; workforce mix needs consideration when comparing.[cite: 1] |

These measures answer different questions: a high absence-event count indicates frequency, while days lost reflects duration or volume[cite: 1].

## 5 | NHS data definitions and national information context

The project uses the NHS Data Model and Dictionary and National Workforce Data Set (NWD) as reference points when interpreting workforce fields[cite: 1]. The NWD provides standard classifications and definitions for NHS workforce information, including job roles and occupation codes[cite: 1]. These definitions support consistency between operational workforce systems such as the Electronic Staff Record (ESR) and national workforce information collections[cite: 1].

| NHS information concept | Use within this analysis |
| :--- | :--- |
| **Organisations and organisational codes** | Group workforce and absence measures at trust/organisation level; retain codes where available for reliable grouping.[cite: 1] |
| **Staff groups and roles** | Compare headcount and absence across consistent workforce categories rather than free-text job labels.[cite: 1] |
| **Headcount and full-time equivalent (FTE)** | Distinguish numbers of people from capacity equivalents; document the reporting-date basis.[cite: 1] |
| **Absence events and reasons** | Separate absence types, event frequency, working days and WTE days lost before defining indicators.[cite: 1] |
| **Reporting periods** | Use 2024/25 financial-year boundaries and named year-end snapshots for comparable reporting.[cite: 1] |
| **Equality and workforce characteristics** | Present demographic distributions consistently while protecting employee privacy.[cite: 1] |

## 6 | Data preparation and SQL analysis

The SQL script is organised around fact and dimension tables[cite: 1]. `fact_absence` holds absence observations; `fact_workforce` holds current workforce information; `fact_workforce_history` supports reporting-date comparisons[cite: 1]. Employee, department, organisation, job role, absence reason and date tables provide the categories used in reporting[cite: 1].

### Quality checks and preparation

A duplicate-assignment check groups workforce records by `employee_key` and flags employees with more than one workforce row[cite: 1]. This is important because multiple assignments can inflate headcount if rows are counted as people[cite: 1]. The SQL also uses `DISTINCT` for absence IDs and employee IDs in selected measures, defined financial-year filters, and `NULLIF` to avoid division-by-zero errors[cite: 1].

```sql
SELECT employee_key, COUNT(*) AS workforce_rows
FROM fact_workforce
GROUP BY employee_key
HAVING COUNT(*) > 1;

```

### Absence and workforce comparisons

`LEFT JOIN` links absence records to department, role, organisation and absence-reason dimensions. `COUNT` and `SUM` then show both the number of events and the associated days lost, while `GROUP BY` and `ORDER BY` make differences across groups easy to examine. The script also filters sickness absence to 2024/25 and groups events by month to reveal changes over time.

```sql
SELECT YEAR(a.start_date) AS year, MONTH(a.start_date) AS month_number,
       COUNT(DISTINCT a.absence_id) AS total_absences,
       SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
JOIN dim_absence_reason r ON a.absence_reason_key = r.absence_reason_key
WHERE a.start_date >= '2024-04-01' AND a.start_date < '2025-04-01'
  AND r.absence_category = 'sickness'
GROUP BY YEAR(a.start_date), MONTH(a.start_date);

```

### Age profile, attrition and overtime

Common table expressions (CTEs) organise the age-band and attrition calculations into readable steps. `CASE` groups ages into Under 35, 35–44, 45–54, 55–59 and 60+. The attrition calculation uses distinct employees and opening/closing workforce snapshots. Overtime analysis uses `SUM`, `NULLIF` and `RANK() OVER (PARTITION BY organisation_code)` to compare and rank departments within trusts.

```sql
ROUND(SUM(w.overtime_hours_month) * 100.0 /
      NULLIF(SUM(w.contracted_hours_month), 0), 2) AS overtime_rate

```

The age-band script uses `DATEDIFF(YEAR, date_of_birth, GETDATE())` to produce age categories. For age reporting tied to a specific year, completed age should be calculated at a fixed reference date and adjusted for birthdays not yet reached. Age bands describe workforce distribution; they do not predict individual retirement.

### SQL techniques demonstrated

| Technique | Application |
| --- | --- |
| **INNER / LEFT JOIN** | Combine workforce and absence facts with employee, organisation, department and reason dimensions.

 |
| **COUNT(DISTINCT), COUNT, SUM, AVG** | Count records or people and aggregate days lost, hours and salary-related measures.

 |
| **WHERE and date boundaries** | Focus calculations on 2024/25, sickness absence or specific workforce snapshots.

 |
| **CTEs and CASE** | Structure calculations for age bands and opening/closing headcount.

 |
| **NULLIF, ROUND** | Handle zero denominators and display readable percentage measures.

 |
| **RANK() OVER (PARTITION BY)** | Rank departmental overtime rates separately within each organisation.

 |

## 7 | Power BI dashboard and reporting design

The report uses three linked pages, with navigation and slicers to move from the overall workforce picture to absence and demographic analysis. DAX measures shown in the report definition include active headcount, overtime hours, overtime percentage, year-end headcount comparisons, sickness days lost, absence events, and demographic proportions.

| Page / visual | What it shows and why this format was chosen |
| --- | --- |
| **Overview — KPI cards** | Active headcount, year-end comparison, overtime measures and related summary figures provide an immediate view of workforce scale and movement.

 |
| **Overview — line chart** | Active headcount over financial years makes the direction of workforce change easier to see than individual annual totals.

 |
| **Overview — bar charts** | Employees and overtime hours by department use ranked categorical comparisons; longer labels are easier to read on horizontal bars.

 |
| **Absence — KPI cards** | Absence events, days lost and the project’s estimated absence percentage separate volume, duration and relative impact.

 |
| **Absence — monthly line charts** | Absence events and WTE days lost over time highlight peaks, falls and possible seasonal patterns.

 |
| **Absence — column and bar charts** | Events by financial year, days lost by absence category and department expose differences between groups.

 |
| **Absence — 100% stacked bars** | Return-to-work interview status by department shows the proportion in each status within each department, not just totals.

 |
| **Diversity — KPI cards and 100% stacked bars** | Employee shares by gender allow composition to be understood at a glance.

 |
| **Diversity — column/bar charts** | Age group by trust, disability status, ethnicity, qualifications and average salary by trust support side-by-side comparisons.

 |
| **Slicers and navigation** | Organisation, financial year, staff group, department, absence type, contract type, gender, pay band and age group make the reports explorable.

 |

**Dashboard Design Overview:**

* KPI cards answer “how much?”


* Trend lines answer “how has it changed?”


* Bar charts answer “which group differs?”


* 100% stacked bars answer “what proportion?”


* Pages keep related questions together to avoid overcrowding a single view.



## 8 | How the analysis answered business questions and supports decisions

| Business question | What the analysis established | Decision the analysis supports |
| --- | --- | --- |
| **Where is workforce capacity concentrated, and how is it changing?** | Active headcount, staff-group and department breakdowns show how the workforce is distributed across organisations. Year-end headcount comparisons provide a view of workforce movement between reporting periods.

 | Identify areas for workforce-capacity review, investigate headcount changes and inform recruitment or resource-planning discussions.

 |
| **Which organisations or teams experience the greatest absence pressure?** | Absence events and working days lost were analysed by organisation, department, staff group and reason. Monthly sickness trends distinguish the frequency of absence from the volume of working time lost.

 | Focus absence investigations on the teams and periods showing the greatest recorded impact, and assess whether further operational support is needed.

 |
| **Where is overtime most concentrated?** | Overtime hours were compared with contracted hours to calculate overtime percentages by organisation and department. Departments were also ranked within each organisation, allowing like-for-like prioritisation within each trust.

 | Prioritise reviews of staffing cover, workload and rota arrangements in areas with relatively high overtime reliance.

 |
| **What do leaver and workforce age patterns indicate?** | The analysis brings together distinct leaver counts, headcount snapshots, estimated attrition percentages and age-band distributions. This provides separate views of recorded staff departures and workforce age composition.

 | Support retention reviews and longer-term succession planning, while investigating underlying causes before drawing conclusions.

 |
| **How does workforce composition differ across groups?** | Gender, ethnicity, disability, qualification and staff-group breakdowns describe workforce representation and show how the mix varies across reporting categories and organisations.

 | Inform workforce equality monitoring and identify differences that merit further investigation or more detailed analysis.

 |
| **How do pay and capacity profiles vary between organisations?** | Average annual salary by trust is presented alongside workforce and demographic measures, enabling comparisons of reported pay levels and workforce composition. These figures are descriptive and do not cover role or grade mix.

 | Guide questions about workforce mix and pay distribution, and identify where including the grade mix would be useful before making decisions.

 |

**Conclusion:** Overall, the analysis provides a consistent way to explore workforce questions using the same underlying reporting model. It supports investigation and management discussion; it does not, on its own, establish the causes of absence, overtime or staff departures.

## 9 | Data quality assurance and validation tests

The SQL script contains schema inspection, completeness and duplicate-record queries.

| Test | Method and link to the SQL file |
| --- | --- |
| **Schema and field metadata** | Used `INFORMATION_SCHEMA.COLUMNS` for table names, columns, types and nullability.

 |
| **Employee table completeness** | Used `COUNT(*)`, `COUNT (DISTINCT employee_key)` and `SUM(CASE WHEN field IS NULL THEN 1 ELSE 0 END)` for identifiers, date of birth, gender and ethnicity.

 |
| **Cross-table missing values** | Used CTE to combine `dim_employee` and `fact_workforce` counts with `UNION ALL`.

 |
| **Workforce row duplication** | `GROUP BY employee_key HAVING COUNT(*) > 1` in `fact_workforce`.

 |
| **Unique absence events and leavers** | Use `COUNT(DISTINCT absence_id)` for events and `COUNT(DISTINCT employee_key)` for leavers.

 |
| **Reporting period and calculation safety** | Use `>= '2024-04-01' AND < '2025-04-01'` and `NULLIF(denominator,0)` for rates.

 |

Example SQL check included in the project:

```sql
SELECT employee_key, COUNT(*) AS workforce_rows
FROM fact_workforce
GROUP BY employee_key
HAVING COUNT(*) > 1;

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

```

## 10 | Skills demonstrated

* **SQL:** SQL analysis and data preparation • Fact and dimension modelling • Workforce segmentation • CTEs (Common Table Expressions) and SQL window functions • Distinct headcount and event count


* **Power BI:** Power BI report design • KPI definition • Time-series analysis • Workforce segmentation • DAX-based measures • Interactive filtering • NHS workforce terminology and standards • Quality assurance and data interpretation • Insight communication



### Reference standards and project materials

* **Project file:** `Health WorkForce 2.0.sql`; `Health Care 2.1.pbix`.


* **NHS National Workforce Data Set (NWD):** https://standards.nhs.uk/published-standards/national-workforce-data-set


* **NHS sickness absence rates methodology:** https://digital.nhs.uk/data-and-information/publications/statistical/nhs-sickness-absence-rates/june-2026/methodology


* **NHS Data Model and Dictionary:** https://www.datadictionary.nhs.uk/



```

```
