# Data Analyst Job Insights and Skills Analysis using SQL  

## Overview  
This project focuses on analyzing job postings to extract insights into the highest-paying Data Analyst roles, the skills in demand, and the optimal skills required for such positions. Using SQL, we performed data exploration and analysis to provide actionable insights for job seekers in the Data Analytics field.  

## Objectives  

- Identify the top-paying remote Data Analyst roles and their associated skills.  
- Analyze the most in-demand skills for Data Analysts across all job postings.  
- Determine the relationship between skills and salary levels to highlight optimal skills for job seekers.  

## Dataset  

The dataset comprises job postings for Data Analyst roles, including job details, salaries, skills, and company information. The data is structured into the following tables:  
- `job_postings_fact`: Contains job-specific details such as job title, location, and salary.  
- `company_dim`: Provides company-specific details.  
- `skills_dim`: Contains skill names.  
- `skills_job_dim`: Maps job postings to the required skills.  

## Schema  

### job_postings_fact  
- `job_id`  
- `job_title`  
- `job_title_short`  
- `job_location`  
- `salary_year_avg`  
- `job_posted_date`  
- `company_id`  
- `job_work_from_home`  

### company_dim  
- `company_id`  
- `name`  

### skills_dim  
- `skill_id`  
- `skills`  

### skills_job_dim  
- `job_id`  
- `skill_id`  

## SQL Queries  

```sql
/* 
Identify the top 10 highest-paying remote Data Analyst roles.
Focus on job postings with specified salaries to determine the most lucrative roles.
*/

SELECT 
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM 
    job_postings_fact
LEFT JOIN company_dim 
    ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere' 
    AND salary_year_avg IS NOT NULL 
ORDER BY salary_year_avg DESC
LIMIT 10;

/* 
Analyze the skills required for top-paying Data Analyst jobs.
Add specified skills for these roles to provide actionable insights for job seekers.
*/

WITH top_paying_jobs AS (
    SELECT 
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM 
        job_postings_fact
    LEFT JOIN company_dim 
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE 
        job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere' 
        AND salary_year_avg IS NOT NULL 
    ORDER BY salary_year_avg DESC
    LIMIT 10
)
SELECT  
    top_paying_jobs.*,
    skills  
FROM 
    top_paying_jobs   
INNER JOIN skills_job_dim 
    ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC;

/* 
Identify the top 5 most in-demand skills for Data Analysts.
Focus on all job postings to rank the most required skills. 
*/

SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM 
    job_postings_fact 
INNER JOIN skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY 
    skills 
ORDER BY 
    demand_count DESC
LIMIT 5;

/* 
Examine the relationship between skills and salary levels.
Identify the average salary associated with each skill to determine how different skills impact earnings.
*/

SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS average_salary
FROM 
    job_postings_fact 
INNER JOIN skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' 
    AND salary_year_avg IS NOT NULL
GROUP BY 
    skills
ORDER BY 
    average_salary DESC
LIMIT 20;

/* 
Determine the most optimal skills for Data Analysts.
Identify skills that are both in high demand and associated with high average salaries.
*/

WITH skills_demand AS (
    SELECT 
        skills_dim.skills,
        skills_dim.skill_id,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM 
        job_postings_fact 
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL 
        AND job_work_from_home = TRUE
    GROUP BY 
        skills_dim.skill_id 
), 
average_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM 
        job_postings_fact 
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL
    GROUP BY 
        skills_job_dim.skill_id
)
SELECT 
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
FROM 
    skills_demand
INNER JOIN 
    average_salary 
    ON skills_demand.skill_id = average_salary.skill_id
ORDER BY 
    demand_count DESC, 
    avg_salary DESC
LIMIT 25;
