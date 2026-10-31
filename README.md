# Healthcare Workforce Intelligence & Performance Analysis
### SQL and Power BI | NHS Workforce Data Standards | Analytical Portfolio Project

A workforce intelligence project examining staffing levels, sickness absence, overtime, and workforce demographics to support operational reporting and workforce planning.

## 📊 Project at a Glance

| Area | Project Summary |
| :--- | :--- |
| **Focus** | Workforce capacity, absence patterns, demographic composition, and resourcing indicators |
| **Technical Tools** | SQL (T-SQL) for querying and aggregations; Power BI for reporting and visual analysis |
| **Analytical Outputs** | Three Power BI report pages: Overview, Absence, and Demographics |
| **NHS Information Context** | NHS Data Model and Dictionary; National Workforce Data Set (NWD); NHS workforce statistics and sickness absence methodology |
| **Analytical Skills** | Data interrogation, dimensional joins, calculations, segmentation, KPI reporting, and trend analysis |

---

## 1. Business Context & Purpose
Reliable workforce information helps healthcare organisations understand staffing capacity, monitor sickness absence, identify areas of pressure, and plan services. This project brings related workforce measures together so that managers can explore trends across organisations, departments, and staff groups.

**The analysis addresses four core questions:**
* How is the workforce distributed?
* Where are absence events and working days lost concentrated?
* How does overtime vary across departments?
* What does the workforce demographic profile show?

---

## 2. NHS Data Definitions & National Reporting Context
A central feature of this project is the use of NHS workforce data standards as the reference point for understanding the information being analysed. The **NHS Data Model and Dictionary** provides standard NHS terminology and definitions. The **National Workforce Data Set (NWD; DAPB1067)** defines common workforce data items and classifications that support consistent collection and analysis across the health service.

### Applying NHS Definitions to the Analysis

| NHS Information Concept | How it Informs this Project |
| :--- | :--- |
| **Organisational Structure** | Analysis by organisation, division, and department; consistent organisational groupings are needed for comparable reporting. |
| **Workforce Classifications** | Staff-group and job-role analysis; standard categories help avoid inconsistent grouping. |
| **Headcount & Capacity** | Employee totals and workforce views; distinguishing individuals from assignments and full-time equivalent (FTE) is essential. |
| **Sickness Absence** | Absence episodes and days lost; definitions and denominators determine whether a measure represents volume, duration, or a true rate. |
| **Workforce Demographics** | Gender, ethnicity, disability, and other categories; consistent coding, missing-value treatment, and appropriate disclosure controls are important. |

> 💡 **Example Interpretation:** Counting absence records shows activity, while summing working days lost shows the amount of time lost. Neither is the same as the NHS sickness absence rate, which uses FTE days sick divided by FTE days available. Keeping these definitions separate is critical when interpreting performance.

---

## 3. Data Structure & Analytical Approach
The SQL queries use a star-schema (fact-and-dimension) structure. Absence and workforce records provide the measurable events or observations; supporting tables describe departments, organisations, employees, roles, and reasons for absence.

| Table | Analytical Use |
| :--- | :--- |
| `fact_absence` | Absence records and working days lost |
| `fact_workforce` | Workforce records and their organisational or job-role relationships |
| `dim_employee` | Employee characteristics such as gender, nationality, and date of birth |
| `dim_department` | Department descriptions |
| `dim_organisation` | Organisation names |
| `dim_job_role` | Job roles and staff groups |
| `dim_absence_reason` | Absence categories |

---

## 4. SQL Analysis: Techniques & Examples

### Department-Level Absence Analysis
A `LEFT JOIN` links absence records to departments. `COUNT` summarises recorded absence occurrences and `SUM` calculates working days lost. `GROUP BY` produces a departmental comparison that can be sorted to identify high-volume areas.

```sql
SELECT d.department,       
       COUNT(a.department_key) AS Nr_Of_Absence,       
       SUM(a.working_days_lost) AS total_days_lost
FROM fact_absence a
LEFT JOIN dim_department d  ON a.department_key = d.department_key
GROUP BY d.department
ORDER BY Nr_Of_Absence DESC;
```

### Workforce Demographic Analysis
SQL `JOIN`, `COUNT`, and `GROUP BY` are used to examine workforce records by staff group and gender. Additional queries group employees by nationality and examine nationality within staff groups.

```sql
SELECT jr.staff_group, e.gender,       
       COUNT(*) AS Nr_of_employees
FROM fact_workforce w
JOIN dim_employee e ON w.employee_key = e.employee_key
JOIN dim_job_role jr ON w.job_role_key = jr.job_role_key
GROUP BY jr.staff_group, e.gender
ORDER BY jr.staff_group, Nr_of_employees DESC;
```

### SQL Capabilities Applied:
* **JOIN / LEFT JOIN:** Combine workforce facts with descriptive dimensions.
* **COUNT / SUM:** Calculate event, employee-record, and days-lost totals.
* **GROUP BY / ORDER BY:** Compare categories and rank totals.
* **CASE / DATEDIFF:** Build age-based analytical groups.
* **CTE:** Break multi-stage SQL logic into readable steps.
* **SUM() OVER (PARTITION BY):** Calculate totals across defined partitions.

---

## 5. Power BI Dashboard & Reporting Design
The Power BI report is organised into three connected views, allowing a reader to move from a high-level workforce summary to more detailed absence and demographic analysis.

| Report Page | Content and Analytical Purpose |
| :--- | :--- |
| **Overview** | Workforce totals, active employees, department count, overtime, employees by department, and working days lost over time. Provides an initial view of workforce capacity and pressure. |
| **Absence** | Absence records, working days lost, sickness days, comparisons by department and reason, monthly and financial-year trends, and return-to-work interview breakdowns. Supports monitoring of absence patterns. |
| **Demographics** | Workforce composition by gender, ethnicity, disability, marital status, and qualification, with salary-related views. Supports examination of workforce representation and pay-related measures. |

---

## 6. Data Quality & Reporting Controls
NHS information reporting depends on clear definitions and reliable data. The following controls provide a practical framework for reviewing workforce analysis before figures are used in management decisions.

* **Completeness:** Identify missing employee, department, job-role, absence-reason, and time fields.
* **Duplicate & Grain Checks:** Ensure counts refer to the intended unit, such as an employee, assignment, or absence record.
* **Code & Definition Checks:** Use consistent workforce categories and investigate unmatched or unrecognised codes.
* **Reconciliation:** Compare SQL totals with corresponding Power BI measures using the same filters and period.
* **Trend Checks:** Investigate unusual changes against previous periods and check reporting-date boundaries.
* **Confidentiality:** Use aggregated reporting and appropriate controls when displaying sensitive workforce characteristics.

---

## 7. Reference Sources & Project Files
* 💾 **SQL Scripts:** `Health WorkForce.sql` (Available in repository files above)
* 📊 **Power BI File:** `Health Care.pbix` (Available in repository files above)
* [NHS Data Model and Dictionary](https://standards.nhs.uk)
* [National Workforce Data Set, DAPB1067](https://standards.nhs.uk)
* [NHS National Workforce Data Set Guidance](https://digital.nhs.uk)
* [NHS Sickness Absence Rates Methodology](https://digital.nhs.uk)
