# SQL Job Market Analysis

A pure SQL project that analyses 50,000+ job postings to identify salary benchmarks, hiring trends, and the most valuable skills in the data analyst job market — using advanced query techniques throughout.

---

## Problem Statement

Which SQL, Python, and BI skills are actually worth learning for a data analyst job seeker? What do salaries look like across roles and locations? This project answers those questions directly from raw job postings data using nothing but SQL.

---

## Dataset

- 50,000+ job postings
- Tables: job_postings, skills, company_dim, job_skills
- Hosted in MySQL local instance
- Schema involves multi-table relationships requiring joins across 4 tables

---

## Tech Stack

| Layer | Tools |
|---|---|
| Language | SQL |
| Database | MySQL |
| Environment | MySQL Workbench |
| Techniques | CTEs, Window Functions, Multi-table Joins, Indexing |

---

## Queries and Techniques Used

### 1. Top 10 Highest-Paying Skills

WITH skill_salaries AS (
    SELECT 
        s.skill_name,
        ROUND(AVG(jp.salary_year_avg), 0) AS avg_salary,
        COUNT(jp.job_id) AS job_count
    FROM job_postings jp
    JOIN job_skills js ON jp.job_id = js.job_id
    JOIN skills s ON js.skill_id = s.skill_id
    WHERE jp.salary_year_avg IS NOT NULL
    GROUP BY s.skill_name
)
SELECT skill_name, avg_salary, job_count
FROM skill_salaries
ORDER BY avg_salary DESC
LIMIT 10;

### 2. Hiring Trends by Month (Window Function)

SELECT 
    DATE_FORMAT(job_posted_date, '%Y-%m') AS month,
    COUNT(*) AS postings,
    SUM(COUNT(*)) OVER (ORDER BY DATE_FORMAT(job_posted_date, '%Y-%m')) 
        AS running_total
FROM job_postings
GROUP BY month
ORDER BY month;

### 3. Salary Benchmarks by Role (RANK)

WITH role_salaries AS (
    SELECT
        job_title_short,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary,
        COUNT(*) AS total_postings
    FROM job_postings
    WHERE salary_year_avg IS NOT NULL
    GROUP BY job_title_short
)
SELECT 
    job_title_short,
    avg_salary,
    total_postings,
    RANK() OVER (ORDER BY avg_salary DESC) AS salary_rank
FROM role_salaries;

---

## Query Optimisation

A slow full-table scan was identified on the skills join:

Before: full scan on job_skills (slow on 50k+ rows)
EXPLAIN SELECT * FROM job_postings jp
JOIN job_skills js ON jp.job_id = js.job_id;

Fix: composite index on the join column
CREATE INDEX idx_job_skills_job_id 
ON job_skills(job_id, skill_id);

Result: query execution dropped from several seconds to under 1 second

---

## Key Findings

- Top 3 skills by posting frequency: SQL (78%), Python (71%), Excel (62%)
- Highest paying skill: Cloud platforms (AWS, Azure) add 25–35% salary premium
- Peak hiring months: January and September have the highest posting volume
- Senior DA roles pay 2.1x entry-level on average

---

## Project Structure

sql-job-market-analysis/
│
├── queries/
│   ├── 1_top_paying_skills.sql
│   ├── 2_hiring_trends.sql
│   ├── 3_salary_benchmarks.sql
│   ├── 4_skill_demand.sql
│   └── 5_query_optimisation.sql
├── data/
│   └── schema.sql
└── README.md

---

## How to Run

git clone https://github.com/Kishoreyanduri/sql-job-market-analysis
cd sql-job-market-analysis

Import schema first:
mysql -u root -p < data/schema.sql

Then run individual query files:
mysql -u root -p job_market < queries/1_top_paying_skills.sql
