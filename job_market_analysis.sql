-- Query 1: Top Paying Jobs

SELECT 
    p.title,
    p.company_name,
    s.max_salary
FROM postings p
JOIN salaries s 
ON p.job_id = s.job_id
WHERE s.max_salary IS NOT NULL
ORDER BY s.max_salary DESC
LIMIT 10;

-- Query 2: Most In-Demand Skills
SELECT 
    s.skill_name,
    COUNT(js.job_id) AS demand_count
FROM job_skills js
JOIN skills s 
ON js.skill_abr = s.skill_abr
GROUP BY s.skill_name
ORDER BY demand_count DESC
LIMIT 10;

-- Query 3: Highest Paying Skills

SELECT 
    s.skill_name,
    AVG(sal.max_salary) AS avg_salary
FROM job_skills js
JOIN skills s 
ON js.skill_abr = s.skill_abr
JOIN salaries sal 
ON js.job_id = sal.job_id
WHERE sal.max_salary IS NOT NULL
GROUP BY s.skill_name
ORDER BY avg_salary DESC
LIMIT 10;

-- Query 4: Skill Opportunity Score

SELECT 
    s.skill_name,
    COUNT(js.job_id) AS demand,
    AVG(sal.max_salary) AS avg_salary,
    (COUNT(js.job_id) * AVG(sal.max_salary)) AS opportunity_score
FROM job_skills js
JOIN skills s 
ON js.skill_abr = s.skill_abr
JOIN salaries sal 
ON js.job_id = sal.job_id
WHERE sal.max_salary IS NOT NULL
GROUP BY s.skill_name
ORDER BY opportunity_score DESC
LIMIT 10;